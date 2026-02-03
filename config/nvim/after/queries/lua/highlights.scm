;; extends

(function_definition parameters: (parameters ["(" ")"] @punctuation.keyword @punctuation.function.bracket))
(function_definition parameters: (parameters "," @punctuation.keyword @punctuation.function.delimiter))

(for_statement ["for" "do" "end"] @keyword @repeat)
(for_generic_clause ["in"] @keyword.repeat @repeat)

(while_statement ["while" "do" "end"] @keyword @repeat)
(repeat_statement ["repeat" "until"] @keyword @repeat)

(variable_declaration "local" @keyword.declaration)
(variable_declaration (assignment_statement "=" @operator.declaration))

(table_constructor ["{" "}"] @punctuation.table @punctuation.table.bracket)
(table_constructor (field "=" @operator.table))
(table_constructor "," @punctuation.table @punctuation.table.delimiter)
