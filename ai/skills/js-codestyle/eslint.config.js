import js from '@eslint/js'
import tseslint from '@typescript-eslint/eslint-plugin'
import tsParser from '@typescript-eslint/parser'
import unicorn from 'eslint-plugin-unicorn'

const baseRules = {
  // Форматирование
  indent: ['error', 2, { SwitchCase: 1 }],
  'linebreak-style': ['error', 'unix'],
  quotes: ['error', 'single', { avoidEscape: true, allowTemplateLiterals: true }],
  semi: ['error', 'never'],
  'max-len': ['error', {
    code: 120,
    ignoreStrings: true,
    ignoreTemplateLiterals: true,
    ignoreRegExpLiterals: true,
    ignoreUrls: true
  }],

  // Пробелы
  'keyword-spacing': ['error', {
    before: true,
    after: false,
    overrides: {
      import: { after: true },
      export: { after: true },
      default: { after: true },
      from: { after: true },
      else: { after: true },
      of: { after: true },
      in: { after: true },
      as: { after: true },
      case: { after: true },
      try: { after: true },
      finally: { after: true },
      return: { after: true },
      yield: { after: true },
      const: { after: true },
      let: { after: true },
      var: { after: true },
      do: { after: true }
    }
  }],
  'space-before-function-paren': ['error', { named: 'never', anonymous: 'never', asyncArrow: 'always' }],
  'space-in-parens': ['error', 'never'],
  'space-infix-ops': 'error',
  'no-multi-spaces': ['error', { exceptions: { ImportDeclaration: true } }],
  'array-bracket-spacing': ['error', 'never'],
  'object-curly-spacing': ['error', 'always'],
  'object-curly-newline': ['error', { multiline: true }],
  'object-property-newline': ['error', { allowAllPropertiesOnSameLine: true }],
  'computed-property-spacing': ['error', 'never'],
  'comma-spacing': 'error',
  'no-trailing-spaces': 'error',
  'eol-last': 'error',
  'no-multiple-empty-lines': ['error', { max: 1, maxEOF: 0, maxBOF: 0 }],

  // Блоки
  'brace-style': ['error', '1tbs', { allowSingleLine: true }],
  curly: ['warn', 'multi', 'consistent'],
  'nonblock-statement-body-position': 'off',

  // Декларации: одно const/let через запятую
  'one-var': ['error', 'consecutive'],
  'no-var': 'error',
  'prefer-const': 'error',

  // Объекты
  'object-shorthand': ['error', 'always', { avoidQuotes: true }],
  'quote-props': ['error', 'as-needed'],

  // Современный JS
  'prefer-template': 'error',
  'prefer-arrow-callback': 'error',
  'arrow-body-style': ['error', 'as-needed'],
  'arrow-parens': ['error', 'as-needed'],
  'prefer-spread': 'error',
  'prefer-rest-params': 'error',
  'prefer-object-spread': 'error',
  'prefer-destructuring': ['error', { array: false, object: true }, { enforceForRenamedProperties: false }],
  'no-useless-rename': 'error',
  'no-useless-return': 'error',
  'no-useless-concat': 'error',
  'no-useless-constructor': 'error',
  'no-useless-computed-key': 'error',

  // Поведение
  'no-unused-vars': ['error', { destructuredArrayIgnorePattern: '^_', argsIgnorePattern: '^_' }],
  'no-unused-expressions': ['error', { allowShortCircuit: true, allowTernary: true }],
  'no-cond-assign': 'off',
  'no-new': 'error',
  'no-lonely-if': 'error',
  'no-else-return': ['error', { allowElseIf: false }],
  eqeqeq: ['error', 'always', { null: 'ignore' }],

  // Запрет for..in (используй for..of с Object.entries/Object.keys/Object.values)
  'no-restricted-syntax': ['error', {
    selector: 'ForInStatement',
    message: 'Используй for..of с Object.entries/Object.keys/Object.values вместо for..in.'
  }],

  // Лаконичность и эффективные структуры
  'unicorn/no-lonely-if': 'error',
  'unicorn/no-negated-condition': 'error',
  'unicorn/no-new-array': 'error',
  'unicorn/no-unused-properties': 'error',
  'unicorn/no-for-loop': 'error',
  'unicorn/no-useless-spread': 'error',
  'unicorn/no-useless-undefined': 'error',
  'unicorn/prefer-spread': 'error',
  'unicorn/prefer-default-parameters': 'error',
  'unicorn/prefer-set-has': 'error',
  'unicorn/prefer-includes': 'error',
  'unicorn/prefer-string-starts-ends-with': 'error',
  'unicorn/prefer-array-some': 'error',
  'unicorn/prefer-object-from-entries': 'error',
  'unicorn/prefer-optional-catch-binding': 'error',
  'unicorn/prefer-array-flat': 'error',
  'unicorn/prefer-array-flat-map': 'error',
  'unicorn/better-regex': 'error',
  'unicorn/consistent-function-scoping': 'error',
  'unicorn/throw-new-error': 'error'
}

export default [
  { ignores: ['node_modules', 'dist', 'build', 'coverage', '**/*.d.ts'] },

  js.configs.recommended,

  {
    files: ['**/*.js', '**/*.mjs', '**/*.cjs'],
    plugins: { unicorn },
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module'
      }
    },
    linterOptions: { reportUnusedDisableDirectives: true },
    rules: baseRules
  },

  {
    files: ['**/*.ts', '**/*.tsx'],
    plugins: {
      unicorn,
      '@typescript-eslint': tseslint
    },
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        project: true,
        ecmaVersion: 'latest',
        sourceType: 'module'
      }
    },
    linterOptions: { reportUnusedDisableDirectives: true },
    rules: {
      ...tseslint.configs.recommended.rules,
      ...baseRules,
      'no-unused-vars': 'off',
      '@typescript-eslint/no-unused-vars': ['error', {
        destructuredArrayIgnorePattern: '^_',
        argsIgnorePattern: '^_'
      }],
      'no-unused-expressions': 'off',
      '@typescript-eslint/no-unused-expressions': ['error', { allowShortCircuit: true, allowTernary: true }]
    }
  }
]
