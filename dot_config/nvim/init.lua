-- https://github.com/nanotee/nvim-lua-guide

-- 2 moving around, searching and patterns
vim.opt.ignorecase = true -- ignore case for most searches
vim.opt.smartcase = true -- ignore ignorecase option if search includes upper case characters

-- 4 displaying text
vim.opt.wrap = true -- wrap long lines
vim.opt.showbreak = "> " -- if a line is wrapped preface it with a '> '
vim.opt.display = "uhex" -- view unprintable characters by their hex value <xx>
vim.opt.lazyredraw = true -- don't redraw while executing macros

vim.opt.list = true -- show trailing whitespace and tabs
vim.opt.listchars = {
	tab = "| ", -- tab for tabs
	trail = "·", -- trail for trailing whitespace
	extends = ">", -- extends/precedes for text off screen
	precedes = "<",
	nbsp = "+", -- nbsp for non-breakable white-space
}

vim.opt.number = true --  show line numbers

vim.opt.cursorline = false -- show a cursor line, sometimes this might be nice to turn on

-- 6 multiple window
vim.opt.hidden = true -- don't unload buffers no longer shown in windows
vim.opt.splitbelow = true -- new window put below current window
vim.opt.splitright = true -- new window put right of the current window

--------------------------------------------------------------------------------
-- language settings/extensions
-- 14 tabs and indenting
vim.opt.tabstop = 8 -- insert 8 spaces for every tab

vim.opt.shiftwidth = 2 -- insert 8 spaces if autoindent chooses to indent new line
vim.opt.softtabstop = 2 -- insert 0 spaces for every tab
vim.opt.expandtab = true -- don't convert tabs to spaces

vim.opt.smarttab = true -- a <Tab> in an indent inserts shiftwidth spaces

vim.opt.autoindent = true -- autoindent the lines according to the previous lines
vim.opt.smartindent = true -- don't always indent if obvious from syntax

-- 19 the swap file
vim.o.swapfile = false -- move all files to memory
vim.bo.swapfile = false

-- always show 1 width sign column so it isn't so annoying when in lsp mode
vim.opt.signcolumn = "yes:1"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Leader key -> " "
-- In general, it's a good idea to set this early in your config, because otherwise if you have any mappings you set BEFORE doing this, they will be set to the OLD leader.
-- Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " " -- set leader key to space
vim.g.maplocalleader = " " -- and also for the local buffer because thats what `let` does...

-- load packer plugins
require("jlw/plugins")

-- local lsp_status = require('lsp-status')

--------------------------------------------------------------------------------
-- Telescope

