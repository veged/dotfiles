# Правила кодирования JavaScript

## Философия

- **Лаконичность** — избегать избыточных переменных и функций, используемых один раз
- **Без дублирования** — код, повторяющийся 2+ раза, генерализовать или выносить в функции
- **Производительность** — эффективные алгоритмы и структуры данных
- **Прагматизм** — выбирать подход в зависимости от задачи
- **Привычка > сложность** — лаконичный код предпочтительнее

## Стиль кодирования

### Форматирование
- Отступы: 2 пробела
- Точки с запятой: никогда
- Кавычки: одинарные
- Длина строки: ~120 символов (не строго)

### Декларация переменных
**Минимализм**: одно ключевое слово `const`/`let` для множественных деклараций через запятую

```javascript
// ✅ Правильно — одно const
const userName = user?.profile?.name ?? 'Аноним',
  updatedUser = { ...user, lastLogin: Date.now() },
  { id, ...userData } = user,
  greeting = `Привет, ${userName}!`

// ❌ Неправильно — множественные const
const userName = user?.profile?.name ?? 'Аноним'
const updatedUser = { ...user, lastLogin: Date.now() }
const { id, ...userData } = user
const greeting = `Привет, ${userName}!`
```

### Условия
**Минимализм**: использовать логические операторы вместо `if` для простых условий

```javascript
// ✅ Правильно — лаконичные условия
cond && action()
!cond && action()
hasAccess || redirectToLogin()

// ❌ Неправильно — избыточный if
if(cond) action()
if(!cond) action()
if(!hasAccess) redirectToLogin()

// ✅ Сложные условия — if допустим
if(user.isActive && user.isPremium && hasAccess) {
  grantFullAccess()
  logEvent('premium_access')
  notifyAdmin()
}

// ✅ Цепочки условий
isValid && save() || showError()
```

### Именование
- **Переменные, функции**: camelCase
- **Классы, типы**: PascalCase
- **Константы**: camelCase (не UPPER_CASE)
- **Короткие функции**: однобуквенные имена допустимы (`x`, `i`)
- **Средние функции**: сокращения допустимы (`ctx`, `arr`, `idx`)
- Без префиксов типов (`strName`, `arrUsers`)

### Комментарии
- Язык: русский
- JSDoc для публичных API и сложных функций
- Простые функции без комментариев

```javascript
// ✅ Сложная функция
/**
 * Обрабатывает данные с фильтрацией и сортировкой
 * @param {Array} users - Массив пользователей
 * @param {Object} options - Опции обработки
 * @param {Function} options.filter - Функция фильтрации
 * @param {Function} options.sort - Функция сортировки
 * @returns {Array} Обработанный массив пользователей
 */
function processUsers(users, { filter, sort }) {
  return users.filter(filter).sort(sort)
}

// ✅ Простая функция без комментариев
function sum(a, b) {
  return a + b
}
```

## Архитектура

### Парадигма
- Функциональный подход по умолчанию
- ООП/классы для сложных предметных областей
- Мутации допустимы для оптимизации
- Иммутабельность когда это имеет смысл

```javascript
// ✅ Функциональный для простых задач
const doubleNumbers = nums => nums.map(n => n * 2)

// ✅ Класс для сложной предметной области
class OrderProcessingPipeline {
  constructor(config) {
    this.validators = config.validators
    this.processors = config.processors
  }

  process(order) {
    // сложная логика обработки
  }
}

// ✅ Мутация для производительности
function updateCache(cache, key, value) {
  cache[key] = value
  return cache
}
```

### Функции
- Разумное количество параметров (обычно до 3-4, но не строго)
- Деструктуризация активно
- Default параметры использовать
- Стрелочные функции для коротких инлайновых колбэков
- Function declarations для сложных именованных функций

```javascript
// ✅ Деструктуризация + defaults
function createUser({ name, email, role = 'user' }) {
  return { name, email, role, createdAt: Date.now() }
}

// ✅ Стрелочные для колбэков
const activeUsers = users.filter(u => u.isActive)

// ✅ Declaration для сложной логики
function processPayment(order, paymentMethod) {
  validateOrder(order)
  calculateTotal(order)
  chargePayment(paymentMethod)
}
```

### Обработка ошибок
- Синхронно: предпочтительно `try/catch`
- Асинхронно: `.catch()` или возвращаемые Error объекты
- Promise chains: использовать `.catch()` для обработки
- Кастомные классы ошибок при необходимости

