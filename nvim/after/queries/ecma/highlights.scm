;; extends

[(null) (undefined)] @constant @constant.builtin

(method_definition name: (property_identifier) @method.builtin
  (#eq? @method.builtin "constructor"))

(regex "/" @punctuation.regex.bracket)
(regex_flags) @string.regex.flags

(member_expression "." @punctuation.member.delimiter)
(optional_chain) @punctuation.member.delimiter

(string ["'" "\""] @punctuation.string.quote)
(template_string "`" @punctuation.string.quote)
((template_substitution ["${" "}"] @punctuation.special @punctuation.string.bracket) @none)

(array ["[" "]"] @punctuation.array.bracket)
(array "," @punctuation.array.delimiter)

(object ["{" "}"] @punctuation.object.bracket)
(object (pair ":" @punctuation.object.delimiter))
(object "," @punctuation.object.delimiter)

(if_statement condition: (parenthesized_expression ["(" ")"] @punctuation.keyword @punctuation.conditional.bracket))
(if_statement consequence: (statement_block ["{" "}"] @punctuation.keyword @punctuation.conditional.bracket))
(if_statement alternative: (else_clause (statement_block ["{" "}"] @punctuation.keyword @punctuation.conditional.bracket)))

(switch_statement value: (parenthesized_expression ["(" ")"] @punctuation.keyword @punctuation.conditional.bracket))
(switch_statement body: (switch_body ["{" "}"] @punctuation.keyword @punctuation.conditional.bracket))
(switch_case ":" @punctuation.keyword @punctuation.conditional.delimiter)
(switch_default ":" @punctuation.keyword @punctuation.conditional.delimiter)

(for_statement ["(" ")"] @punctuation.keyword @punctuation.repeat.bracket)
(for_statement body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.repeat.bracket))
(for_in_statement ["(" ")"] @punctuation.keyword @punctuation.repeat.bracket)
(for_in_statement body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.repeat.bracket))
(while_statement condition: (parenthesized_expression ["(" ")"] @punctuation.keyword @punctuation.repeat.bracket))
(while_statement body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.repeat.bracket))
(do_statement body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.repeat.bracket))
(do_statement condition: (parenthesized_expression ["(" ")"] @punctuation.keyword @punctuation.repeat.bracket))

(with_statement object: (parenthesized_expression ["(" ")"] @punctuation.keyword @punctuation.with.bracket))
(with_statement body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.with.bracket))

(try_statement body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.exception.bracket))
(catch_clause ["(" ")"] @punctuation.keyword @punctuation.exception.bracket)
(catch_clause body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.exception.bracket))
(finally_clause body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.exception.bracket))

(class_declaration body: (class_body ["{" "}"] @punctuation.keyword @punctuation.class.bracket))

(function_declaration parameters: (formal_parameters ["(" ")"] @punctuation.keyword @punctuation.function.bracket))
(function_declaration parameters: (formal_parameters "," @punctuation.keyword @punctuation.function.delimiter))
(function_declaration body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.function.bracket))
(generator_function_declaration parameters: (formal_parameters ["(" ")"] @punctuation.keyword @punctuation.function.bracket))
(generator_function_declaration parameters: (formal_parameters "," @punctuation.keyword @punctuation.function.delimiter))
(generator_function_declaration body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.function.bracket))
(function_expression parameters: (formal_parameters ["(" ")"] @punctuation.keyword @punctuation.function.bracket))
(function_expression parameters: (formal_parameters "," @punctuation.keyword @punctuation.function.delimiter))
(function_expression body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.function.bracket))
(arrow_function parameters: (formal_parameters ["(" ")"] @punctuation.keyword @punctuation.function.bracket))
(arrow_function parameters: (formal_parameters "," @punctuation.keyword @punctuation.function.delimiter))
(arrow_function "=>" @punctuation.function.special)
(arrow_function body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.function.bracket))
(generator_function_declaration "*" @punctuation.function.special)
(method_definition "*" @punctuation.function.special)
(method_definition parameters: (formal_parameters ["(" ")"] @punctuation.keyword @punctuation.function.bracket))
(method_definition parameters: (formal_parameters "," @punctuation.keyword @punctuation.function.delimiter))
(method_definition body: (statement_block ["{" "}"] @punctuation.keyword @punctuation.function.bracket))

["if" "else" "switch" "case"] @keyword @conditional
(switch_default "default" @keyword @conditional)

["import" "from" "as"] @keyword @keyword.include @include

["new" "delete" "typeof" "in" "instanceof" "void"] @keyword @keyword.operator @operator

["for" "do" "of" "while"] @keyword @keyword.repeat @repeat

(for_in_statement operator: "in" @keyword @keyword.repeat @repeat)

["class" "extends" "static" "get" "set"] @keyword @keyword.class

"static" @storageclass

"debugger" @keyword @keyword.debugger

"with" @keyword @keyword.with

["const" "let" "var"] @keyword.declaration

["return" "yield" "export"] @keyword @keyword.return
(export_statement "default" @keyword.return)

(break_statement "break" @keyword.break)
(continue_statement "continue" @keyword @keyword.continue)

"function" @keyword @keyword.function

["async" "await"] @keyword @keyword.coroutine

["throw" "try" "catch" "finally"] @keyword @keyword.exception
