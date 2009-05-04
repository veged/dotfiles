if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet ai <xsl:apply-imports/>".st.et.""
exec "Snippet an <xsl:attribute name=\"".st.et."\">".st.et."</xsl:attribute>"
exec "Snippet ats <xsl:apply-templates select=\"".st.et."\"/>".st.et.""
exec "Snippet atsm <xsl:apply-templates select=\"".st.et."\" mode=\"".st.et."\"/>".st.et.""
exec "Snippet cos <xsl:copy-of select=\"".st.et."\"/>"
exec "Snippet ctn <xsl:call-template name=\"".st.et."\"/>".st.et.""
exec "Snippet ctnwp <xsl:call-template name=\"".st.et."\"><CR>      <xsl:with-param name=\"".st.et."\" select=\"".st.et."\"/><CR></xsl:call-template>".st.et.""
exec "Snippet cwt <xsl:choose><CR>    <xsl:when test=\"".st.et."\"><CR>        ".st.et."<CR>    </xsl:when><CR></xsl:choose>"
exec "Snippet cwto <xsl:choose><CR>    <xsl:when test=\"".st.et."\"><CR>        ".st.et."<CR>    </xsl:when><CR>    <xsl:otherwise><CR>        <CR>    </xsl:otherwise><CR></xsl:choose>"
exec "Snippet fe <xsl:for-each select=\"".st.et."\"><CR>    ".st.et."<CR></xsl:for-each>"
exec "Snippet it <xsl:if test=\"".st.et."\"><CR>    ".st.et."<CR></xsl:if>"
exec "Snippet kn <xsl:key name=\"".st.et."\" match=\"".st.et."\" use=\"".st.et."\"/>".st.et.""
exec "Snippet o <xsl:otherwise><CR>    ".st.et."<CR></xsl:otherwise>"
exec "Snippet pn <xsl:param name=\"".st.et."\"/>"
exec "Snippet tm <xsl:template match=\"".st.et."\"><CR>    ".st.et."<CR></xsl:template>"
exec "Snippet tmm <xsl:template match=\"".st.et."\" mode=\"".st.et."\"><CR>    ".st.et."<CR></xsl:template>"
exec "Snippet tn <xsl:template name=\"".st.et."\"><CR>    ".st.et."<CR></xsl:template>"
exec "Snippet tt <xsl:text>".st.et."</xsl:text>"
exec "Snippet vn <xsl:variable name=\"".st.et."\">".st.et."</xsl:variable>"
exec "Snippet vns <xsl:variable name=\"".st.et."\" select=\"".st.et."\"/>"
exec "Snippet vos <xsl:value-of select=\"".st.et."\"/>"
exec "Snippet wp <xsl:with-param name=\"".st.et."\" select=\"".st.et."\"/>".st.et.""
exec "Snippet wpn <xsl:with-param name=\"".st.et."\" select=\"".st.et."\"/>".st.et.""
exec "Snippet wt <xsl:when test=\"".st.et."\">".st.et."</xsl:when>"