```javascript
// ✅ Синхронная обработка
function parseJSON(str) {
  try {
    return JSON.parse(str)
  } catch (err) {
    console.error('Ошибка парсинга:', err)
    return null
  }
}

// ✅ Асинхронная обработка
function fetchData(url) {
  return fetch(url)
    .then(res => res.json())
    .catch(err => {
      console.error('Ошибка загрузки:', err)
      return null
    })
}

// ✅ Кастомная ошибка
class ValidationError extends Error {
  constructor(message, field) {
    super(message)
    this.name = 'ValidationError'
    this.field = field
  }
}
```

## Современный JavaScript (ES6+)

Активно использовать:
- async/await и Promise chains (по ситуации)
- Optional chaining (`?.`)
- Nullish coalescing (`??`)
- Spread/rest (`...`)
- Destructuring
- Template literals
- Arrow functions

```javascript
const userName = user?.profile?.name ?? 'Аноним',
  updatedUser = { ...user, lastLogin: Date.now() },
  { id, ...userData } = user,
  greeting = `Привет, ${userName}!`
```

### Циклы и итерация

**`for..of`** — основной цикл для массивов, Map, Set и любых итерируемых объектов.
**`for..in`** — не использовать (проблемы с прототипной цепочкой, нужен `hasOwnProperty`).

```javascript
// ❌ Индексный цикл
for(let i = 0; i < items.length; i++) {
  process(items[i])
}

// ❌ while с инкрементом
let i = 0
while(item = items[i++]) {
  process(item)
}

// ✅ for..of
for(const item of items)
  process(item)
```

**Итерация по объектам**: `Object.entries`/`Object.keys`/`Object.values` + `for..of` вместо `for..in` + `hasOwnProperty`

```javascript
// ❌ for..in + hasOwnProperty
for(const key in obj) {
  if(Object.hasOwn(obj, key)) {
    fn(obj[key], key)
  }
}

// ❌ for..in + hasOwnProperty (старый стиль)
const hasOwn = Object.prototype.hasOwnProperty
for(const key in obj) {
  if(hasOwn.call(obj, key)) {
    fn(obj[key], key)
  }
}

// ✅ Object.entries + for..of
for(const [key, val] of Object.entries(obj))
  fn(val, key)

// ✅ Object.keys / Object.values когда нужно что-то одно
for(const key of Object.keys(obj))
  fn(key)

for(const val of Object.values(obj))
  fn(val)
```

**Map вместо объектов для внутренних хранилищ**: убирает необходимость в `hasOwnProperty` полностью

```javascript
// ❌ Объект как хранилище — нужен hasOwnProperty при итерации
const storage = {}
storage[id] = value
for(const key in storage) {
  if(Object.hasOwn(storage, key)) { ... }
}

// ✅ Map — нет проблем с прототипной цепочкой
const storage = new Map()
storage.set(id, value)
for(const [key, val] of storage)
  process(key, val)
```

**Итерация по Map/Set**:

```javascript
// ✅ Map
for(const [key, val] of myMap)
  process(key, val)

// ✅ Set
for(const item of mySet)
  process(item)
```

### Модули
- ESM (`import`/`export`)
- Порядок импортов:
  1. Стандартные модули Node.js
  2. Сторонние пакеты
  3. Собственные модули
- Default exports для простых модулей
- Named exports для модулей с несколькими экспортами

```javascript
// ✅ Порядок импортов
import fs from 'fs'
import path from 'path'

import React from 'react'
import axios from 'axios'

import { processData } from './utils'
import { UserService } from './services'
```

## Производительность

### Выбор структур данных

**Анти-паттерн: массив + фуллскан**

Статические массивы для проверки вхождения/поиска — неэффективно. Используй Set/Map/RegExp.

```javascript
// ❌ Массив + some/includes — O(n)
const errors = ['error', 'Error', 'failed'],
  hasError = str => errors.some(e => str.includes(e))

// ❌ Массив + includes — O(n)
const flags = ['--out', '--port']
flags.includes(flag) && processFlag(flag)

// ❌ Массив + find — O(n)
const configs = [{ key: 'prod', url: '...' }],
  config = configs.find(c => c.key === env)?.url
```

**Правильно: Set/Map/RegExp — O(1) или лучше**

