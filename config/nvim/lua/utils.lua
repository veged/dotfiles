g = vim.g
o = vim.o

function autocmd(e, c, p)
  vim.api.nvim_create_autocmd(
    e,
    {
      pattern = p or '*',
      [type(c) == 'string' and 'command' or 'callback'] = c
    })
end

function keymap(m, a1, a2, a3, a4)
  if type(a1) == 'table' then
    a3 = a2
    a2 = a1
    a1 = ''
  end

  if type(a2) == 'table' then
    if #a2 ~= 0 then
      keymap(m, a1, a2[1], a2[2], a3)
    else
      for k, v in pairs(a2) do
        if type(v) == 'table' and #v == 2 then
          keymap(m, a1 .. k, v[1], v[2], a3)
        else
          keymap(m, a1 .. k, v, a3)
        end
      end
    end
  else
    if type(a3) == 'string' then a3 = { desc = a3 } end
    vim.keymap.set(m, a1, a2, vim.tbl_extend('force', {}, a3 or {}, a4 or {}))
  end
end

function keymapN(a1, a2, a3, a4) keymap('n', a1, a2, a3, a4) end
function keymapV(a1, a2, a3, a4) keymap('v', a1, a2, a3, a4) end
function keymapC(a1, a2, a3, a4) keymap('c', a1, a2, a3, a4) end
function keymapI(a1, a2, a3, a4) keymap('i', a1, a2, a3, a4) end

function Cmd(s) return '<Cmd>' .. s .. '<CR>' end
function S(s) return '<S-' .. s .. '>' end
function M(s) return '<M-' .. s .. '>' end
function C(s) return '<C-' .. s .. '>' end
function CS(s) return C('S-' .. s) end
function MC(s) return C('C-' .. s) end