-- Use Ctrl+/ in insert mode to bring up internal which-key
-- Use ? in normal mode to bring up internal which-key
require("telescope").setup({
	defaults = {
		layout_config = {
			horizontal = { width = 0.8 },
			vertical = { width = 0.8 },
		},
	},
	extensions = {
		fzf = {
			fuzzy = false, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
		file_browser = {
			hidden = true, -- show hidden files
		},
		bookmarks = {
			-- Available: 'brave', 'buku', 'chrome', 'chrome_beta', 'edge', 'safari', 'firefox', 'vivaldi'
			selected_browser = "chrome",
			-- Either provide a shell command to open the URL
			url_open_command = "open",
			-- Show the full path to the bookmark instead of just the bookmark name
			full_path = true,
		},
	},
	pickers = {
		lsp_references = { fname_width = 50 },
	},
})

-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
-- https://github.com/nvim-telescope/telescope-fzf-native.nvim
require("telescope").load_extension("fzf")
require("telescope").load_extension("frecency")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("possession")
require("telescope").load_extension("project")
require("telescope").load_extension("bookmarks")

-- Use with <leader>?
require("cheatsheet").setup({})

-- :help nvim-tree-setup
require("nvim-tree").setup({
	view = {
		-- Resize the window on each draw based on the longest line.
		-- Use this while not showing symlinks so it stays reasonable
		-- adaptive_size = true,

		-- Width of the window, can be a `%` string, a number representing columns or a function.
		width = 50,

		-- Side of the tree, can be `"left"`, `"right"`, `"bottom"`, `"top"`.
		side = "left",
	},

	-- Reloads the explorer every time a buffer is written to.
	auto_reload_on_write = true,

	-- Automatically reloads the tree on `BufEnter` nvim-tree.
	reload_on_bufenter = true,

	-- Changes the tree root directory on `DirChanged` and refreshes the tree.
	sync_root_with_cwd = true,

	renderer = {
		-- Whether to show the destination of the symlink.
		symlink_destination = true,
	},
})

--------------------------------------------------------------------------------
-- Color Settings

-- https://github.com/Mofiqul/vscode.nvim
-- mode: "light" | "dark"
-- Unfortunately this is currently broken because nvim_set_hl replaces the highlight scheme instead of updating it and neovim can't reload properly
-- Note: Unlike the `:highlight` command which can update a highlight group, this function completely replaces the definition. For example: `nvim_set_hl(0, 'Visual', {})` will clear the highlight group 'Visual'.
-- This plugin uses nvim_set_hl to set color rather than :highlight
-- It doesn't actually work on switching because it replaces the highlight group vs updating it in place
-- https://github.com/neovim/neovim/issues/18160
-- https://github.com/neovim/neovim/issues/13246
-- https://github.com/neovim/neovim/issues/18266
local function change_color_mode(mode)
	local c = require("vscode.colors")
	local hl = vim.api.nvim_set_hl
	require("vscode").setup({
		-- Override highlight groups (see ./lua/vscode/theme.lua)
		-- group_overrides = {
		-- 	-- Change the background colors to vscSelection
		-- 	TelescopeSelection = { fg = c.vscFront, bg = c.vscSelection },
		-- 	TelescopeMultiSelection = { fg = c.vscFront, bg = c.vscSelection },
		-- },
	})

	if mode == "light" then
		require("vscode").change_style("light")
	elseif mode == "dark" then
		require("vscode").change_style("dark")
	else
		print("unrecognized mode: " .. mode)
	end

	hl(0, "TelescopeSelection", { fg = c.vscFront, bg = c.vscSelection })
	hl(0, "TelescopeMultiSelection", { fg = c.vscFront, bg = c.vscSelection })
end

-- lsp_status.register_progress()

-- Bottom status bar
-- setup lualine
local function setup_lualine(mode)
	local theme = mode == "dark" and "nordfox" or "dayfox"
	require("lualine").setup({
		options = {
			-- theme = 'tokyonight',
			-- theme = 'onelight',
			-- theme = "vscode",
			-- theme = "dayfox",
			theme = theme,
			icons_enabled = false,
			section_separators = "",
			component_separators = "",
		},
		sections = {
			lualine_a = {
				{
					"filename",
					path = 1, -- 1: Relative path
				},
			},
			-- lualine_x = { lsp_status.status, "encoding", "fileformat", "filetype" },
		},
	})
end

-- Use a light grey indent
local function highlight_indent_blankline(mode)
	if mode == "dark" then
		vim.cmd([[ highlight! IndentBlanklineHighlight guifg=#444444 guibg=NONE ]])
	else
		vim.cmd([[ highlight! IndentBlanklineHighlight guifg=#cccccc guibg=NONE ]])
	end
end

local dn = require("dark_notify")

-- Configure
dn.run({
	schemes = {
		dark = {
			-- colorscheme = "vscode",
			colorscheme = "nordfox",
			-- colorscheme = "catppuccin",
			background = "dark",
		},
		light = {
			-- colorscheme = "vscode",
			colorscheme = "dayfox",
			-- colorscheme = "catppuccin",
			background = "light",
		},
	},
	onchange = function(mode)
		setup_lualine(mode)
		highlight_indent_blankline(mode)
	end,
	-- onchange = change_color_mode,
	-- onchange = function(mode)
	-- 	if mode == "dark" then
	-- 		vim.cmd([[Catppuccin frappe]])
	-- 	else
	-- 		vim.cmd([[Catppuccin latte]])
	-- 	end
	-- end
})

-- Show guides for indentation levels
-- :help indent-blankline-variables
require("indent_blankline").setup({
	buftype_exclude = { "terminal" },
	filetype_exclude = { "man", "help", "markdown", "NvimTree" },
	char_highlight_list = { "IndentBlanklineHighlight" },
	context_highlight_list = { "Warning" },
	use_treesitter = true,
	show_first_indent_level = true,
	show_current_context = false, -- highlights current indent level
	show_current_context_start = false,
})

--------------------------------------------------------------------------------
-- Language Settings (LSP, Treesitter, Completions, Tab Settings)

require("jlw/lang")

--------------------------------------------------------------------------------
-- Global Opts - meta commands

-- navigate buffers with arrow keys (in normal mode)
-- vim.api.nvim_set_keymap("n", "<left>", ":bprevious<CR>", { noremap = true })
-- vim.api.nvim_set_keymap("n", "<right>", ":bnext<CR>", { noremap = true })

-- Navigate buffers with Left/Right, navigate tabs with Shift + Left/Right
vim.keymap.set("n", "<Left>", [[<cmd>bprevious<cr>]])
vim.keymap.set("n", "<Right>", [[<cmd>bnext<cr>]])
vim.keymap.set("n", "<S-Left>", [[<cmd>tabprevious<cr>]])
vim.keymap.set("n", "<S-Right>", [[<cmd>tabnext<cr>]])

vim.keymap.set("n", "<C-p>", require("telescope").extensions.project.project)

-- smart-splits recommended mappings
-- https://github.com/mrjones2014/smart-splits.nvim
-- These bind Opt/Ctrl with arrow keys and hjkl vim directions
-- I had to unmap Ctrl + arrow keys in OSX shortcuts for mission control
-- OSX converts Opt arrow keys into unicode characters, so there's a weird hack
-- here to just interpret those weird unicode characters

-- resizing splits - ⌥ +↑→↓←
vim.keymap.set("n", "<A-Left>", require("smart-splits").resize_left)
vim.keymap.set("n", "<A-Down>", require("smart-splits").resize_down)
vim.keymap.set("n", "<A-Up>", require("smart-splits").resize_up)
vim.keymap.set("n", "<A-Right>", require("smart-splits").resize_right)
vim.keymap.set("n", "˙", require("smart-splits").resize_left) -- these are really funky unicodes: opt+h
vim.keymap.set("n", "∆", require("smart-splits").resize_down) -- these are really funky unicodes: opt+j
vim.keymap.set("n", "˚", require("smart-splits").resize_up) -- these are really funky unicodes: opt+k
vim.keymap.set("n", "¬", require("smart-splits").resize_right) -- these are really funky unicodes: opt+l
vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)

-- moving between splits - C+↑→↓←
vim.keymap.set("n", "<C-Left>", require("smart-splits").move_cursor_left)
vim.keymap.set("n", "<C-Down>", require("smart-splits").move_cursor_down)
vim.keymap.set("n", "<C-Up>", require("smart-splits").move_cursor_up)
vim.keymap.set("n", "<C-Right>", require("smart-splits").move_cursor_right)
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)

-- which key

require("jlw/which_key")

--------------------------------------------------------------------------------
-- Session management

-- This saves to ~/.local/share/nvim/possession
require("possession").setup({
	autosave = {
		current = true, -- or fun(name): boolean
		tmp = false, -- or fun(): boolean
		tmp_name = "tmp",
		on_load = true,
		on_quit = true,
	},
})

--------------------------------------------------------------------------------
-- setup buffer line

vim.opt.termguicolors = true
-- require("bufferline").setup({})
-- require("tabby").setup({})

require("tabline").setup({
	-- Defaults configuration options
	enable = true,
	options = {
		-- If lualine is installed tabline will use separators configured in lualine by default.
		-- These options can be used to override those settings.
		-- section_separators = {'', ''},
		-- component_separators = {'', ''},
		section_separators = { "", "" },
		component_separators = { "", "" },
		-- max_bufferline_percent = 66, -- set to nil by default, and it uses vim.o.columns * 2/3
		-- show_tabs_always = false, -- this shows tabs only when there are more than one tab or if the first tab is named
		show_tabs_always = true, -- this shows tabs only when there are more than one tab or if the first tab is named
		show_devicons = false, -- this shows devicons in buffer section
		show_bufnr = true, -- this appends [bufnr] to buffer section,
		show_filename_only = true, -- shows base filename only instead of relative path in filename
		-- modified_icon = "+ ", -- change the default modified icon
		-- modified_italic = false, -- set to true by default; this determines whether the filename turns italic if modified
		-- show_tabs_only = false, -- this shows only tabs instead of tabs + buffers
	},
})
vim.cmd([[
	set guioptions-=e " Use showtabline in gui vim
	set sessionoptions+=tabpages,globals " store tabpages and globals in session
]])

-- This is actually the barbar.nvim plugin, no clue why they renamed it
-- require("bufferline").setup({})

--------------------------------------------------------------------------------
-- Autocmds

-- Vertical split for help
-- https://github.com/TeoDev1611/astro.nvim/blob/astro/lua/core/sets.lua
local vim_group = vim.api.nvim_create_augroup("vimrc_help", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.txt",
	command = [[if &buftype == 'help' | wincmd L | endif]],
	group = vim_group,
})

-- TODO comments!
require("todo-comments").setup({
	highlight = {
		pattern = [[.*<(KEYWORDS)[^:]*:]],
	},
	search = {
		pattern = [[\b(KEYWORDS)[^:]*:]], -- ripgrep regex
	},
})

local function open_in_github()
	vim.fn.expand('%:p')
end
vim.fn.expand('%:p')