```javascript
// ✅ RegExp для поиска подстрок
const errorPattern = /error|Error|failed/,
  hasError = str => errorPattern.test(str)

// ✅ Set для вхождения — O(1)
const flags = new Set(['--out', '--port'])
flags.has(flag) && processFlag(flag)

// ✅ Map для маппинга — O(1)
const configs = new Map([
  ['prod', 'api.prod.com'],
  ['dev', 'api.dev.com']
]),
  config = configs.get(env)

// ✅ Object для простых маппингов
const configs = { prod: 'api.prod.com', dev: 'api.dev.com' },
  config = configs[env]
```

### Алгоритмическая сложность

Избегать O(n²), использовать эффективные структуры данных

```javascript
// ❌ O(n²)
function findDuplicates(arr) {
  return arr.filter((item, idx) => arr.indexOf(item) !== idx)
}

// ✅ O(n)
function findDuplicates(arr) {
  const seen = new Set()
  return arr.filter(item => {
    if (seen.has(item)) return true
    seen.add(item)
    return false
  })
}

// ❌ O(n²)
const removeDuplicates = arr => arr.filter((item, idx) => arr.indexOf(item) === idx)

// ✅ O(n)
const removeDuplicates = arr => [...new Set(arr)]

// ❌ Поиск в массиве — O(n)
const userIds = [1, 2, 3, 4, 5]
userIds.includes(targetId) && processUser(targetId)

// ✅ Поиск в Set — O(1)
const userIds = new Set([1, 2, 3, 4, 5])
userIds.has(targetId) && processUser(targetId)
```

### Минимизация операций

```javascript
// ❌ Копирование всех элементов
const updateItems = (items, id, data) =>
  items.map(item => item.id === id ? { ...item, ...data } : { ...item })

// ✅ Копирование только изменённого
const updateItems = (items, id, data) =>
  items.map(item => item.id === id ? { ...item, ...data } : item)

// ❌ Множественные проходы
function processData(items) {
  const filtered = items.filter(item => item.isActive),
    mapped = filtered.map(item => item.value),
    sorted = mapped.sort((a, b) => b - a)
  return sorted
}

// ✅ Один проход
const processData = items => items
  .reduce((acc, item) => {
    item.isActive && acc.push(item.value)
    return acc
  }, [])
  .sort((a, b) => b - a)
```

## Борьба с дублированием

**Правило**: если код повторяется 2+ раза — устранить дублирование

**Приоритет методов:**
1. **Генерализация** — переструктурировать код для универсальности (цикл, map, конфигурация)
2. **Вынос в функцию** — если генерализация невозможна
3. **Вынос в переменную** — для повторяющихся значений

### Генерализация: цикл вместо дублирования

```javascript
// ❌ Дублирование
const rootSource = await pickSource(opts.slug)
rootSource === 'content' && (rootChildren = await loadContent(base, opts.slug, rootTree))

const source = await pickSource(slug)
source === 'content' && (chosen = await loadContent(base, slug, tree))

// ✅ Генерализация — массив + цикл
const sources = [
  { slug: opts.slug, tree: rootTree },
  { slug, tree }
]

const [rootChildren, chosen] = await Promise.all(sources.map(async ({ slug, tree }) => {
  const source = await pickSource(slug)
  return source === 'content' ? await loadContent(base, slug, tree) : tree
}))
```

### Генерализация: объект конфигурации

```javascript
// ❌ Похожие функции
async function pickSource(slug) {
  const recipePath = path.resolve(__dirname, 'practicum-choose-source.goose.yaml')
  !await fileExists(recipePath) && (return 'tree')
  const result = await runGoose(recipePath, slug)
  return parseResult(result, 'tree')
}

async function pageSlug(title) {
  const recipePath = path.resolve(__dirname, 'practicum-page-slug.goose.yaml'),
    fallback = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
  !await fileExists(recipePath) && (return fallback)
  const result = await runGoose(recipePath, title)
  return parseResult(result, fallback)
}

// ✅ Конфигурация
const recipes = {
  source: {
    file: 'practicum-choose-source.goose.yaml',
    fallback: () => 'tree'
  },
  slug: {
    file: 'practicum-page-slug.goose.yaml',
    fallback: title => title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
  }
}

async function runRecipe(type, input) {
  const { file, fallback } = recipes[type],
    recipePath = path.resolve(__dirname, file)

  !await fileExists(recipePath) && (return fallback(input))

  const result = await runGoose(recipePath, input)
  return parseResult(result, fallback(input))
}
```

### Генерализация: Map обработчиков

