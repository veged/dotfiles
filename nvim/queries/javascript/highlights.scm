(variable_declaration ("var") @keyword.var)
(lexical_declaration ("let") @keyword.let)
(lexical_declaration ("const") @keyword.const)

(switch_statement ("switch") @keyword.switch)

(break_statement ("break") @keyword.break)
(continue_statement ("continue") @keyword.continue)

(array "[" @punctuation.bracket.array ","? @punctuation.delimiter.array "]" @punctuation.bracket.array)
