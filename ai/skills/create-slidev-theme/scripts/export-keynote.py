#!/usr/bin/env python3
"""Безопасно экспортирует копию Keynote в PPTX, PDF и изображения."""

from __future__ import annotations

import argparse
import hashlib
import json
import locale
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET


APPLESCRIPT_PATH = Path(__file__).with_name("export-keynote.applescript")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def inspect_path(path: Path) -> dict[str, object]:
    if path.is_file():
        return {"bytes": path.stat().st_size, "sha256": sha256_file(path)}
    digest = hashlib.sha256()
    total_bytes = 0
    entry_count = 0
    for item in sorted(path.rglob("*"), key=lambda value: value.relative_to(path).as_posix()):
        relative = item.relative_to(path).as_posix()
        entry_count += 1
        if item.is_symlink():
            digest.update(f"symlink\0{relative}\0{os.readlink(item)}\0".encode())
        elif item.is_dir():
            digest.update(f"directory\0{relative}\0".encode())
        elif item.is_file():
            size = item.stat().st_size
            file_hash = sha256_file(item)
            total_bytes += size
            digest.update(f"file\0{relative}\0{size}\0{file_hash}\0".encode())
    return {"bytes": total_bytes, "entryCount": entry_count, "sha256": digest.hexdigest()}


def copy_source(source: Path, destination: Path) -> None:
    if source.is_dir():
        shutil.copytree(source, destination)
    else:
        shutil.copy2(source, destination)


def pptx_slide_count(path: Path) -> int:
    namespaces = {
        "p": "http://schemas.openxmlformats.org/presentationml/2006/main",
    }
    with zipfile.ZipFile(path) as package:
        root = ET.fromstring(package.read("ppt/presentation.xml"))
    return len(root.findall("p:sldIdLst/p:sldId", namespaces))


def pdf_page_count(path: Path) -> int | None:
    mdls = shutil.which("mdls")
    if mdls:
        result = subprocess.run(
            [mdls, "-raw", "-name", "kMDItemNumberOfPages", str(path)],
            check=False,
            capture_output=True,
            text=True,
        )
        value = result.stdout.strip()
        if result.returncode == 0 and value.isdigit():
            return int(value)
    pdfinfo = shutil.which("pdfinfo")
    if pdfinfo:
        result = subprocess.run([pdfinfo, str(path)], check=False, capture_output=True, text=True)
        for line in result.stdout.splitlines():
            if line.startswith("Pages:") and line.split(":", 1)[1].strip().isdigit():
                return int(line.split(":", 1)[1].strip())
    return None


def image_files(path: Path) -> list[tuple[int, Path]]:
    extensions = {".jpeg", ".jpg", ".png", ".tif", ".tiff"}
    indexed = []
    for item in path.rglob("*"):
        if not item.is_file() or item.suffix.lower() not in extensions:
            continue
        matches = re.findall(r"\d+", item.stem)
        if not matches:
            raise ValueError(f"В имени изображения нет номера слайда: {item.name}")
        indexed.append((int(matches[-1]), item))
    indexed.sort(key=lambda value: (value[0], value[1].as_posix()))
    indices = [index for index, _ in indexed]
    if len(indices) != len(set(indices)):
        raise ValueError(f"Номера изображений повторяются: {indices}")
    if indices != list(range(1, len(indices) + 1)):
        raise ValueError(f"Номера изображений не образуют последовательность 1..N: {indices}")
    return indexed