```javascript
// ❌ Повторяющиеся условия
const [flag, value] = arg.split('=')

flag === '--parallel' && value && (opts.parallel = Math.max(1, +value))
flag === '--out' && value && (opts.out = path.resolve(value))
flag === '--slug' && value && (opts.slug = value)
flag === '--clear-cache' && (opts.clear = true)

// ✅ Map обработчиков
const handlers = {
  '--parallel': v => ({ parallel: Math.max(1, +v) }),
  '--out': v => ({ out: path.resolve(v) }),
  '--slug': v => ({ slug: v }),
  '--clear-cache': () => ({ clear: true })
}

const [flag, value] = arg.split('='),
  handler = handlers[flag]

handler && (value || flag === '--clear-cache') && Object.assign(opts, handler(value))
```

### Генерализация: массив данных + Promise.all

```javascript
// ❌ Множественные вызовы
const rootTreeJson = jsonTree(rootChildren)
rootTreeJson
  ? await fs.writeFile(base + '.tree.json', rootTreeJson)
  : await fs.rm(base + '.tree.json', { force: true })

const chosenTreeJson = jsonTree(chosen)
chosenTreeJson
  ? await fs.writeFile(base.file + '.tree.json', chosenTreeJson)
  : await fs.rm(base.file + '.tree.json', { force: true })

// ✅ Массив + Promise.all
await Promise.all([
  { data: rootChildren, path: base + '.tree.json' },
  { data: chosen, path: base.file + '.tree.json' }
].map(async ({ data, path }) => {
  const json = jsonTree(data)
  return json
    ? fs.writeFile(path, json)
    : fs.rm(path, { force: true })
}))
```

### Вынос в функцию

Когда генерализация невозможна или усложнит код

```javascript
// ❌ Дублирование логики
const json1 = JSON.stringify(data1)
json1
  ? await fs.writeFile('1.json', json1)
  : await fs.rm('1.json', { force: true })

const json2 = JSON.stringify(data2)
json2
  ? await fs.writeFile('2.json', json2)
  : await fs.rm('2.json', { force: true })

// ✅ Функция
async function writeJsonOrDelete(path, data) {
  const json = JSON.stringify(data)
  return json
    ? fs.writeFile(path, json)
    : fs.rm(path, { force: true })
}

await writeJsonOrDelete('1.json', data1)
await writeJsonOrDelete('2.json', data2)
```

## Паттерны и анти-паттерны

### Избегать
- Дублирование кода (2+ повтора)
- Массив + some/includes для статических списков (используй Set/Map/RegExp)
- Объекты как хранилища (используй Map/Set)
- `for..in` (используй `for..of` + `Object.entries`/`Object.keys`/`Object.values`)
- `hasOwnProperty` в любой форме (следствие `for..in` и объектов-хранилищ)
- Индексные циклы `for(let i = 0; ...)` и `while(item = arr[i++])` (используй `for..of`)
- Магические числа и строки
- Переменные, используемые один раз
- Неэффективные алгоритмы (O(n²) вместо O(n))
- Множественные `const`/`let` вместо одного через запятую
- `if` для простых условий вместо логических операторов

### Допустимо
- Глобальные переменные при необходимости
- Nested callbacks в любом объёме
- Длинные функции при необходимости
- Мутации для производительности

```javascript
// ❌ Избыточная переменная
function double(n) {
  const result = n * 2
  return result
}

// ✅ Лаконично
const double = n => n * 2

// ❌ Магическое число
user.age > 18 && grantAccess()

// ✅ Именованная константа
const ADULT_AGE = 18
user.age > ADULT_AGE && grantAccess()

// ❌ Множественные декларации
const a = 1
const b = 2
const c = 3

// ✅ Одна декларация
const a = 1, b = 2, c = 3

// ❌ Избыточный if
if(isActive) processUser()
if(!hasError) sendResponse()

// ✅ Логические операторы
isActive && processUser()
hasError || sendResponse()
```

## Типизация и валидация

### TypeScript
- Использование: для больших и сложных проектов
- Строгость: максимальная, избегать `any`
- JSDoc: альтернатива для небольших проектов

### Валидация данных
- Runtime валидация: использовать библиотеки (Zod, Yup, Joi) при необходимости
- Входные параметры: рассчитывать на соблюдение контрактов
- Устойчивость: писать код, устойчивый к разным типам входных данных

