export default function remarkUnwrapText() {
  return (tree, file) => {
    function visit(node) {
      if(node.type === 'text') {
        const value = node.value.replace(/\r\n?|\n/g, ' ')

        if(value !== node.value) {
          file.message('Объедините текст абзаца в одну строку', node.position, 'remark-unwrap-text:soft-line-break')
          node.value = value
        }
      }

      for(const child of node.children ?? []) visit(child)
    }

    visit(tree)
  }
}
