if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet proto ".st."className".et.".prototype.".st."methodName".et." = function(".st.et.")<CR>{<CR>".st.et."<CR>};<CR>".st.et
exec "Snippet fun function ".st."functionName".et." (".st.et.") {<CR>".st.et."<CR>}<CR>".st.et
exec "Snippet cl console.log(".st."1".et.");".st.et
