local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

return require('packer').startup(function(use)
  use {
    'wbthomason/packer.nvim',
    'lewis6991/impatient.nvim', -- Improve startup time for Neovim
    {
      'nvim-telescope/telescope.nvim', -- Find, Filter, Preview, Pick.
      branch = '0.1.x',
      requires = { 'nvim-lua/plenary.nvim' } -- All the lua functions I don't want to write twice.
    },
    'editorconfig/editorconfig-vim', -- EditorConfig plugin
    'rktjmp/highlight-current-n.nvim', -- highlights the current /, ? or * match under your cursor when pressing n or N
    'booperlv/nvim-gomove', -- A complete plugin for moving and duplicating blocks and lines, with complete fold handling, reindenting, and undoing in one go
    'tpope/vim-surround', -- Delete/change/add parentheses/quotes/XML-tags/much more with ease
    'numToStr/Comment.nvim', -- Smart and powerful comment plugin
    'windwp/nvim-autopairs', -- A super powerful autopair plugin for Neovim that supports multiple characters
    'ntpeters/vim-better-whitespace', -- Better whitespace highlighting
    'tpope/vim-repeat', -- Enable repeating supported plugin maps with .
    'nishigori/increment-activator', -- enhance to increment candidates U have defined
    'troydm/zoomwintab.vim', -- zoom current window

    'folke/which-key.nvim', -- displays a popup with possible keybindings of the command you started typing

    'nvim-lualine/lualine.nvim', -- A blazing fast and easy to configure neovim statusline plugin
    {
      'kyazdani42/nvim-tree.lua', -- A file explorer tree for neovim written in lua
      requires = { 'kyazdani42/nvim-web-devicons' } -- Adds file type icons to Vim plugins
    },
    {
      'folke/trouble.nvim', -- A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing
      requires = 'kyazdani42/nvim-web-devicons'
    },

    'L3MON4D3/LuaSnip', -- Snippet Engine for Neovim written in Lua
    { 'utilyre/spoon.nvim', requires = { 'L3MON4D3/LuaSnip' } }, -- A collection of luasnip snippets
    { 'saadparwaiz1/cmp_luasnip', requires = {'hrsh7th/nvim-cmp', 'L3MON4D3/LuaSnip'} }, -- A collection of luasnip snippets
    'neovim/nvim-lspconfig', -- Quickstart configurations for the Nvim LSP client

    'onsails/lspkind.nvim', -- vscode-like pictograms for neovim lsp completion items
    'hrsh7th/nvim-cmp', -- A completion plugin for neovim coded in Lua
    { 'hrsh7th/cmp-nvim-lsp', requires = {'hrsh7th/nvim-cmp'} }, -- source for neovim builtin LSP client  use 'hrsh7th/cmp-nvim-lsp'
    { 'ray-x/cmp-treesitter', requires = {'hrsh7th/nvim-cmp'} }, -- source for treesitter
    { 'hrsh7th/cmp-nvim-lua', requires = {'hrsh7th/nvim-cmp'} }, -- source for lua
    { 'hrsh7th/cmp-buffer', requires = {'hrsh7th/nvim-cmp'} }, -- source for buffer words
    { 'octaltree/cmp-look', requires = {'hrsh7th/nvim-cmp'} }, -- source for Linux look
    { 'hrsh7th/cmp-path', requires = {'hrsh7th/nvim-cmp'} }, -- source for filesystem paths

    { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }, -- Nvim Treesitter configurations and abstraction layer
    'nvim-treesitter/playground', -- Treesitter playground integrated into Neovim

    {
      'lewis6991/gitsigns.nvim', -- Git integration for buffers
      config = function() require('gitsigns').setup() end
    },

    'rktjmp/lush.nvim', -- Create Neovim themes with real-time feedback, export anywhere
    'veged/yacolors.nvim',
    'rickhowe/diffchar.vim', -- Highlight the exact differences, based on characters and words
    'norcalli/nvim-colorizer.lua', -- A high-performance color highlighter
    'moll/vim-node', -- Tools and environment to make Vim superb for developing with Node.js
    'jose-elias-alvarez/typescript.nvim', -- A Lua plugin, written in TypeScript, to write TypeScript
    'JoosepAlviste/nvim-ts-context-commentstring', -- Neovim treesitter plugin for setting the commentstring based on the cursor location in a file
    {
        'windwp/nvim-ts-autotag', -- Use treesitter to auto close and auto rename html tag
        config = function() require('nvim-ts-autotag').setup() end
    },
    'nvim-treesitter/nvim-treesitter-textobjects', -- Syntax aware text-objects, select, move, swap, and peek support
    'maxmellon/vim-jsx-pretty', -- JSX and TSX syntax pretty highlighting
    'euclidianAce/BetterLua.vim', -- Better Lua syntax highlighting
    'andrejlevkovitch/vim-lua-format', -- Lua vim formatter supported by LuaFormatter
  }


  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then require('packer').sync() end
end)
