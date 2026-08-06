#!/usr/bin/env node

import { createHash } from 'node:crypto'
import { existsSync, lstatSync, readFileSync, readdirSync, readlinkSync, realpathSync, statSync, writeFileSync } from 'node:fs'
import { basename, extname, join, relative, resolve, sep } from 'node:path'

const IMAGE_EXTENSIONS = new Set(['.avif', '.gif', '.heic', '.jpeg', '.jpg', '.png', '.svg', '.tif', '.tiff', '.webp'])
const FONT_EXTENSIONS = new Set(['.eot', '.otf', '.ttc', '.ttf', '.woff', '.woff2'])
const DOCUMENT_EXTENSIONS = new Set(['.doc', '.docx', '.md', '.pages', '.rtf', '.txt'])
const PRESENTATION_EXTENSIONS = new Set(['.odp', '.potx', '.ppsx', '.ppt'])

function usage() {
  console.error('Использование: node scripts/inventory-inputs.mjs [--root каталог-темы] [--output файл.json] <путь...>')
}

function parseArguments(argv) {
  const paths = []
  let output = null
  let root = process.cwd()

  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index]
    if (value === '--output') {
      output = argv[index + 1]
      if (!output) throw new Error('После --output нужен путь к JSON-файлу')
      index += 1
    } else if (value === '--root') {
      root = argv[index + 1]
      if (!root) throw new Error('После --root нужен путь к каталогу темы')
      index += 1
    } else if (value === '--help' || value === '-h') {
      usage()
      process.exit(0)
    } else if (value.startsWith('--')) {
      throw new Error(`Неизвестный параметр: ${value}`)
    } else {
      paths.push(value)
    }
  }

  if (paths.length === 0) throw new Error('Укажите хотя бы один входной файл или каталог')
  return { output, paths, root: resolve(root) }
}

function normalizedRelative(root, path) {
  return relative(root, path).split(sep).join('/') || '.'
}

function hashFile(path) {
  const hash = createHash('sha256')
  hash.update(readFileSync(path))
  return hash.digest('hex')
}

function inspectDirectory(root) {
  const aggregate = createHash('sha256')
  let bytes = 0
  let entryCount = 0

  function visit(directory) {
    const names = readdirSync(directory).sort((left, right) => left.localeCompare(right, 'en'))
    if (names.length === 0) {
      aggregate.update(`directory\0${normalizedRelative(root, directory)}\0`)
    }

    for (const name of names) {
      const path = join(directory, name)
      const metadata = lstatSync(path)
      const relativePath = normalizedRelative(root, path)
      entryCount += 1

      if (metadata.isSymbolicLink()) {
        aggregate.update(`symlink\0${relativePath}\0${readlinkSync(path)}\0`)
      } else if (metadata.isDirectory()) {
        aggregate.update(`directory\0${relativePath}\0`)
        visit(path)
      } else if (metadata.isFile()) {
        const digest = hashFile(path)
        bytes += metadata.size
        aggregate.update(`file\0${relativePath}\0${metadata.size}\0${digest}\0`)
      } else {
        aggregate.update(`other\0${relativePath}\0${metadata.mode}\0`)
      }
    }
  }

  visit(root)
  return { bytes, entryCount, sha256: aggregate.digest('hex') }
}

function classify(path, metadata) {
  const extension = extname(path).toLowerCase()
  if (extension === '.key') return metadata.isDirectory() ? 'keynote-package' : 'keynote-file'
  if (metadata.isDirectory()) return 'directory'
  if (extension === '.pptx') return 'pptx'
  if (PRESENTATION_EXTENSIONS.has(extension)) return 'presentation'
  if (extension === '.pdf') return 'pdf'
  if (IMAGE_EXTENSIONS.has(extension)) return 'image'
  if (FONT_EXTENSIONS.has(extension)) return 'font'
  if (DOCUMENT_EXTENSIONS.has(extension)) return 'brand-document'
  return 'other'
}

function portablePath(root, absolutePath) {
  const value = normalizedRelative(root, absolutePath)
  if (value === '..' || value.startsWith('../')) return { path: `external/${basename(absolutePath)}`, external: true }
  return { path: value, external: false }
}

function inspectInput(inputPath, root) {
  const absolutePath = resolve(inputPath)
  const portable = portablePath(root, absolutePath)
  if (!existsSync(absolutePath)) {
    return {
      ...portable,
      name: basename(absolutePath),
      exists: false,
      error: 'Путь не существует',
    }
  }

  const metadata = lstatSync(absolutePath)
  const kind = classify(absolutePath, metadata)
  const extension = extname(absolutePath).toLowerCase() || null

  if (metadata.isDirectory()) {
    const directory = inspectDirectory(absolutePath)
    return {
      ...portable,
      name: basename(absolutePath),
      exists: true,
      kind,
      extension,
      bytes: directory.bytes,
      entryCount: directory.entryCount,
      sha256: directory.sha256,
    }
  }

  if (metadata.isSymbolicLink()) {
    const target = realpathSync(absolutePath)
    const targetMetadata = statSync(target)
    if (!targetMetadata.isFile()) {
      return {
        ...portable,
        name: basename(absolutePath),
        exists: true,
        kind: 'symlink',
        extension,
        target: portablePath(root, target),
        bytes: 0,
        sha256: createHash('sha256').update(readlinkSync(absolutePath)).digest('hex'),
      }
    }
  }

  return {
    ...portable,
    name: basename(absolutePath),
    exists: true,
    kind,
    extension,
    bytes: metadata.size,
    sha256: hashFile(absolutePath),
  }
}

function summarize(inputs) {
  const byKind = {}
  let bytes = 0

  for (const input of inputs) {
    if (!input.exists) continue
    byKind[input.kind] = (byKind[input.kind] ?? 0) + 1
    bytes += input.bytes ?? 0
  }

  return {
    count: inputs.length,
    available: inputs.filter((input) => input.exists).length,
    missing: inputs.filter((input) => !input.exists).length,
    bytes,
    byKind,
  }
}

try {
  const { output, paths, root } = parseArguments(process.argv.slice(2))
  const inputs = [...new Set(paths.map((path) => resolve(path)))]
    .sort((left, right) => left.localeCompare(right, 'en'))
    .map((path) => inspectInput(path, root))
  const inventory = {
    version: 1,
    algorithm: 'sha256',
    inputs,
    totals: summarize(inputs),
  }
  const serialized = `${JSON.stringify(inventory, null, 2)}\n`

  if (output) writeFileSync(resolve(output), serialized)
  else process.stdout.write(serialized)

  if (inventory.totals.missing > 0) {
    console.error(`Не найдены входы: ${inventory.totals.missing}`)
    process.exitCode = 2
  }
} catch (error) {
  console.error(`Ошибка: ${error.message}`)
  usage()
  process.exitCode = 1
}
