#!/usr/bin/env node

import { createHash } from 'node:crypto'
import { existsSync, lstatSync, readFileSync, readdirSync, readlinkSync, statSync } from 'node:fs'
import { basename, join, relative, resolve, sep } from 'node:path'

function usage() {
  console.error('Использование: node scripts/check-theme-contract.mjs [--template-mode] <каталог-темы>')
}

function parseArguments(argv) {
  let templateMode = false
  const paths = []
  for (const value of argv) {
    if (value === '--template-mode') templateMode = true
    else if (value === '--help' || value === '-h') {
      usage()
      process.exit(0)
    } else if (value.startsWith('--')) throw new Error(`Неизвестный параметр: ${value}`)
    else paths.push(value)
  }
  if (paths.length !== 1) throw new Error('Нужен ровно один каталог темы')
  return { root: resolve(paths[0]), templateMode }
}

function readJson(path, failures, label) {
  if (!existsSync(path)) {
    failures.push(`${label}: файл отсутствует`)
    return null
  }
  try {
    return JSON.parse(readFileSync(path, 'utf8'))
  } catch (error) {
    failures.push(`${label}: некорректный JSON (${error.message})`)
    return null
  }
}

function sha256File(path) {
  return createHash('sha256').update(readFileSync(path)).digest('hex')
}

function normalizedRelative(root, path) {
  return relative(root, path).split(sep).join('/') || '.'
}

function hashPath(path) {
  const metadata = lstatSync(path)
  if (metadata.isFile()) return sha256File(path)
  if (!metadata.isDirectory()) return createHash('sha256').update(readlinkSync(path)).digest('hex')
  const aggregate = createHash('sha256')
  function visit(directory) {
    const names = readdirSync(directory).sort((left, right) => left.localeCompare(right, 'en'))
    if (names.length === 0) aggregate.update(`directory\0${normalizedRelative(path, directory)}\0`)
    for (const name of names) {
      const item = join(directory, name)
      const itemMetadata = lstatSync(item)
      const relativePath = normalizedRelative(path, item)
      if (itemMetadata.isSymbolicLink()) aggregate.update(`symlink\0${relativePath}\0${readlinkSync(item)}\0`)
      else if (itemMetadata.isDirectory()) {
        aggregate.update(`directory\0${relativePath}\0`)
        visit(item)
      } else if (itemMetadata.isFile()) {
        const digest = sha256File(item)
        aggregate.update(`file\0${relativePath}\0${itemMetadata.size}\0${digest}\0`)
      } else aggregate.update(`other\0${relativePath}\0${itemMetadata.mode}\0`)
    }
  }
  visit(path)
  return aggregate.digest('hex')
}

function isPortablePath(value) {
  return typeof value === 'string' && value !== '' && !value.startsWith('/') && !value.split('/').includes('..') && !/^[a-zA-Z]:[\\/]/.test(value)
}

function checkHashMap(root, value, label, failures) {
  if (!value || Array.isArray(value) || typeof value !== 'object' || Object.keys(value).length === 0) {
    failures.push(`${label}: нужна непустая таблица «относительный путь → SHA-256»`)
    return
  }
  for (const [relativePath, expected] of Object.entries(value)) {
    if (!isPortablePath(relativePath)) {
      failures.push(`${label}.${relativePath}: путь должен быть переносимым и относительным`)
      continue
    }
    if (typeof expected !== 'string' || !/^[a-f0-9]{64}$/.test(expected)) {
      failures.push(`${label}.${relativePath}: некорректный SHA-256`)
      continue
    }
    const path = join(root, relativePath)
    if (!existsSync(path)) failures.push(`${label}.${relativePath}: файл или каталог отсутствует`)
    else if (hashPath(path) !== expected) failures.push(`${label}.${relativePath}: SHA-256 не совпадает с содержимым`)
  }
}

function walkFiles(root) {
  if (!existsSync(root)) return []
  const result = []
  function visit(directory) {
    for (const name of readdirSync(directory).sort()) {
      const path = join(directory, name)
      if (statSync(path).isDirectory()) visit(path)
      else result.push(path)
    }
  }
  visit(root)
  return result
}

function positivePackageFiles(files) {
  return Array.isArray(files)
    ? files.filter((value) => typeof value === 'string' && !value.startsWith('!'))
    : []
}

