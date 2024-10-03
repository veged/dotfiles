;; extends

(string ["\""] @punctuation.string.quote)

["[" "]"] @punctuation.array.bracket
(array "," @punctuation.array.delimiter)

(object ["{" "}"] @punctuation.object.bracket)
(object (pair ":" @punctuation.object.delimiter))
(object "," @punctuation.object.delimiter)