def normalized_rmse(source: Path, target: Path, directory: Path, index: int) -> float:
    magick = shutil.which("magick")
    if not magick:
        raise ValueError("Для проверки порядка нужен ImageMagick (команда magick)")
    normalized_source = directory / f"source-{index}.png"
    normalized_target = directory / f"target-{index}.png"
    for input_path, output_path in ((source, normalized_source), (target, normalized_target)):
        result = subprocess.run(
            [magick, str(input_path), "-auto-orient", "-resize", "512x512!", "-colorspace", "sRGB", str(output_path)],
            check=False,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            raise ValueError(f"ImageMagick не нормализовал {input_path.name}: {result.stderr.strip()}")
    result = subprocess.run(
        [magick, "compare", "-metric", "RMSE", str(normalized_source), str(normalized_target), "null:"],
        check=False,
        capture_output=True,
        text=True,
    )
    match = re.search(r"\((\d+(?:\.\d+)?)\)", result.stderr)
    if result.returncode not in {0, 1} or not match:
        raise ValueError(f"ImageMagick не сравнил пару {index}: {result.stderr.strip()}")
    return float(match.group(1))


def verify_pdf_order(pdf: Path, images: list[tuple[int, Path]], rmse_max: float) -> list[dict[str, object]]:
    pdftoppm = shutil.which("pdftoppm")
    if not pdftoppm:
        raise ValueError("Для проверки порядка нужен Poppler (команда pdftoppm)")
    with tempfile.TemporaryDirectory(prefix="slidev-keynote-order-") as temporary:
        directory = Path(temporary)
        prefix = directory / "pdf-page"
        result = subprocess.run(
            [pdftoppm, "-png", "-r", "144", str(pdf), str(prefix)],
            check=False,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            raise ValueError(f"Не удалось растрировать PDF для проверки порядка: {result.stderr.strip()}")
        pages = image_files(directory)
        if [index for index, _ in pages] != [index for index, _ in images]:
            raise ValueError("Номера страниц PDF и изображений Keynote не совпадают")
        evidence = []
        for (index, source), (_, page) in zip(images, pages, strict=True):
            rmse = normalized_rmse(source, page, directory, index)
            evidence.append({"slide": index, "image": source.name, "pdfPage": index, "normalizedRmse": rmse})
            if rmse > rmse_max:
                raise ValueError(f"Не доказан порядок слайда {index}: RMSE {rmse:.6f} больше {rmse_max:.6f}")
    return evidence


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def close_working_copy(osascript: str, document_stem: str) -> None:
    cleanup_script = f'''
tell application "Keynote"
  repeat with openedDocument in documents
    if name of openedDocument starts with "{document_stem}" then close openedDocument saving no
  end repeat
end tell
'''
    subprocess.run([osascript, "-"], input=cleanup_script, check=False, capture_output=True, text=True, timeout=30)


def arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Экспортировать рабочую копию Keynote в проверяемый набор форматов")
    parser.add_argument("keynote", type=Path, help="Исходный файл или пакет .key")
    parser.add_argument("--output-dir", type=Path, required=True, help="Новый или пустой каталог экспорта")
    parser.add_argument("--timeout", type=int, default=600, help="Предельное время экспорта в секундах")
    parser.add_argument("--source-id", help="Переносимый путь входа в каталоге темы; по умолчанию — имя файла")
    parser.add_argument("--order-rmse-max", type=float, default=0.12, help="Максимальный RMSE пары изображение/PDF для доказательства порядка")
    parser.add_argument("--dry-run", action="store_true", help="Проверить параметры без запуска Keynote")
    return parser.parse_args()


def main() -> int:
    options = arguments()
    source = options.keynote.expanduser().resolve()
    output = options.output_dir.expanduser().resolve()
    if not source.exists() or source.suffix.lower() != ".key":
        print(f"Ошибка: не найден файл или пакет Keynote: {source}", file=sys.stderr)
        return 1
    source_id = options.source_id or source.name
    if Path(source_id).is_absolute() or ".." in Path(source_id).parts:
        print("Ошибка: --source-id должен быть относительным путём без '..'", file=sys.stderr)
        return 1
    if not 0 < options.order_rmse_max < 1:
        print("Ошибка: --order-rmse-max должен быть между 0 и 1", file=sys.stderr)
        return 1
    if output.exists() and any(output.iterdir()):
        print(f"Ошибка: каталог экспорта не пуст: {output}", file=sys.stderr)
        return 1
    plan = {
        "source": str(source),
        "sourceDigest": inspect_path(source),
        "outputDir": str(output),
        "exports": ["presentation.pptx", "presentation.pdf", "slides/", "keynote-export.json"],
    }
    if options.dry_run:
        print(json.dumps(plan, ensure_ascii=False, indent=2))
        return 0
    if platform.system() != "Darwin":
        print("Ошибка: экспорт Keynote поддерживается только в macOS", file=sys.stderr)
        return 1
    osascript = shutil.which("osascript")
    if not osascript:
        print("Ошибка: не найден osascript", file=sys.stderr)
        return 1
    if not APPLESCRIPT_PATH.is_file():
        print(f"Ошибка: не найден сценарий экспорта: {APPLESCRIPT_PATH}", file=sys.stderr)
        return 1

    output.mkdir(parents=True, exist_ok=True)
    pptx_path = output / "presentation.pptx"
    pdf_path = output / "presentation.pdf"
    images_path = output / "slides"
    working_stem = f"slidev-export-{plan['sourceDigest']['sha256'][:12]}"
    with tempfile.TemporaryDirectory(prefix="slidev-keynote-export-") as temporary:
        working_source = Path(temporary) / f"{working_stem}.key"
        copy_source(source, working_source)
        try:
            result = subprocess.run(
                [osascript, "-", str(working_source), str(pptx_path), str(pdf_path), str(images_path)],
                input=APPLESCRIPT_PATH.read_text(encoding="utf-8"),
                check=False,
                capture_output=True,
                text=True,
                timeout=options.timeout,
            )
        except subprocess.TimeoutExpired:
            try:
                close_working_copy(osascript, working_stem)
            except (OSError, subprocess.TimeoutExpired):
                pass
            print(f"Ошибка: Keynote не завершил экспорт за {options.timeout} секунд", file=sys.stderr)
            return 1
    if result.returncode != 0:
        print(f"Ошибка Keynote: {result.stderr.strip() or result.stdout.strip()}", file=sys.stderr)
        return 1

    output_lines = [line.strip() for line in result.stdout.splitlines() if line.strip()]
    if len(output_lines) < 2 or not output_lines[-1].isdigit():
        print(f"Ошибка: Keynote вернул неожиданный ответ: {result.stdout!r}", file=sys.stderr)
        return 1
    keynote_version = output_lines[-2]
    keynote_count = int(output_lines[-1])
    if not pptx_path.is_file() or not pdf_path.is_file() or not images_path.exists():
        print("Ошибка: Keynote создал не все обязательные экспорты", file=sys.stderr)
        return 1

    pptx_count = pptx_slide_count(pptx_path)
    pdf_count = pdf_page_count(pdf_path)
    try:
        images = image_files(images_path)
    except ValueError as error:
        print(f"Ошибка: {error}", file=sys.stderr)
        return 1
    image_count = len(images)
    counts = {"keynote": keynote_count, "pptx": pptx_count, "pdf": pdf_count, "images": image_count}
    comparable_counts = [value for value in counts.values() if value is not None]
    count_match = pdf_count is not None and len(comparable_counts) == 4 and len(set(comparable_counts)) == 1
    order_evidence = []
    if count_match:
        try:
            order_evidence = verify_pdf_order(pdf_path, images, options.order_rmse_max)
        except ValueError as error:
            print(f"Ошибка: {error}", file=sys.stderr)
            return 1
    images_by_index = dict(images)
    mappings = [
        {
            "keynoteSlide": index,
            "pptxSlide": index if index <= pptx_count else None,
            "pdfPage": index if pdf_count is not None and index <= pdf_count else None,
            "image": images_by_index[index].relative_to(output).as_posix() if index in images_by_index else None,
        }
        for index in range(1, max(comparable_counts, default=0) + 1)
    ]
    manifest = {
        "version": 1,
        "status": "ok" if count_match else "count-mismatch",
        "source": {"path": source_id, **inspect_path(source)},
        "environment": {
            "macOS": platform.mac_ver()[0],
            "keynote": keynote_version,
            "locale": locale.getlocale(),
        },
        "exports": {
            "pptx": {"path": pptx_path.name, **inspect_path(pptx_path)},
            "pdf": {"path": pdf_path.name, **inspect_path(pdf_path)},
            "images": {"path": images_path.name, **inspect_path(images_path)},
        },
        "counts": counts,
        "orderVerification": {
            "method": "Keynote image export compared with same-index PDF raster",
            "rmseMaximum": options.order_rmse_max,
            "verified": count_match and len(order_evidence) == keynote_count,
            "pairs": order_evidence,
        },
        "mappings": mappings,
        "warnings": [
            "PPTX может изменить маски, диаграммы, гарнитуры и наследование",
            "PDF и изображения не сохраняют редактируемую структуру",
            "Статические экспорты не доказывают точность сборок и анимации",
        ],
    }
    write_json(output / "keynote-export.json", manifest)
    if not count_match:
        print(f"Ошибка: число слайдов расходится: {counts}", file=sys.stderr)
        return 2
    print(f"Экспортировано слайдов: {keynote_count}; манифест: {output / 'keynote-export.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
