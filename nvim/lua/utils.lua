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

local function keymap(m, a1, a2, a3)
  if a3 then
    vim.keymap.set(m, a1, a2, { desc = a3 })
  else
    for k, v in pairs(a1) do
      if #v == 2 then
        keymap(m, (a2 or '') .. k, v[1], v[2])
      else
        keymap(m, v, k)
      end
    end
  end
end

function keymapN(a1, a2, a3) keymap('n', a1, a2, a3) end
function keymapV(a1, a2, a3) keymap('v', a1, a2, a3) end

function Cmd(s) return '<Cmd>' .. s .. '<CR>' end
function S(s) return '<S-' .. s .. '>' end
function C(s) return '<C-' .. s .. '>' end
