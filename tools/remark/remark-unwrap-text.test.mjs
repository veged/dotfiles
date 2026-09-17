import assert from 'node:assert/strict'
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { spawnSync } from 'node:child_process'
import { fileURLToPath } from 'node:url'
import { test } from 'node:test'

import { remark } from 'remark'
import remarkFrontmatter from 'remark-frontmatter'
import remarkGfm from 'remark-gfm'

import remarkUnwrapText from './remark-unwrap-text.mjs'

const settings = { bullet: '+', emphasis: '_', fence: '~' },
  processor = () => remark().use(remarkFrontmatter).use(remarkGfm).data('settings', settings)

for(const [name, source, expected] of [
  ['абзац', 'Начало\nпродолжение.\n', 'Начало продолжение.\n'],
  ['CRLF', 'Начало\r\nпродолжение.\r\n', 'Начало продолжение.\n'],
  ['CR', 'Начало\rпродолжение.\r', 'Начало продолжение.\n'],
  ['пункт списка', '+ Начало\n  продолжение.\n', '+ Начало продолжение.\n'],
  ['цитата', '> Начало\n> продолжение.\n', '> Начало продолжение.\n'],
  ['выделение', '_Начало\nпродолжение_.\n', '_Начало продолжение_.\n'],
  ['текст ссылки', '[Начало\nпродолжение](https://example.com).\n', '[Начало продолжение](https://example.com).\n'],
  ['между элементами', '**Начало**\n`код`\nконец.\n', '**Начало** `код` конец.\n'],
  ['неразрывные пробелы', 'Начало\u00a0слова\nконец\u202fфразы.\n', 'Начало\u00a0слова конец\u202fфразы.\n']
]) {
  test(`Разворачивание и диагностика: ${name}`, async () => {
    const file = await processor().use(remarkUnwrapText).process(source),
      repeated = await processor().use(remarkUnwrapText).process(String(file))

    assert.equal(String(file), expected)
    assert.ok(file.messages.length > 0)
    assert.ok(file.messages.every(message => message.source === 'remark-unwrap-text' && message.line))
    assert.equal(String(repeated), expected)
    assert.equal(repeated.messages.length, 0)
  })
}

for(const [name, source] of [
  ['отдельные абзацы', 'Первый абзац.\n\nВторой абзац.\n'],
  ['структуру списков', '+ Первый пункт.\n+ Второй пункт.\n  + Вложенный пункт.\n'],
  ['явный разрыв через пробелы', 'Начало  \nпродолжение.\n'],
  ['явный разрыв через обратную косую черту', 'Начало\\\nпродолжение.\n'],
  ['явный разрыв внутри выделения', '_Начало\\\nпродолжение_.\n'],
  ['пробелы во встроенном коде', 'Текст `a  b` и ` x `.\n'],
  ['перенос внутри встроенного кода', 'Текст `a\nb`.\n'],
  ['обычные пробелы', 'Первое  второе\tтретье.\n'],
  ['блок кода', '~~~text\na  b\nc\n~~~\n'],
  ['HTML', '<div>\na  b\nc\n</div>\n'],
  ['встроенный HTML', 'Текст <span\nclass="x">слово</span>.\n'],
  ['YAML', '---\ntitle: Заголовок\ntext: |\n  Строка\n  Продолжение\n---\n\nАбзац.\n'],
  ['таблицу', '| А | Б |\n| - | - |\n| 1 | 2 |\n']
]) {
  test(`Сохраняет ${name} и настройки сериализации`, async () => {
    const base = await processor().process(source),
      file = await processor().use(remarkUnwrapText).process(source)

    assert.equal(String(file), String(base))
    assert.equal(file.messages.length, 0)
  })
}

test('CLI проверяет без записи, исправляет файл и принимает результат', t => {
  const directory = mkdtempSync(join(tmpdir(), 'remark-unwrap-text-')),
    path = join(directory, 'example.md'),
    source = 'Начало\nпродолжение.\n',
    cli = fileURLToPath(new URL('./node_modules/remark-cli/cli.js', import.meta.url)),
    config = fileURLToPath(new URL('./remarkrc.json', import.meta.url)),
    run = (...args) => spawnSync(process.execPath, [cli, path, '--rc-path', config, '--quiet', ...args], {
      encoding: 'utf8', timeout: 15000
    })

  t.after(() => rmSync(directory, { recursive: true, force: true }))
  writeFileSync(path, source)

  const check = run('--frail')
  assert.equal(check.status, 1, check.stderr)
  assert.match(check.stderr, /remark-unwrap-text/)
  assert.equal(readFileSync(path, 'utf8'), source)

  const fix = run('--output')
  assert.equal(fix.status, 0, fix.stderr)
  assert.equal(readFileSync(path, 'utf8'), 'Начало продолжение.\n')

  const clean = run('--frail')
  assert.equal(clean.status, 0, clean.stderr)
})
