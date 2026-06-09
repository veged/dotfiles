#!/usr/bin/env node
// Codex ↔ OpenAI bridge для Fabric.
//
// Поднимает локальный OpenAI-совместимый эндпоинт (/v1/chat/completions, /v1/models)
// и на каждый запрос вызывает `codex exec`, отдавая ответ модели через ChatGPT-подписку.
// Никаких API-ключей: авторизация берётся из твоего залогиненного Codex CLI.
//
// Конфигурация через env:
//   FABRIC_CODEX_BRIDGE_PORT   порт (по умолчанию 8123)
//   FABRIC_CODEX_BRIDGE_HOST   адрес (по умолчанию 127.0.0.1)
//   CODEX_BIN                  путь к codex (по умолчанию "codex" из PATH)
//   CODEX_MODEL                модель по умолчанию (по умолчанию gpt-5.4)
//   CODEX_REASONING_EFFORT     minimal|low|medium|high|xhigh (по умолчанию low)
//   CODEX_TIMEOUT_MS           таймаут одного вызова (по умолчанию 300000)

import http from 'node:http'
import { spawn } from 'node:child_process'
import { mkdtempSync, readFileSync, rmSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'

const PORT = Number(process.env.FABRIC_CODEX_BRIDGE_PORT || 8123)
const HOST = process.env.FABRIC_CODEX_BRIDGE_HOST || '127.0.0.1'
const CODEX = process.env.CODEX_BIN || 'codex'
const DEFAULT_MODEL = process.env.CODEX_MODEL || 'gpt-5.5'
const REASONING = process.env.CODEX_REASONING_EFFORT || 'high'
const TIMEOUT_MS = Number(process.env.CODEX_TIMEOUT_MS || 300000)
const ADVERTISED = ['gpt-5.5', 'gpt-5.4', 'gpt-5.4-codex', 'gpt-5-codex', 'gpt-5']

const textOf = (content) =>
  typeof content === 'string'
    ? content
    : Array.isArray(content)
      ? content.map((p) => p?.text ?? '').join('')
      : ''

// Fabric шлёт pattern как system, вход как user. Codex принимает один промпт —
// плющим: system впереди, остальное по порядку.
const flatten = (messages = []) => {
  const sys = messages.filter((m) => m.role === 'system').map((m) => textOf(m.content))
  const rest = messages.filter((m) => m.role !== 'system').map((m) => textOf(m.content))
  return [...sys, ...rest].filter(Boolean).join('\n\n')
}

const runCodex = (prompt, model) =>
  new Promise((resolve, reject) => {
    const dir = mkdtempSync(join(tmpdir(), 'fabric-codex-'))
    const out = join(dir, 'last.txt')
    const args = [
      'exec',
      '--ephemeral',
      '--skip-git-repo-check',
      '--ignore-user-config',
      '-s', 'read-only',
      '-C', dir,
      '-c', `model_reasoning_effort="${REASONING}"`,
      '-m', model,
      '-o', out,
      '-',
    ]
    const child = spawn(CODEX, args, { stdio: ['pipe', 'ignore', 'pipe'] })
    let stderr = ''
    const timer = setTimeout(() => child.kill('SIGKILL'), TIMEOUT_MS)

    child.stderr.on('data', (d) => (stderr += d))
    child.on('error', (e) => {
      clearTimeout(timer)
      rmSync(dir, { recursive: true, force: true })
      reject(e)
    })
    child.on('close', (code) => {
      clearTimeout(timer)
      let answer = ''
      try {
        answer = readFileSync(out, 'utf8').trim()
      } catch {}
      rmSync(dir, { recursive: true, force: true })
      if (code === 0 && answer) resolve(answer)
      else reject(new Error(`codex exec exit ${code}: ${stderr.slice(-2000) || 'нет ответа'}`))
    })

    child.stdin.write(prompt)
    child.stdin.end()
  })

const readBody = (req) =>
  new Promise((resolve, reject) => {
    let raw = ''
    req.on('data', (c) => (raw += c))
    req.on('end', () => resolve(raw))
    req.on('error', reject)
  })

const completion = (model, text) => ({
  id: `chatcmpl-codex-${Date.now()}`,
  object: 'chat.completion',
  created: Math.floor(Date.now() / 1000),
  model,
  choices: [{ index: 0, message: { role: 'assistant', content: text }, finish_reason: 'stop' }],
  usage: { prompt_tokens: 0, completion_tokens: 0, total_tokens: 0 },
})

const streamChunks = (res, model, text) => {
  const base = { id: `chatcmpl-codex-${Date.now()}`, object: 'chat.completion.chunk', created: Math.floor(Date.now() / 1000), model }
  const send = (choice) => res.write(`data: ${JSON.stringify({ ...base, choices: [choice] })}\n\n`)
  res.writeHead(200, { 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache', Connection: 'keep-alive' })
  send({ index: 0, delta: { role: 'assistant', content: text }, finish_reason: null })
  send({ index: 0, delta: {}, finish_reason: 'stop' })
  res.write('data: [DONE]\n\n')
  res.end()
}

const json = (res, code, obj) => {
  res.writeHead(code, { 'Content-Type': 'application/json' })
  res.end(JSON.stringify(obj))
}

const server = http.createServer(async (req, res) => {
  const path = req.url.split('?')[0]

  if (req.method === 'GET' && path.endsWith('/models')) {
    return json(res, 200, {
      object: 'list',
      data: ADVERTISED.map((id) => ({ id, object: 'model', created: 0, owned_by: 'codex-cli' })),
    })
  }

  if (req.method === 'GET' && (path === '/' || path.endsWith('/health'))) {
    return json(res, 200, { status: 'ok', backend: 'codex exec', model: DEFAULT_MODEL })
  }

  if (req.method === 'POST' && path.endsWith('/chat/completions')) {
    try {
      const body = JSON.parse((await readBody(req)) || '{}')
      const model = body.model || DEFAULT_MODEL
      const prompt = flatten(body.messages)
      if (!prompt) return json(res, 400, { error: { message: 'пустой prompt' } })
      const text = await runCodex(prompt, model)
      return body.stream ? streamChunks(res, model, text) : json(res, 200, completion(model, text))
    } catch (e) {
      return json(res, 500, { error: { message: String(e.message || e), type: 'codex_bridge_error' } })
    }
  }

  json(res, 404, { error: { message: `неизвестный маршрут ${req.method} ${path}` } })
})

server.listen(PORT, HOST, () => {
  console.log(`fabric codex-bridge: http://${HOST}:${PORT}/v1  →  ${CODEX} exec (model=${DEFAULT_MODEL}, reasoning=${REASONING})`)
})
