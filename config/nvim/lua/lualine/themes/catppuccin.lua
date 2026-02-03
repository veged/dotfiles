local C = require('catppuccin.palettes').get_palette()
local O = require('catppuccin').options
local transparent_bg = O.transparent_background and 'NONE' or C.mantle

return {
  normal = {
    a = { bg = C.green, fg = C.mantle, gui = 'bold' },
    b = { bg = C.surface1, fg = C.green },
    c = { bg = transparent_bg, fg = C.text },
    x = { bg = transparent_bg, fg = C.text },
    y = { bg = C.surface1, fg = C.green },
    z = { bg = C.green, fg = C.mantle, gui = 'bold' },
  },

  insert = {
    a = { bg = C.peach, fg = C.base, gui = 'bold' },
    b = { bg = C.surface1, fg = C.peach },
    y = { bg = C.surface1, fg = C.peach },
    z = { bg = C.peach, fg = C.base, gui = 'bold' },
  },

  terminal = {
    a = { bg = C.lavender, fg = C.base, gui = 'bold' },
    b = { bg = C.surface1, fg = C.lavender },
    y = { bg = C.surface1, fg = C.lavender },
    z = { bg = C.lavender, fg = C.base, gui = 'bold' },
  },

  command = {
    a = { bg = C.mauve, fg = C.base, gui = 'bold' },
    b = { bg = C.surface1, fg = C.yellow },
    y = { bg = C.surface1, fg = C.yellow },
    z = { bg = C.mauve, fg = C.base, gui = 'bold' },
  },

  visual = {
    a = { bg = C.sky, fg = C.base, gui = 'bold' },
    b = { bg = C.surface1, fg = C.sky },
    y = { bg = C.surface1, fg = C.sky },
    z = { bg = C.sky, fg = C.base, gui = 'bold' },
  },

  replace = {
    a = { bg = C.red, fg = C.base, gui = 'bold' },
    b = { bg = C.surface1, fg = C.red },
    y = { bg = C.surface1, fg = C.red },
    z = { bg = C.red, fg = C.base, gui = 'bold' },
  },

  inactive = {
    a = { bg = transparent_bg, fg = C.overlay0 },
    b = { bg = transparent_bg, fg = C.surface1, gui = 'bold' },
    c = { bg = transparent_bg, fg = C.overlay0 },
    x = { bg = transparent_bg, fg = C.overlay0 },
    y = { bg = transparent_bg, fg = C.surface1, gui = 'bold' },
    z = { bg = transparent_bg, fg = C.overlay0 },
  },
}