function packageCovers(files, requiredPath) {
  return positivePackageFiles(files).some((entry) => {
    const normalized = entry.replace(/^\.\//, '').replace(/\/$/, '')
    return normalized === requiredPath || requiredPath.startsWith(`${normalized}/`)
  })
}

function packageExcludes(files, requiredPath) {
  return Array.isArray(files) && files.some((entry) => {
    if (typeof entry !== 'string' || !entry.startsWith('!')) return false
    return entry.slice(1).replace(/^\.\//, '') === requiredPath
  })
}

function requirePath(root, relativePath, failures, kind = null) {
  const path = join(root, relativePath)
  if (!existsSync(path)) {
    failures.push(`${relativePath}: путь отсутствует`)
    return
  }
  if (kind === 'file' && !statSync(path).isFile()) failures.push(`${relativePath}: ожидался файл`)
  if (kind === 'directory' && !statSync(path).isDirectory()) failures.push(`${relativePath}: ожидался каталог`)
}

function requireScripts(packageJson, scripts, failures, mode) {
  for (const script of scripts) {
    const command = packageJson?.scripts?.[script]
    if (typeof command !== 'string') {
      failures.push(`package.json.scripts.${script}: команда отсутствует (${mode})`)
    } else if (
      command.trim() === ''
      || /(?:^|[;&|])\s*(?:true|:|exit\s+0|echo(?:\s+[^;&|]*)?)\s*(?=$|[;&|])/i.test(command)
      || /(?:^|[;&|])\s*(?:node|python3?)\b[^;&|]*?\s(?:-e|--eval|-p|--print)(?==|\s|['"]|$)/i.test(command)
      || /(?:^|[;&|])\s*(?:bash|zsh|sh)\b[^;&|]*?\s(?:-[a-z]*c|--command)(?==|\s|['"]|$)/i.test(command)
    ) {
      failures.push(`package.json.scripts.${script}: команда-заглушка недопустима (${mode})`)
    }
  }
}

function requireReferencedFiles(root, packageJson, scripts, failures) {
  const pattern = /(?:^|\s)(?:node|python3?|bash|zsh)\s+([^\s;&|]+)/g
  for (const script of scripts) {
    const command = packageJson?.scripts?.[script]
    if (typeof command !== 'string') continue
    for (const match of command.matchAll(pattern)) {
      const reference = match[1].replace(/^['"]|['"]$/g, '')
      if (reference.startsWith('-') || (!reference.includes('/') && !/\.(?:[cm]?js|py|sh)$/.test(reference))) continue
      if (!isPortablePath(reference) || !existsSync(join(root, reference))) {
        failures.push(`package.json.scripts.${script}: файл команды отсутствует или путь непереносим (${reference})`)
      }
    }
  }
}

function referencedScripts(command) {
  const result = []
  const pattern = /(?:npm|pnpm)\s+run\s+([a-zA-Z0-9:_-]+)|yarn\s+([a-zA-Z0-9:_-]+)/g
  for (const match of command.matchAll(pattern)) result.push(match[1] ?? match[2])
  return result
}

function reachesScript(packageJson, start, target, visited = new Set()) {
  if (start === target) return true
  if (visited.has(start)) return false
  visited.add(start)
  const command = packageJson?.scripts?.[start]
  if (typeof command !== 'string') return false
  return referencedScripts(command).some((next) => reachesScript(packageJson, next, target, visited))
}

function requireTestCoverage(packageJson, scripts, failures, mode) {
  for (const script of scripts) {
    if (!reachesScript(packageJson, 'test', script)) failures.push(`package.json.scripts.test: не запускает ${script} (${mode})`)
  }
}

function checkCore(root, packageJson, failures) {
  if (typeof packageJson?.name !== 'string' || !/^(?:@[^/]+\/)?slidev-theme-[a-z0-9-]+$/.test(packageJson.name)) {
    failures.push('package.json.name: ожидается имя slidev-theme-* или @scope/slidev-theme-*')
  }
  const defaults = packageJson?.slidev?.defaults
  if (!Number.isFinite(defaults?.canvasWidth)) failures.push('package.json.slidev.defaults.canvasWidth: нужно число')
  if (typeof defaults?.aspectRatio !== 'string') failures.push('package.json.slidev.defaults.aspectRatio: значение отсутствует')

  requireScripts(packageJson, [
    'build', 'typecheck', 'validate', 'tokens:build', 'tokens:check',
    'check:render', 'check:pixels', 'check:package-assets', 'check:consumer', 'test',
  ], failures, 'базовый режим')
  requireReferencedFiles(root, packageJson, Object.keys(packageJson?.scripts ?? {}), failures)
  requireTestCoverage(packageJson, [
    'tokens:check', 'validate', 'typecheck', 'build', 'check:render',
    'check:pixels', 'check:package-assets', 'check:consumer',
  ], failures, 'базовый режим')

  if (!Array.isArray(packageJson?.files)) {
    failures.push('package.json.files: нужен явный разрешённый список npm-пакета')
  } else {
    for (const path of ['components', 'layouts', 'styles', 'tokens', 'skills', 'example.md', 'README.md']) {
      if (!packageCovers(packageJson.files, path)) failures.push(`package.json.files: не публикует ${path}`)
    }
    for (const entry of positivePackageFiles(packageJson.files)) {
      if (/^(reference|template(?:\.|\/)|.*\.(?:key|pptx)$)/i.test(entry)) {
        failures.push(`package.json.files: внутренний источник не должен публиковаться (${entry})`)
      }
    }
  }

  for (const path of ['components', 'layouts', 'styles', 'tokens', 'scripts', 'tests', 'skills']) {
    requirePath(root, path, failures, 'directory')
  }
  for (const path of [
    'README.md', 'example.md', 'styles/index.css',
    'tokens/primitives.json', 'tokens/semantics.json', 'tokens/components.json',
  ]) requirePath(root, path, failures, 'file')

  const layouts = walkFiles(join(root, 'layouts')).filter((path) => path.endsWith('.vue'))
  if (layouts.length === 0) failures.push('layouts: не найдено ни одного Vue-макета')
  const authorSkills = walkFiles(join(root, 'skills')).filter((path) => path.endsWith('/SKILL.md'))
  if (authorSkills.length === 0) failures.push('skills: не найден авторский SKILL.md')

  const examplePath = join(root, 'example.md')
  if (existsSync(examplePath)) {
    const example = readFileSync(examplePath, 'utf8')
    const demonstrated = new Set([...example.matchAll(/^layout:\s*['"]?([^\s#'"]+)/gm)].map((match) => match[1]))
    const publicLayouts = layouts
      .map((path) => basename(path, '.vue'))
      .filter((name) => !name.startsWith('_') && !packageExcludes(packageJson.files, `layouts/${name}.vue`))
    for (const layout of publicLayouts) {
      if (!demonstrated.has(layout)) failures.push(`example.md: публичный макет ${layout} не показан в галерее`)
    }
  }
  const readmePath = join(root, 'README.md')
  if (existsSync(readmePath) && !/layout/i.test(readFileSync(readmePath, 'utf8'))) {
    failures.push('README.md: не найдено описание макетов')
  }
}

function checkSourceStructure(structure, inputByPath, failures) {
  if (!structure) return { slideCount: 0, sourceSlides: new Set() }
  if (structure.schemaVersion !== 1) {
    failures.push('reference/source-structure.json: ожидается schemaVersion 1')
    return { slideCount: 0, sourceSlides: new Set() }
  }
  if (typeof structure?.input?.sha256 !== 'string' || !/^[a-f0-9]{64}$/.test(structure.input.sha256)) {
    failures.push('reference/source-structure.json: отсутствует SHA-256 входа')
  }
  if (!isPortablePath(structure?.input?.path)) {
    failures.push('reference/source-structure.json: input.path должен быть переносимым относительным путём')
  } else if (inputByPath.get(structure.input.path)?.sha256 !== structure.input.sha256) {
    failures.push('reference/source-structure.json: input.path и SHA-256 не совпадают с source-inputs.json')
  }
  const slides = structure?.presentation?.slides
  const slideCount = structure?.presentation?.slideCount
  if (!Array.isArray(slides) || !Number.isInteger(slideCount)) {
    failures.push('reference/source-structure.json: отсутствуют presentation.slideCount и slides')
    return { slideCount: 0, sourceSlides: new Set() }
  }
  if (slides.length !== slideCount) failures.push('reference/source-structure.json: число записей slides не равно slideCount')
  const sourceSlides = new Set()
  for (const [index, slide] of slides.entries()) {
    if (!Number.isInteger(slide?.order) || slide.order < 1 || sourceSlides.has(slide.order)) {
      failures.push(`source-structure slides[${index}].order: номер отсутствует или повторяется`)
    } else sourceSlides.add(slide.order)
    if (typeof slide?.part !== 'string') failures.push(`source-structure slides[${index}].part: путь отсутствует`)
  }
  return { slideCount, sourceSlides }
}

function checkSourceMap(sourceMap, structureInfo, failures) {
  if (!sourceMap) return null
  if (sourceMap.version !== 1 || !Array.isArray(sourceMap.mappings) || !Array.isArray(sourceMap.exclusions)) {
    failures.push('reference/source-map.json: ожидаются version, mappings и exclusions')
    return null
  }
  if (sourceMap.sourceSlides !== structureInfo.slideCount) {
    failures.push('reference/source-map.json: sourceSlides не равно числу слайдов структуры')
  }
  const covered = new Set()
  const fixtures = new Set()
  const mappedPairs = new Map()
  for (const [index, mapping] of sourceMap.mappings.entries()) {
    if (!Number.isInteger(mapping?.sourceSlide) || covered.has(mapping.sourceSlide)) {
      failures.push(`source-map mappings[${index}].sourceSlide: номер отсутствует или повторяется`)
      continue
    }
    if (!Number.isInteger(mapping?.fixtureSlide) || fixtures.has(mapping.fixtureSlide)) {
      failures.push(`source-map mappings[${index}].fixtureSlide: номер отсутствует или повторяется`)
      continue
    }
    covered.add(mapping.sourceSlide)
    fixtures.add(mapping.fixtureSlide)
    mappedPairs.set(mapping.sourceSlide, mapping.fixtureSlide)
  }
  for (const [index, exclusion] of sourceMap.exclusions.entries()) {
    if (!Number.isInteger(exclusion?.sourceSlide) || covered.has(exclusion.sourceSlide)) {
      failures.push(`source-map exclusions[${index}].sourceSlide: номер отсутствует или повторяется`)
      continue
    }
    covered.add(exclusion.sourceSlide)
    if (typeof exclusion.reason !== 'string' || exclusion.reason.trim() === '') failures.push(`source-map exclusions[${index}].reason: причина отсутствует`)
    if (exclusion.approved !== true) failures.push(`source-map exclusions[${index}].approved: исключение не подтверждено`)
  }
  for (const slide of structureInfo.sourceSlides) {
    if (!covered.has(slide)) failures.push(`reference/source-map.json: исходный слайд ${slide} не учтён`)
  }
  for (const slide of covered) {
    if (!structureInfo.sourceSlides.has(slide)) failures.push(`reference/source-map.json: неизвестный исходный слайд ${slide}`)
  }
  return mappedPairs
}

function checkMetrics(metrics, mappedPairs, failures) {
  if (!Array.isArray(metrics)) {
    failures.push('reference/fidelity-diff/metrics.json: ожидается массив')
    return
  }
  const measured = new Set()
  for (const [index, metric] of metrics.entries()) {
    const label = `metrics[${index}]`
    if (!Number.isInteger(metric?.sourceSlide) || measured.has(metric.sourceSlide)) {
      failures.push(`${label}.sourceSlide: номер отсутствует или повторяется`)
      continue
    }
    measured.add(metric.sourceSlide)
    if (mappedPairs && mappedPairs.get(metric.sourceSlide) !== metric.fixtureSlide) failures.push(`${label}: пара не совпадает с source-map.json`)
    if (!Array.isArray(metric.bestShift) || metric.bestShift[0] !== 0 || metric.bestShift[1] !== 0) failures.push(`${label}.bestShift: нужен глобальный сдвиг [0, 0]`)
    if (metric.localCoverageOk !== true) failures.push(`${label}.localCoverageOk: локальные области покрыты не полностью`)
    if (metric.localGeometryOk !== true) failures.push(`${label}.localGeometryOk: локальная геометрия не прошла`)
    if (metric.normalizationOk !== true) failures.push(`${label}.normalizationOk: нормализации не подтверждены`)
    if (metric.geometryOk !== true) failures.push(`${label}.geometryOk: итоговая геометрия не прошла`)
    for (const field of ['edgeF1At2', 'maePct', 'changedPct', 'localShiftMaxPx']) {
      if (!Number.isFinite(metric[field])) failures.push(`${label}.${field}: нужна числовая метрика`)
    }
    if (Number.isFinite(metric.edgeF1At2) && (metric.edgeF1At2 < 0.95 || metric.edgeF1At2 > 1)) failures.push(`${label}.edgeF1At2: ожидается значение от 0,95 до 1`)
    if (Number.isFinite(metric.maePct) && (metric.maePct < 0 || metric.maePct > 5)) failures.push(`${label}.maePct: значение должно быть от 0 до 5`)
    if (Number.isFinite(metric.changedPct) && (metric.changedPct < 0 || metric.changedPct > 15)) failures.push(`${label}.changedPct: значение должно быть от 0 до 15`)
    if (Number.isFinite(metric.localShiftMaxPx) && (metric.localShiftMaxPx < 0 || metric.localShiftMaxPx > 2)) failures.push(`${label}.localShiftMaxPx: локальный сдвиг должен быть не больше 2 px`)
  }
  if (mappedPairs) {
    for (const sourceSlide of mappedPairs.keys()) {
      if (!measured.has(sourceSlide)) failures.push(`metrics: нет измерений для исходного слайда ${sourceSlide}`)
    }
    if (measured.size !== mappedPairs.size) failures.push('metrics: число измерений не равно числу отображённых слайдов')
  }
}

function recordCount(value) {
  if (Array.isArray(value)) return value.length
  if (value && typeof value === 'object') return Object.keys(value).length
  return 0
}

function checkTemplateMode(root, packageJson, failures) {
  requireScripts(packageJson, [
    'source:inspect', 'source:build', 'source:render', 'fidelity:verify', 'fidelity:provenance',
  ], failures, 'режим шаблона')
  requireTestCoverage(packageJson, ['fidelity:verify', 'fidelity:provenance'], failures, 'режим шаблона')
  for (const script of ['source:inspect', 'source:build', 'source:render']) {
    if (!reachesScript(packageJson, 'fidelity:verify', script)) failures.push(`package.json.scripts.fidelity:verify: не запускает ${script}`)
  }
  for (const path of [
    'reference/template-audit.md', 'reference/source-fixture.md',
    'reference/fidelity-diff/report.md', 'reference/fidelity-diff/overview-all.png',
  ]) requirePath(root, path, failures, 'file')

  const inputs = readJson(join(root, 'reference/source-inputs.json'), failures, 'reference/source-inputs.json')
  const inputByPath = new Map()
  if (inputs && (inputs.algorithm !== 'sha256' || inputs?.totals?.missing !== 0 || !Array.isArray(inputs.inputs) || inputs.inputs.length === 0)) {
    failures.push('reference/source-inputs.json: опись входов неполна или пуста')
  } else if (inputs) {
    for (const [index, input] of inputs.inputs.entries()) {
      const label = `source-inputs inputs[${index}]`
      if (input?.exists !== true) failures.push(`${label}.exists: вход недоступен`)
      if (input?.external === true) failures.push(`${label}.external: внешний путь непереносим; скопируйте источник в reference/sources`)
      if (!isPortablePath(input?.path)) {
        failures.push(`${label}.path: нужен переносимый относительный путь`)
        continue
      }
      if (inputByPath.has(input.path)) failures.push(`${label}.path: путь повторяется`)
      inputByPath.set(input.path, input)
      const actualPath = join(root, input.path)
      if (!existsSync(actualPath)) failures.push(`${label}.path: вход отсутствует в каталоге темы`)
      else if (typeof input.sha256 !== 'string' || hashPath(actualPath) !== input.sha256) failures.push(`${label}.sha256: хеш не совпадает с текущим входом`)
    }
  }
  const structure = readJson(join(root, 'reference/source-structure.json'), failures, 'reference/source-structure.json')
  const structureInfo = checkSourceStructure(structure, inputByPath, failures)
  const losses = readJson(join(root, 'reference/source-losses.json'), failures, 'reference/source-losses.json')
  if (losses && (losses.version !== 1 || !Array.isArray(losses.losses) || losses?.summary?.fatal !== 0)) {
    failures.push('reference/source-losses.json: схема неверна или остались фатальные потери')
  }
  const sourceMap = readJson(join(root, 'reference/source-map.json'), failures, 'reference/source-map.json')
  const mappedPairs = checkSourceMap(sourceMap, structureInfo, failures)
  const normalizations = readJson(join(root, 'reference/source-normalizations.json'), failures, 'reference/source-normalizations.json')
  if (normalizations && (typeof normalizations.version !== 'number' || !Array.isArray(normalizations.groups))) {
    failures.push('reference/source-normalizations.json: ожидаются version и groups')
  }
  const environment = readJson(join(root, 'reference/render-environment.json'), failures, 'reference/render-environment.json')
  if (environment) {
    if (typeof environment?.renderer?.name !== 'string' || typeof environment?.renderer?.version !== 'string' || !Number.isFinite(environment?.renderer?.dpr)) {
      failures.push('reference/render-environment.json: не зафиксированы движок, версия и DPR')
    }
    if (!Number.isFinite(environment?.viewport?.width) || !Number.isFinite(environment?.viewport?.height)) failures.push('reference/render-environment.json: не зафиксирован viewport')
    if (typeof environment?.colorProfile !== 'string' || environment.colorProfile.trim() === '') failures.push('reference/render-environment.json: не зафиксирован цветовой профиль')
    if (!Array.isArray(environment?.fonts) || environment.fonts.length === 0) failures.push('reference/render-environment.json: не зафиксированы гарнитуры')
    else for (const [index, font] of environment.fonts.entries()) {
      if (typeof font?.family !== 'string' || typeof font?.sha256 !== 'string' || !/^[a-f0-9]{64}$/.test(font.sha256)) failures.push(`render-environment fonts[${index}]: нужны family и SHA-256`)
      if (font?.path !== undefined) {
        if (!isPortablePath(font.path) || !existsSync(join(root, font.path))) failures.push(`render-environment fonts[${index}].path: файл отсутствует или путь непереносим`)
        else if (sha256File(join(root, font.path)) !== font.sha256) failures.push(`render-environment fonts[${index}].sha256: хеш файла не совпадает`)
      }
    }
  }
  const metrics = readJson(join(root, 'reference/fidelity-diff/metrics.json'), failures, 'reference/fidelity-diff/metrics.json')
  checkMetrics(metrics, mappedPairs, failures)
  const provenance = readJson(join(root, 'reference/fidelity-diff/input-hashes.json'), failures, 'reference/fidelity-diff/input-hashes.json')
  if (provenance) {
    if (provenance.algorithm !== 'sha256' || recordCount(provenance.trackedInputs) === 0) {
      failures.push('reference/fidelity-diff/input-hashes.json: нужна привязка SHA-256 с trackedInputs')
    }
    checkHashMap(root, provenance.trackedInputs, 'input-hashes trackedInputs', failures)
    for (const required of [
      'reference/source-inputs.json', 'reference/source-structure.json', 'reference/source-losses.json',
      'reference/source-map.json', 'reference/source-normalizations.json', 'reference/render-environment.json',
    ]) {
      if (!Object.hasOwn(provenance.trackedInputs ?? {}, required)) failures.push(`input-hashes trackedInputs: не привязан ${required}`)
    }
    const sourceRenders = provenance.sourceRenders
    const targetRenders = provenance.targetRenders ?? provenance.slidevRenders
    checkHashMap(root, sourceRenders, 'input-hashes sourceRenders', failures)
    checkHashMap(root, targetRenders, 'input-hashes targetRenders', failures)
    if (recordCount(sourceRenders) === 0 || recordCount(targetRenders) === 0) {
      failures.push('input-hashes: нужны отдельные хеши исходных и целевых изображений')
    } else if (mappedPairs && (recordCount(sourceRenders) !== mappedPairs.size || recordCount(targetRenders) !== mappedPairs.size)) {
      failures.push('input-hashes: число хешей изображений не равно числу отображённых слайдов')
    }
  }

  const fixturePath = join(root, 'reference/source-fixture.md')
  if (existsSync(fixturePath)) {
    const fixture = readFileSync(fixturePath, 'utf8')
    const layouts = [...fixture.matchAll(/^layout:\s*['"]?([^\s#'"]+)/gm)].map((match) => match[1])
    if (layouts.length === 0) failures.push('reference/source-fixture.md: не найдено ни одного layout')
    for (const layout of new Set(layouts)) {
      if (!existsSync(join(root, 'layouts', `${layout}.vue`))) failures.push(`reference/source-fixture.md: layout ${layout} отсутствует в layouts/`)
    }
  }
}

try {
  const { root, templateMode } = parseArguments(process.argv.slice(2))
  if (!existsSync(root) || !statSync(root).isDirectory()) throw new Error(`Каталог не существует: ${root}`)
  const failures = []
  const packageJson = readJson(join(root, 'package.json'), failures, 'package.json')
  if (packageJson) checkCore(root, packageJson, failures)
  if (templateMode && packageJson) checkTemplateMode(root, packageJson, failures)
  if (failures.length > 0) {
    console.error(`Контракт темы не пройден: ${failures.length}`)
    for (const failure of failures) console.error(`- ${failure}`)
    process.exitCode = 1
  } else console.log(`Контракт темы пройден (${templateMode ? 'режим шаблона' : 'базовый режим'}): ${root}`)
} catch (error) {
  console.error(`Ошибка: ${error.message}`)
  usage()
  process.exitCode = 1
}