```javascript
// ✅ Устойчивый код
const getLength = arr => Array.isArray(arr) ? arr.length : 0

// ✅ С проверкой во время выполнения
import { z } from 'zod'

const UserSchema = z.object({
  name: z.string(),
  email: z.string().email(),
  age: z.number().min(0)
})

function createUser(data) {
  const validated = UserSchema.parse(data)
  return { ...validated, createdAt: Date.now() }
}
```

## Фронтенд

### DOM и события
- Vanilla JS или React по необходимости
- Event delegation предпочтительнее для производительности
- addEventListener вместо onclick

```javascript
// ✅ Event delegation
document.querySelector('.list').addEventListener('click', e => {
  e.target.matches('.item') && handleItemClick(e.target)
})
```

### React
- Только functional components
- Hooks использовать по правилам React (не вызывать условно, только на верхнем уровне)
- Context API для state management

```javascript
// ✅ Functional component
function UserCard({ user }) {
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <div className="UserCard" onClick={() => setIsExpanded(!isExpanded)}>
      <div className="UserCard-Name">{user.name}</div>
      {isExpanded && <div className="UserCard-Details">{user.email}</div>}
    </div>
  )
}

// ✅ Custom hook
function useUserData(userId) {
  const [user, setUser] = useState(null)

  useEffect(() => {
    fetchUserData(userId).then(setUser)
  }, [userId])

  return user
}
```

### CSS
- CSS in CSS (не CSS-in-JS)
- BEM naming в стиле React:
  - Формат: `BlockName-ElemName_modName_modVal`
  - Имена записываются латиницей
  - Блоки и элементы: с заглавной буквы, каждое слово с заглавной (PascalCase)
  - Модификаторы: со строчной буквы
  - Имя элемента отделяется от блока одним дефисом (-)
  - Разделители модификаторов: подчёркивание (_)

```css
/* ✅ BEM naming стиль React */
.UserCard { }
.UserCard-Avatar { }
.UserCard-Name { }
.UserCard-Details { }
.UserCard_premium { }
.UserCard_size_large { }
.UserCard-Avatar_rounded { }
```

## Тестирование

### Подход
- Unit-тесты: писать часто, особенно для AI-генерируемого кода
- Фреймворк: Node.js testing framework
- TDD vs тесты после: по ситуации

```javascript
// ✅ Простой тест
import { test } from 'node:test'
import assert from 'node:assert'

test('getUserStatus возвращает правильный статус', () => {
  assert.equal(
    getUserStatus({ isActive: true, isPremium: true }),
    'premium-active'
  )
  assert.equal(
    getUserStatus({ isActive: true, isPremium: false }),
    'active'
  )
})
```

### Code Review приоритеты

**Критично:**
- Дублирование кода — устранить
- Неэффективные структуры данных (массив вместо Set/Map/RegExp)
- Лаконичность (размер кода)
- Алгоритмическая сложность
- Производительность

**Вопрос вкуса:**
- «Сложность» и «читаемость» кода (зависит от привычки)

## Примеры кода в идеальном стиле

```javascript
// ✅ Лаконичность
const processUsers = (users, filter) => users.filter(filter)

// ✅ Условная логика с тернарными операторами
const getUserStatus = ({ isActive, isPremium }) =>
  isActive ? isPremium ? 'premium-active' : 'active' : 'inactive'

// ✅ Async операции
function fetchUserData(userId) {
  return fetch(`/api/users/${userId}`)
    .then(res => res.json())
    .catch(err => {
      console.error(err)
      return null
    })
}

// ✅ Эффективная проверка через RegExp
const errorPattern = /error|Error|failed/,
  isValid = result => !errorPattern.test(result)

// ✅ Генерализация через Promise.all
await Promise.all([
  { data: rootChildren, path: base + '.tree.json' },
  { data: chosen, path: base.file + '.tree.json' }
].map(async ({ data, path }) => {
  const json = jsonTree(data)
  return json ? fs.writeFile(path, json) : fs.rm(path, { force: true })
}))

// ✅ Композиция функций
const compose = (...fns) => x => fns.reduceRight((acc, fn) => fn(acc), x),
  addTax = price => price * 1.2,
  addShipping = price => price + 10,
  formatPrice = price => `${price.toFixed(2)} ₽`,
  calculateTotal = compose(formatPrice, addShipping, addTax)

// ✅ Лаконичные условия и декларации
const userName = user?.profile?.name ?? 'Аноним',
  isActive = user?.isActive ?? false,
  { id, email, ...rest } = user

isActive && processUser()
hasError || showSuccess()
```
