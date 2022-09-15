(variable_declaration ("var") @keyword.var)
(lexical_declaration ("let") @keyword.let)
(lexical_declaration ("const") @keyword.const)

(if_statement
  condition: (parenthesized_expression
    "(" @punctuation.bracket.conditional
    ")" @punctuation.bracket.conditional))
(if_statement
  consequence: (statement_block
    "{" @punctuation.bracket.conditional
    "}" @punctuation.bracket.conditional))
(if_statement
  alternative: (else_clause (statement_block
    "{" @punctuation.bracket.conditional
    "}" @punctuation.bracket.conditional)))

(switch_statement ("switch") @keyword.switch)

(break_statement ("break") @keyword.break)
(continue_statement ("continue") @keyword.continue)

(array
  "[" @punctuation.bracket.array
  ","? @punctuation.delimiter.array
  "]" @punctuation.bracket.array)

(object
  "{" @punctuation.bracket.object
  (pair ":" @punctuation.delimiter.object)
  ","? @punctuation.delimiter.object
  "}" @punctuation.bracket.object)

(string ["'" "\""] @punctuation.quote.string)
(template_string
  "`" @punctuation.quote.string
  (template_substitution
    "${" @punctuation.bracket.string
    "}" @punctuation.bracket.string)
  "`" @punctuation.quote.string)

(member_expression "." @punctuation.delimiter.member)

(function_declaration
  parameters: (formal_parameters
    "(" @punctuation.bracket.function
    ","? @punctuation.delimiter.function
    ")" @punctuation.bracket.function))
(function_declaration
  body: (statement_block
    "{" @punctuation.bracket.function
    "}" @punctuation.bracket.function))
(function
  parameters: (formal_parameters
    "(" @punctuation.bracket.function
    ","? @punctuation.delimiter.function
    ")" @punctuation.bracket.function))
(function
  body: (statement_block
    "{" @punctuation.bracket.function
    "}" @punctuation.bracket.function))
(arrow_function
  parameters: (formal_parameters
    "(" @punctuation.bracket.function
    ","? @punctuation.delimiter.function
    ")" @punctuation.bracket.function))
(arrow_function "=>" @punctuation.arrow.function)
(arrow_function
  body: (statement_block
    "{" @punctuation.bracket.function
    "}" @punctuation.bracket.function))

