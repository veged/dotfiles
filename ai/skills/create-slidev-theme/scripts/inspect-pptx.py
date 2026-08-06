#!/usr/bin/env python3
"""Строит детерминированную структурную опись PPTX без внешних зависимостей."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import mimetypes
import posixpath
import sys
import zipfile
from pathlib import Path, PurePosixPath
from typing import Any
from xml.etree import ElementTree as ET


NS = {
    "a": "http://schemas.openxmlformats.org/drawingml/2006/main",
    "c": "http://schemas.openxmlformats.org/drawingml/2006/chart",
    "dgm": "http://schemas.openxmlformats.org/drawingml/2006/diagram",
    "p": "http://schemas.openxmlformats.org/presentationml/2006/main",
    "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    "rel": "http://schemas.openxmlformats.org/package/2006/relationships",
}


def local_name(value: str) -> str:
    return value.rsplit("}", 1)[-1]


def clean_attributes(element: ET.Element | None) -> dict[str, str]:
    if element is None:
        return {}
    return {local_name(key): value for key, value in sorted(element.attrib.items())}


def namespace_uri(value: str) -> str | None:
    if value.startswith("{") and "}" in value:
        return value[1:].split("}", 1)[0]
    return None


def xml_to_data(element: ET.Element | None) -> dict[str, Any] | None:
    """Сохраняет неизвестные DrawingML-поля без притворной интерпретации."""
    if element is None:
        return None
    result: dict[str, Any] = {
        "tag": local_name(element.tag),
        "attributes": clean_attributes(element),
    }
    namespace = namespace_uri(element.tag)
    if namespace:
        result["namespace"] = namespace
    text = (element.text or "").strip()
    if text:
        result["text"] = text
    children = [xml_to_data(child) for child in element]
    if children:
        result["children"] = children
    return result


def integer(value: str | None) -> int | None:
    if value is None:
        return None
    try:
        return int(value)
    except ValueError:
        return None


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_xml(package: zipfile.ZipFile, part: str) -> ET.Element:
    return ET.fromstring(package.read(part))


def source_from_relationship_part(path: str) -> str:
    if path == "_rels/.rels":
        return ""
    directory = posixpath.dirname(path)
    parent = posixpath.dirname(directory)
    filename = posixpath.basename(path)
    if not directory.endswith("/_rels") or not filename.endswith(".rels"):
        raise ValueError(f"Некорректный путь relationships: {path}")
    return posixpath.join(parent, filename[:-5])


def resolve_relationship_target(source: str, target: str) -> str:
    base = posixpath.dirname(source) if source else ""
    return posixpath.normpath(posixpath.join(base, target)).lstrip("/")


def relationship_index(package: zipfile.ZipFile, names: set[str]) -> tuple[dict[str, dict[str, dict[str, Any]]], list[dict[str, Any]]]:
    by_source: dict[str, dict[str, dict[str, Any]]] = {}
    all_relationships: list[dict[str, Any]] = []
    for path in sorted(name for name in names if name.endswith(".rels")):
        source = source_from_relationship_part(path)
        root = parse_xml(package, path)
        source_relationships: dict[str, dict[str, Any]] = {}
        for relation in root:
            relation_id = relation.attrib.get("Id", "")
            external = relation.attrib.get("TargetMode") == "External"
            target = relation.attrib.get("Target", "")
            target_part = target if external else resolve_relationship_target(source, target)
            record = {
                "id": relation_id,
                "type": relation.attrib.get("Type", ""),
                "target": target,
                "targetMode": "External" if external else "Internal",
                "targetPart": target_part,
                "broken": False if external else target_part not in names,
            }
            source_relationships[relation_id] = record
            all_relationships.append({"sourcePart": source or "/", **record})
        by_source[source] = source_relationships
    return by_source, all_relationships


def content_type_index(package: zipfile.ZipFile) -> tuple[dict[str, str], dict[str, str]]:
    root = parse_xml(package, "[Content_Types].xml")
    defaults: dict[str, str] = {}
    overrides: dict[str, str] = {}
    for element in root:
        if local_name(element.tag) == "Default":
            defaults[element.attrib.get("Extension", "").lower()] = element.attrib.get("ContentType", "")
        elif local_name(element.tag) == "Override":
            overrides[element.attrib.get("PartName", "").lstrip("/")] = element.attrib.get("ContentType", "")
    return defaults, overrides


def content_type(path: str, defaults: dict[str, str], overrides: dict[str, str]) -> str:
    extension = PurePosixPath(path).suffix.lstrip(".").lower()
    return overrides.get(path) or defaults.get(extension) or mimetypes.guess_type(path)[0] or "application/octet-stream"


def identity_matrix() -> list[list[float]]:
    return [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]


def multiply(left: list[list[float]], right: list[list[float]]) -> list[list[float]]:
    return [
        [sum(left[row][index] * right[index][column] for index in range(3)) for column in range(3)]
        for row in range(3)
    ]


def translate(x: float, y: float) -> list[list[float]]:
    return [[1.0, 0.0, x], [0.0, 1.0, y], [0.0, 0.0, 1.0]]


def scale(x: float, y: float) -> list[list[float]]:
    return [[x, 0.0, 0.0], [0.0, y, 0.0], [0.0, 0.0, 1.0]]


def rotate(angle: float) -> list[list[float]]:
    cosine = math.cos(angle)
    sine = math.sin(angle)
    return [[cosine, -sine, 0.0], [sine, cosine, 0.0], [0.0, 0.0, 1.0]]


def around_center(matrix: list[list[float]], x: float, y: float) -> list[list[float]]:
    return multiply(translate(x, y), multiply(matrix, translate(-x, -y)))


def apply_matrix(matrix: list[list[float]], x: float, y: float) -> list[float]:
    return [matrix[0][0] * x + matrix[0][1] * y + matrix[0][2], matrix[1][0] * x + matrix[1][1] * y + matrix[1][2]]


def parse_point(element: ET.Element | None) -> dict[str, int] | None:
    if element is None:
        return None
    x = integer(element.attrib.get("x") or element.attrib.get("cx"))
    y = integer(element.attrib.get("y") or element.attrib.get("cy"))
    if x is None or y is None:
        return None
    return {"x": x, "y": y}


def find_transform(element: ET.Element) -> ET.Element | None:
    candidates = [
        "./p:spPr/a:xfrm",
        "./p:grpSpPr/a:xfrm",
        "./p:xfrm",
        "./p:pic/p:spPr/a:xfrm",
    ]
    for query in candidates:
        found = element.find(query, NS)
        if found is not None:
            return found
    return None


def parse_transform(element: ET.Element) -> dict[str, Any] | None:
    transform = find_transform(element)
    if transform is None:
        return None
    result: dict[str, Any] = {
        "off": parse_point(transform.find("a:off", NS)),
        "ext": parse_point(transform.find("a:ext", NS)),
        "chOff": parse_point(transform.find("a:chOff", NS)),
        "chExt": parse_point(transform.find("a:chExt", NS)),
        "rotation60000": integer(transform.attrib.get("rot")) or 0,
        "flipH": transform.attrib.get("flipH") in {"1", "true"},
        "flipV": transform.attrib.get("flipV") in {"1", "true"},
    }
    return result


def object_matrix(parent: list[list[float]], transform: dict[str, Any] | None) -> list[list[float]]:
    if not transform or not transform.get("off") or not transform.get("ext"):
        return parent
    off = transform["off"]
    ext = transform["ext"]
    center_x = off["x"] + ext["x"] / 2
    center_y = off["y"] + ext["y"] / 2
    flip_matrix = scale(-1.0 if transform["flipH"] else 1.0, -1.0 if transform["flipV"] else 1.0)
    angle = math.radians(transform["rotation60000"] / 60000)
    own = around_center(multiply(rotate(angle), flip_matrix), center_x, center_y)
    return multiply(parent, own)


def group_child_matrix(parent: list[list[float]], transform: dict[str, Any] | None) -> list[list[float]]:
    if not transform or not all(transform.get(key) for key in ("off", "ext", "chOff", "chExt")):
        return parent
    off, ext = transform["off"], transform["ext"]
    child_off, child_ext = transform["chOff"], transform["chExt"]
    scale_x = ext["x"] / child_ext["x"] if child_ext["x"] else 1.0
    scale_y = ext["y"] / child_ext["y"] if child_ext["y"] else 1.0
    base = multiply(translate(off["x"], off["y"]), multiply(scale(scale_x, scale_y), translate(-child_off["x"], -child_off["y"])))
    center_x = off["x"] + ext["x"] / 2
    center_y = off["y"] + ext["y"] / 2
    flip_matrix = scale(-1.0 if transform["flipH"] else 1.0, -1.0 if transform["flipV"] else 1.0)
    angle = math.radians(transform["rotation60000"] / 60000)
    own = around_center(multiply(rotate(angle), flip_matrix), center_x, center_y)
    return multiply(parent, multiply(own, base))


def matrix_values(matrix: list[list[float]]) -> list[float]:
    return [value for row in matrix for value in row]


def quad(transform: dict[str, Any] | None, matrix: list[list[float]]) -> list[list[float]] | None:
    if not transform or not transform.get("off") or not transform.get("ext"):
        return None
    off, ext = transform["off"], transform["ext"]
    points = [
        (off["x"], off["y"]),
        (off["x"] + ext["x"], off["y"]),
        (off["x"] + ext["x"], off["y"] + ext["y"]),
        (off["x"], off["y"] + ext["y"]),
    ]
    return [apply_matrix(matrix, x, y) for x, y in points]


def non_visual_properties(element: ET.Element) -> dict[str, Any]:
    properties = next((node for node in element.iter() if local_name(node.tag) == "cNvPr"), None)
    if properties is None:
        return {"id": None, "name": None}
    hyperlink = properties.find("a:hlinkClick", NS)
    return {
        "id": integer(properties.attrib.get("id")),
        "name": properties.attrib.get("name"),
        "title": properties.attrib.get("title"),
        "description": properties.attrib.get("descr"),
        "hidden": properties.attrib.get("hidden") in {"1", "true"},
        "hyperlinkId": None if hyperlink is None else hyperlink.attrib.get(f"{{{NS['r']}}}id"),
    }


def placeholder_properties(element: ET.Element) -> dict[str, Any] | None:
    placeholder = next((node for node in element.iter() if local_name(node.tag) == "ph"), None)
    return None if placeholder is None else clean_attributes(placeholder)


def color_value(element: ET.Element | None) -> dict[str, Any] | None:
    if element is None or len(element) == 0:
        return None
    color = element[0]
    return {"kind": local_name(color.tag), "value": next(iter(color.attrib.values()), None), "transforms": [local_name(child.tag) for child in color]}


def parse_style(element: ET.Element) -> dict[str, Any]:
    properties = element.find("./p:spPr", NS)
    if properties is None:
        properties = element.find("./p:grpSpPr", NS)
    if properties is None:
        return {}
    fill = None
    for name in ("solidFill", "gradFill", "blipFill", "pattFill", "noFill"):
        node = properties.find(f"a:{name}", NS)
        if node is not None:
            fill = {"kind": name, "color": color_value(node) if name == "solidFill" else None}
            break
    line = properties.find("a:ln", NS)
    geometry = properties.find("a:prstGeom", NS)
    custom_geometry = properties.find("a:custGeom", NS)
    effects = properties.find("a:effectLst", NS)
    return {
        "fill": fill,
        "line": None if line is None else {"attributes": clean_attributes(line), "color": color_value(line.find("a:solidFill", NS))},
        "geometry": geometry.attrib.get("prst") if geometry is not None else ("custom" if custom_geometry is not None else None),
        "effects": [] if effects is None else [local_name(child.tag) for child in effects],
        "rawProperties": xml_to_data(properties),
    }


def parse_run_properties(element: ET.Element | None, relationships: dict[str, dict[str, Any]]) -> dict[str, Any]:
    if element is None:
        return {}
    result: dict[str, Any] = {"attributes": clean_attributes(element)}
    for family in ("latin", "ea", "cs"):
        node = element.find(f"a:{family}", NS)
        if node is not None and node.attrib.get("typeface"):
            result[family] = node.attrib["typeface"]
    fill = element.find("a:solidFill", NS)
    if fill is not None:
        result["color"] = color_value(fill)
    hyperlink = element.find("a:hlinkClick", NS)
    if hyperlink is not None:
        relation_id = hyperlink.attrib.get(f"{{{NS['r']}}}id")
        result["hyperlink"] = relationships.get(relation_id or "", {"id": relation_id})
    return result


def parse_paragraph_properties(element: ET.Element | None) -> dict[str, Any]:
    if element is None:
        return {}
    result: dict[str, Any] = {"attributes": clean_attributes(element)}
    for child in element:
        kind = local_name(child.tag)
        if kind in {"lnSpc", "spcBef", "spcAft"}:
            value = next(iter(child), None)
            result[kind] = None if value is None else {"kind": local_name(value.tag), "attributes": clean_attributes(value)}
        elif kind in {"buChar", "buAutoNum", "buNone", "buFont", "tabLst"}:
            result[kind] = clean_attributes(child)
    return result


def parse_text_body(element: ET.Element, relationships: dict[str, dict[str, Any]]) -> dict[str, Any] | None:
    body = element.find("./p:txBody", NS)
    if body is None:
        body = element.find(".//a:txBody", NS)
    if body is None:
        body = next((node for node in element.iter() if local_name(node.tag) == "txBody"), None)
    if body is None:
        return None
    paragraphs = []
    plain_paragraphs = []
    for paragraph in [node for node in body if local_name(node.tag) == "p"]:
        runs = []
        text_fragments = []
        for child in paragraph:
            kind = local_name(child.tag)
            if kind in {"r", "fld"}:
                text_node = next((node for node in child if local_name(node.tag) == "t"), None)
                value = text_node.text if text_node is not None and text_node.text is not None else ""
                properties = next((node for node in child if local_name(node.tag) == "rPr"), None)
                runs.append({"kind": kind, "text": value, "properties": parse_run_properties(properties, relationships)})
                text_fragments.append(value)
            elif kind == "br":
                runs.append({"kind": "break", "text": "\n", "properties": {}})
                text_fragments.append("\n")
        paragraph_properties = next((node for node in paragraph if local_name(node.tag) == "pPr"), None)
        text = "".join(text_fragments)
        paragraphs.append({"text": text, "properties": parse_paragraph_properties(paragraph_properties), "runs": runs})
        plain_paragraphs.append(text)
    body_properties = next((node for node in body if local_name(node.tag) == "bodyPr"), None)
    return {"text": "\n".join(plain_paragraphs), "bodyProperties": clean_attributes(body_properties), "paragraphs": paragraphs}


def resolve_relation(relationships: dict[str, dict[str, Any]], relation_id: str | None) -> dict[str, Any] | None:
    if not relation_id:
        return None
    return relationships.get(relation_id, {"id": relation_id, "broken": True})


def parse_table(table: ET.Element, relationships: dict[str, dict[str, Any]]) -> dict[str, Any]:
    grid = table.find("a:tblGrid", NS)
    columns = [] if grid is None else [integer(column.attrib.get("w")) for column in grid]
    rows = []
    merges = []
    for row_index, row in enumerate(table.findall("a:tr", NS), start=1):
        cells = []
        for column_index, cell in enumerate(row.findall("a:tc", NS), start=1):
            text = "\n".join(node.text or "" for node in cell.findall(".//a:t", NS))
            properties = cell.find("a:tcPr", NS)
            merge = {
                key: integer(cell.attrib.get(key)) if key in {"gridSpan", "rowSpan"} else cell.attrib.get(key) in {"1", "true"}
                for key in ("gridSpan", "rowSpan", "hMerge", "vMerge")
                if key in cell.attrib
            }
            if merge:
                merges.append({"row": row_index, "column": column_index, **merge})
            cells.append({
                "column": column_index,
                "attributes": clean_attributes(cell),
                "merge": merge or None,
                "text": text,
                "properties": clean_attributes(properties),
                "propertiesTree": xml_to_data(properties),
            })
        rows.append({"heightEmu": integer(row.attrib.get("h")), "cells": cells})
    properties = table.find("a:tblPr", NS)
    style_id = table.find("a:tblPr/a:tableStyleId", NS)
    return {
        "columnsEmu": columns,
        "tableProperties": xml_to_data(properties),
        "styleId": None if style_id is None else style_id.text,
        "merges": merges,
        "rows": rows,
    }


def parse_graphic_data(element: ET.Element, part: str, relationships: dict[str, dict[str, Any]], losses: list[dict[str, Any]], shape_id: int | None) -> dict[str, Any] | None:
    graphic_data = next((node for node in element.iter() if local_name(node.tag) == "graphicData"), None)
    if graphic_data is None:
        return None
    uri = graphic_data.attrib.get("uri", "")
    chart = graphic_data.find(".//c:chart", NS)
    table = graphic_data.find("a:tbl", NS)
    diagram = next((node for node in graphic_data.iter() if local_name(node.tag) == "relIds"), None)
    if chart is not None:
        relation_id = chart.attrib.get(f"{{{NS['r']}}}id")
        return {"kind": "chart", "uri": uri, "relationship": resolve_relation(relationships, relation_id)}
    if table is not None:
        return {"kind": "table", "uri": uri, "table": parse_table(table, relationships)}
    if diagram is not None:
        relations = {local_name(key): resolve_relation(relationships, value) for key, value in diagram.attrib.items()}
        losses.append({"severity": "structural", "part": part, "shapeId": shape_id, "code": "diagram-model-not-materialized", "detail": "Связи сохранены, но семантическая модель SmartArt не вычислена"})
        return {"kind": "diagram", "uri": uri, "relationships": relations}
    losses.append({"severity": "structural", "part": part, "shapeId": shape_id, "code": "unsupported-graphic-data", "detail": uri})
    return {"kind": "unsupported", "uri": uri}


def inspect_shape_tree(
    tree: ET.Element,
    part: str,
    relationships: dict[str, dict[str, Any]],
    losses: list[dict[str, Any]],
    media_uses: list[dict[str, Any]],
    parent_matrix: list[list[float]] | None = None,
) -> list[dict[str, Any]]:
    parent_matrix = parent_matrix or identity_matrix()
    records = []
    z_order = 0
    for element in tree:
        kind = local_name(element.tag)
        if kind in {"nvGrpSpPr", "grpSpPr", "extLst"}:
            continue
        z_order += 1
        properties = non_visual_properties(element)
        transform = parse_transform(element)
        current_matrix = object_matrix(parent_matrix, transform)
        record: dict[str, Any] = {
            "kind": kind,
            "id": properties["id"],
            "name": properties["name"],
            "title": properties.get("title"),
            "description": properties.get("description"),
            "hidden": properties.get("hidden"),
            "placeholder": placeholder_properties(element),
            "hyperlink": resolve_relation(relationships, properties.get("hyperlinkId")),
            "zOrder": z_order,
            "sourcePart": part,
            "transform": transform,
            "matrixToSlide": matrix_values(current_matrix),
            "quadEmu": quad(transform, current_matrix),
            "style": parse_style(element),
            "text": parse_text_body(element, relationships),
        }
        if record["style"].get("geometry") == "custom":
            losses.append({"severity": "structural", "part": part, "shapeId": properties["id"], "code": "custom-geometry-not-decoded", "detail": "Исходный custGeom сохранён в style.rawProperties"})
        if kind == "pic":
            blip = element.find(".//a:blip", NS)
            embedded = None if blip is None else blip.attrib.get(f"{{{NS['r']}}}embed")
            linked = None if blip is None else blip.attrib.get(f"{{{NS['r']}}}link")
            source_rect = element.find(".//a:srcRect", NS)
            relation = resolve_relation(relationships, embedded or linked)
            record["media"] = {
                "mode": "embedded" if embedded else "linked",
                "relationship": relation,
                "crop100000": clean_attributes(source_rect),
            }
            media_uses.append({"sourcePart": part, "shapeId": properties["id"], "shapeName": properties["name"], **record["media"]})
            if linked:
                losses.append({"severity": "structural", "part": part, "shapeId": properties["id"], "code": "linked-media-depends-on-external-target", "detail": relation})
        if kind == "graphicFrame":
            record["graphic"] = parse_graphic_data(element, part, relationships, losses, properties["id"])
        ole = next((node for node in element.iter() if local_name(node.tag) == "oleObj"), None)
        if ole is not None:
            relation_id = ole.attrib.get(f"{{{NS['r']}}}id")
            record["ole"] = {"attributes": clean_attributes(ole), "relationship": resolve_relation(relationships, relation_id)}
            losses.append({"severity": "structural", "part": part, "shapeId": properties["id"], "code": "ole-requires-fallback"})
        if kind == "grpSp":
            children_matrix = group_child_matrix(parent_matrix, transform)
            record["children"] = inspect_shape_tree(element, part, relationships, losses, media_uses, children_matrix)
        records.append(record)
    return records


def collect_placeholders(objects: list[dict[str, Any]]) -> list[dict[str, Any]]:
    result = []
    for obj in objects:
        if obj.get("placeholder") is not None:
            result.append({"objectId": obj.get("id"), "objectName": obj.get("name"), **obj["placeholder"]})
        result.extend(collect_placeholders(obj.get("children", [])))
    return result


def shape_tree(root: ET.Element) -> ET.Element | None:
    return root.find(".//p:spTree", NS)


def inspect_drawing_part(
    package: zipfile.ZipFile,
    part: str,
    relationships_by_source: dict[str, dict[str, dict[str, Any]]],
    losses: list[dict[str, Any]],
    media_uses: list[dict[str, Any]],
) -> dict[str, Any]:
    root = parse_xml(package, part)
    relationships = relationships_by_source.get(part, {})
    tree = shape_tree(root)
    objects = [] if tree is None else inspect_shape_tree(tree, part, relationships, losses, media_uses)
    return {
        "part": part,
        "show": root.attrib.get("show", "1") not in {"0", "false"},
        "objects": objects,
        "placeholders": collect_placeholders(objects),
        "transition": next((clean_attributes(node) for node in root.iter() if local_name(node.tag) == "transition"), None),
        "timingPresent": any(local_name(node.tag) == "timing" for node in root.iter()),
        "textStyles": xml_to_data(next((node for node in root.iter() if local_name(node.tag) == "txStyles"), None)),
    }


def relation_by_type(relationships: dict[str, dict[str, Any]], suffix: str) -> dict[str, Any] | None:
    return next((relation for relation in relationships.values() if relation["type"].endswith(suffix)), None)


def text_from_part(package: zipfile.ZipFile, part: str | None) -> str | None:
    if not part:
        return None
    root = parse_xml(package, part)
    values = [node.text or "" for node in root.iter() if local_name(node.tag) == "t"]
    return "\n".join(value for value in values if value)


def inspect_chart(package: zipfile.ZipFile, part: str, relationships_by_source: dict[str, dict[str, dict[str, Any]]]) -> dict[str, Any]:
    root = parse_xml(package, part)
    chart_types = sorted({local_name(node.tag) for node in root.iter() if local_name(node.tag).endswith("Chart")})
    series_count = sum(1 for node in root.iter() if local_name(node.tag) == "ser")
    external_data = next((node for node in root.iter() if local_name(node.tag) == "externalData"), None)
    relation_id = None if external_data is None else external_data.attrib.get(f"{{{NS['r']}}}id")
    series = []
    for node in [candidate for candidate in root.iter() if local_name(candidate.tag) == "ser"]:
        formulas = [candidate.text or "" for candidate in node.iter() if local_name(candidate.tag) == "f"]
        caches = []
        for cache in [candidate for candidate in node.iter() if local_name(candidate.tag) in {"numCache", "strCache", "multiLvlStrCache"}]:
            points = []
            for point in [candidate for candidate in cache if local_name(candidate.tag) in {"pt", "lvl"}]:
                values = [child.text or "" for child in point.iter() if local_name(child.tag) == "v"]
                points.append({"attributes": clean_attributes(point), "values": values})
            caches.append({"kind": local_name(cache.tag), "points": points, "rawTree": xml_to_data(cache)})
        series.append({
            "index": integer(next((candidate.attrib.get("val") for candidate in node if local_name(candidate.tag) == "idx"), None)),
            "order": integer(next((candidate.attrib.get("val") for candidate in node if local_name(candidate.tag) == "order"), None)),
            "formulas": formulas,
            "caches": caches,
            "rawTree": xml_to_data(node),
        })
    axes = []
    for node in [candidate for candidate in root.iter() if local_name(candidate.tag).endswith("Ax")]:
        value = lambda name: next((candidate.attrib.get("val") for candidate in node.iter() if local_name(candidate.tag) == name), None)
        axes.append({
            "kind": local_name(node.tag),
            "id": value("axId"),
            "crossAxisId": value("crossAx"),
            "position": value("axPos"),
            "minimum": value("min"),
            "maximum": value("max"),
            "rawTree": xml_to_data(node),
        })
    return {
        "part": part,
        "types": chart_types,
        "seriesCount": series_count,
        "series": series,
        "axes": axes,
        "workbook": resolve_relation(relationships_by_source.get(part, {}), relation_id),
        "plotArea": xml_to_data(next((node for node in root.iter() if local_name(node.tag) == "plotArea"), None)),
    }


def theme_fonts(package: zipfile.ZipFile, theme_parts: list[str]) -> list[dict[str, Any]]:
    result = []
    for part in theme_parts:
        root = parse_xml(package, part)
        families = {}
        for family_name in ("majorFont", "minorFont"):
            family = next((node for node in root.iter() if local_name(node.tag) == family_name), None)
            if family is None:
                continue
            families[family_name] = {
                "latin": next((node.attrib.get("typeface") for node in family if local_name(node.tag) == "latin"), None),
                "eastAsian": next((node.attrib.get("typeface") for node in family if local_name(node.tag) == "ea"), None),
                "complexScript": next((node.attrib.get("typeface") for node in family if local_name(node.tag) == "cs"), None),
                "supplemental": [clean_attributes(node) for node in family if local_name(node.tag) == "font"],
            }
        result.append({
            "part": part,
            "families": families,
            "colorScheme": xml_to_data(next((node for node in root.iter() if local_name(node.tag) == "clrScheme"), None)),
            "formatScheme": xml_to_data(next((node for node in root.iter() if local_name(node.tag) == "fmtScheme"), None)),
        })
    return result


def collect_run_fonts(records: list[dict[str, Any]]) -> list[str]:
    fonts: set[str] = set()

    def visit(objects: list[dict[str, Any]]) -> None:
        for obj in objects:
            text = obj.get("text") or {}
            for paragraph in text.get("paragraphs", []):
                for run in paragraph.get("runs", []):
                    properties = run.get("properties") or {}
                    fonts.update(value for key, value in properties.items() if key in {"latin", "ea", "cs"} and value)
            visit(obj.get("children", []))

    for record in records:
        visit(record.get("objects", []))
    return sorted(fonts)


def extract_binary_parts(package: zipfile.ZipFile, output: Path, names: set[str]) -> None:
    for part in sorted(name for name in names if name.startswith(("ppt/media/", "ppt/embeddings/", "ppt/fonts/"))):
        destination = output / PurePosixPath(part)
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(package.read(part))


def presentation_sections(root: ET.Element) -> list[dict[str, Any]]:
    sections = []
    for section in [node for node in root.iter() if local_name(node.tag) == "section"]:
        slide_ids = [integer(node.attrib.get("id")) for node in section.iter() if local_name(node.tag) == "sldId"]
        sections.append({"name": section.attrib.get("name"), "id": section.attrib.get("id"), "slideIds": [value for value in slide_ids if value is not None]})
    return sections


def inspect_pptx(path: Path, media_dir: Path | None, input_id: str) -> tuple[dict[str, Any], dict[str, Any]]:
    losses: list[dict[str, Any]] = []
    media_uses: list[dict[str, Any]] = []
    with zipfile.ZipFile(path) as package:
        names = set(package.namelist())
        if "[Content_Types].xml" not in names or "ppt/presentation.xml" not in names:
            raise ValueError("Файл не похож на PPTX: отсутствуют обязательные части OOXML")
        defaults, overrides = content_type_index(package)
        relationships_by_source, all_relationships = relationship_index(package, names)
        for relation in all_relationships:
            if relation["broken"]:
                losses.append({"severity": "fatal", "part": relation["sourcePart"], "code": "broken-relationship", "detail": relation})

        presentation_root = parse_xml(package, "ppt/presentation.xml")
        presentation_relationships = relationships_by_source.get("ppt/presentation.xml", {})
        slide_size_node = presentation_root.find("p:sldSz", NS)
        slide_size = None if slide_size_node is None else {"cx": integer(slide_size_node.attrib.get("cx")), "cy": integer(slide_size_node.attrib.get("cy")), "type": slide_size_node.attrib.get("type")}
        slide_records = []
        drawing_records = []
        slide_id_nodes = presentation_root.findall("p:sldIdLst/p:sldId", NS)
        for order, slide_id_node in enumerate(slide_id_nodes, start=1):
            relation_id = slide_id_node.attrib.get(f"{{{NS['r']}}}id")
            slide_relation = resolve_relation(presentation_relationships, relation_id)
            if not slide_relation or slide_relation.get("broken"):
                losses.append({"severity": "fatal", "code": "slide-target-missing", "sourceSlide": order, "detail": slide_relation})
                continue
            slide_part = slide_relation["targetPart"]
            drawing = inspect_drawing_part(package, slide_part, relationships_by_source, losses, media_uses)
            drawing_records.append(drawing)
            slide_relationships = relationships_by_source.get(slide_part, {})
            layout_relation = relation_by_type(slide_relationships, "/slideLayout")
            layout_part = None if layout_relation is None else layout_relation["targetPart"]
            layout_relationships = relationships_by_source.get(layout_part or "", {})
            master_relation = relation_by_type(layout_relationships, "/slideMaster")
            master_part = None if master_relation is None else master_relation["targetPart"]
            master_relationships = relationships_by_source.get(master_part or "", {})
            theme_relation = relation_by_type(master_relationships, "/theme")
            notes_relation = relation_by_type(slide_relationships, "/notesSlide")
            comments_relation = next((relation for relation in slide_relationships.values() if "comment" in relation["type"].lower()), None)
            slide_records.append({
                "order": order,
                "id": integer(slide_id_node.attrib.get("id")),
                "relationshipId": relation_id,
                "part": slide_part,
                "hidden": not drawing["show"],
                "layoutPart": layout_part,
                "masterPart": master_part,
                "themePart": None if theme_relation is None else theme_relation["targetPart"],
                "notesPart": None if notes_relation is None else notes_relation["targetPart"],
                "notesText": text_from_part(package, None if notes_relation is None else notes_relation["targetPart"]),
                "commentsPart": None if comments_relation is None else comments_relation["targetPart"],
                "commentsText": text_from_part(package, None if comments_relation is None else comments_relation["targetPart"]),
                "objects": drawing["objects"],
                "placeholders": drawing["placeholders"],
                "transition": drawing["transition"],
                "timingPresent": drawing["timingPresent"],
            })
            if drawing["transition"] is not None:
                losses.append({"severity": "informational", "sourceSlide": order, "part": slide_part, "code": "transition-is-not-static"})
            if drawing["timingPresent"]:
                losses.append({"severity": "informational", "sourceSlide": order, "part": slide_part, "code": "animation-builds-require-separate-audit"})

        layout_parts = sorted(name for name in names if name.startswith("ppt/slideLayouts/slideLayout") and name.endswith(".xml"))
        master_parts = sorted(name for name in names if name.startswith("ppt/slideMasters/slideMaster") and name.endswith(".xml"))
        theme_parts = sorted(name for name in names if name.startswith("ppt/theme/theme") and name.endswith(".xml"))
        layout_records = [inspect_drawing_part(package, part, relationships_by_source, losses, media_uses) for part in layout_parts]
        master_records = [inspect_drawing_part(package, part, relationships_by_source, losses, media_uses) for part in master_parts]
        layouts_by_part = {record["part"]: record for record in layout_records}
        masters_by_part = {record["part"]: record for record in master_records}
        for slide in slide_records:
            layout_placeholders = layouts_by_part.get(slide["layoutPart"], {}).get("placeholders", [])
            master_placeholders = masters_by_part.get(slide["masterPart"], {}).get("placeholders", [])
            inheritance = []
            for placeholder in slide["placeholders"]:
                index = placeholder.get("idx")
                placeholder_type = placeholder.get("type")
                match = lambda candidate: (index is not None and candidate.get("idx") == index) or (index is None and candidate.get("type") == placeholder_type)
                layout_match = next((candidate for candidate in layout_placeholders if match(candidate)), None)
                master_match = next((candidate for candidate in master_placeholders if match(candidate)), None)
                inheritance.append({
                    "slideObjectId": placeholder.get("objectId"),
                    "type": placeholder_type,
                    "idx": index,
                    "layoutPart": slide["layoutPart"],
                    "layoutObjectId": None if layout_match is None else layout_match.get("objectId"),
                    "masterPart": slide["masterPart"],
                    "masterObjectId": None if master_match is None else master_match.get("objectId"),
                })
            slide["placeholderInheritance"] = inheritance
        charts = [inspect_chart(package, part, relationships_by_source) for part in sorted(name for name in names if name.startswith("ppt/charts/") and name.endswith(".xml"))]
        losses.append({
            "severity": "structural",
            "part": "ppt/presentation.xml",
            "code": "effective-style-cascade-not-materialized",
            "detail": "Слои slide/layout/master/theme сохранены отдельно; вычисленные итоговые стили должен подтвердить эталонный рендер",
        })

        package_parts = []
        for part in sorted(name for name in names if not name.endswith("/")):
            payload = package.read(part)
            package_parts.append({
                "path": part,
                "contentType": content_type(part, defaults, overrides),
                "bytes": len(payload),
                "sha256": sha256_bytes(payload),
                "relationships": list(relationships_by_source.get(part, {}).values()),
            })

        if media_dir is not None:
            extract_binary_parts(package, media_dir, names)

        embedded_fonts = [part for part in sorted(names) if part.startswith("ppt/fonts/")]
        all_drawing_records = drawing_records + layout_records + master_records
        structure = {
            "schemaVersion": 1,
            "sourceKind": "pptx",
            "input": {"path": input_id, "bytes": path.stat().st_size, "sha256": sha256_file(path)},
            "presentation": {
                "slideSizeEmu": slide_size,
                "slideCount": len(slide_id_nodes),
                "sections": presentation_sections(presentation_root),
                "slides": slide_records,
            },
            "layouts": layout_records,
            "masters": master_records,
            "themes": theme_fonts(package, theme_parts),
            "charts": charts,
            "mediaUses": media_uses,
            "fonts": {"runTypefaces": collect_run_fonts(all_drawing_records), "embeddedParts": embedded_fonts, "licenseStatus": "unknown" if embedded_fonts else "not-embedded"},
            "packageParts": package_parts,
            "relationships": all_relationships,
            "capabilities": {
                "coordinates": "EMU with composed group matrices",
                "objects": ["shape", "picture", "connector", "group", "table", "chart", "diagram", "ole"],
                "text": ["runs", "paragraphs", "body-properties", "hyperlinks"],
                "media": ["embedded", "linked", "crop", "use-site"],
            },
        }
        loss_manifest = {
            "version": 1,
            "sourceSha256": structure["input"]["sha256"],
            "summary": {severity: sum(1 for loss in losses if loss["severity"] == severity) for severity in ("fatal", "structural", "visual", "informational")},
            "losses": losses,
        }
        return structure, loss_manifest


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Извлечь структуру, связи и объекты PPTX")
    parser.add_argument("pptx", type=Path, help="Исходный файл PPTX")
    parser.add_argument("--output", type=Path, required=True, help="Путь к source-structure.json")
    parser.add_argument("--loss-output", type=Path, required=True, help="Путь к source-losses.json")
    parser.add_argument("--media-dir", type=Path, help="Каталог для медиа, вложений и встроенных шрифтов")
    parser.add_argument("--input-id", help="Переносимый путь входа в каталоге темы; по умолчанию — имя файла")
    parser.add_argument("--allow-fatal", action="store_true", help="Не завершаться ошибкой при фатальных потерях")
    return parser.parse_args()


def main() -> int:
    options = arguments()
    if not options.pptx.is_file():
        print(f"Ошибка: файл не найден: {options.pptx}", file=sys.stderr)
        return 1
    if options.output.resolve() == options.loss_output.resolve():
        print("Ошибка: --output и --loss-output должны различаться", file=sys.stderr)
        return 1
    input_id = options.input_id or options.pptx.name
    if Path(input_id).is_absolute() or ".." in Path(input_id).parts:
        print("Ошибка: --input-id должен быть относительным путём без '..'", file=sys.stderr)
        return 1
    try:
        structure, losses = inspect_pptx(options.pptx, options.media_dir, input_id)
        write_json(options.output, structure)
        write_json(options.loss_output, losses)
    except (OSError, ValueError, zipfile.BadZipFile, ET.ParseError) as error:
        print(f"Ошибка: {error}", file=sys.stderr)
        return 1
    print(
        f"Извлечено слайдов: {structure['presentation']['slideCount']}; "
        f"объектов на слайдах: {sum(len(slide['objects']) for slide in structure['presentation']['slides'])}; "
        f"фатальных потерь: {losses['summary']['fatal']}"
    )
    return 0 if options.allow_fatal or losses["summary"]["fatal"] == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
