-- https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/plugins.lua

local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
-- To manually update:
--     nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
--     :PackerSync
vim.cmd([[
	augroup packer_user_config
		autocmd!
		autocmd BufWritePost plugins.lua source <afile> | PackerSync
	augroup end
]])

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	--------------------------------------------------------------------------------
	-- Buffer Management

	-- Top status line
	-- https://github.com/akinsho/bufferline.nvim
	-- use({ "akinsho/bufferline.nvim", requires = "kyazdani42/nvim-web-devicons" })

	-- Tabby primarily shows tabs not buffers
	-- https://github.com/nanozuki/tabby.nvim
	-- use({ "nanozuki/tabby.nvim" })

	use({ "kdheepak/tabline.nvim" })

	-- TODO(jaredw): I like this one, but the coloring is off
	-- use({
	-- 	"romgrk/barbar.nvim",
	-- 	requires = { "kyazdani42/nvim-web-devicons" },
	-- })

	-- Bottom status line
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	-- Provide lsp status in lualine
	-- https://github.com/nvim-lua/lsp-status.nvim
	-- TODO(jaredw): Figure out how to set this up
	-- use({ "nvim-lua/lsp-status.nvim" })

	-- Session Management
	-- https://github.com/jedrzejboczar/possession.nvim
	use({
		"jedrzejboczar/possession.nvim",
		requires = { "nvim-lua/plenary.nvim" },
	})

	--------------------------------------------------------------------------------
	-- Windowing

	-- Adjust window size with C+↑→↓← (hljk) and move cursor with M+↑→↓← (hljk)
	-- https://github.com/mrjones2014/smart-splits.nvim
	use({ "mrjones2014/smart-splits.nvim" })

	--------------------------------------------------------------------------------
	-- Colors

	-- use({ "folke/tokyonight.nvim" })
	-- use({ "Mofiqul/vscode.nvim" })

	-- Automatic dark mode switching on macOS.
	use({ "cormacrelf/dark-notify" })

	-- Nightfox provides better support for treesitter + LSP
	-- https://github.com/EdenEast/nightfox.nvim
	use({ "EdenEast/nightfox.nvim" })

	-- Catppuccin provides better support for treesitter + LSP (this is what nightfox was based off of)
	use({ "catppuccin/nvim", as = "catppuccin" })

	--------------------------------------------------------------------------------
	-- Finders - Telescope

	-- https://github.com/Abstract-IDE/Abstract/blob/44f4204d5f3b7fc9e2a0f9c9843e246df6ee6024/lua/packer_nvim.lua
	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }, -- FZF sorter for telescope written in c
		},
	})

	-- Provides :Telescope frecency command which shows recent files by frequency + recency
	-- https://github.com/nvim-telescope/telescope-frecency.nvim
	use({ "nvim-telescope/telescope-frecency.nvim", requires = { "tami5/sqlite.lua" } })

	-- Project management
	-- https://github.com/nvim-telescope/telescope-project.nvim
	use({ "nvim-telescope/telescope-project.nvim" })

	-- telescope-file-browser.nvim is a file browser extension for
	-- telescope.nvim. It supports synchronized creation, deletion,
	-- renaming, and moving of files and folders powered by telescope.nvim
	-- and plenary.nvim.
	-- https://github.com/nvim-telescope/telescope-file-browser.nvim
	-- Uses `brew install fd` for speedup
	use({ "nvim-telescope/telescope-file-browser.nvim" })

	-- A searchable cheatsheet for neovim from within the editor using Telescope
	-- https://github.com/sudormrfbin/cheatsheet.nvim
	use({
		"sudormrfbin/cheatsheet.nvim",
		requires = {
			{ "nvim-telescope/telescope.nvim" },
			{ "nvim-lua/popup.nvim" },
			{ "nvim-lua/plenary.nvim" },
		},
	})

	-- Tree file browser
	-- https://github.com/kyazdani42/nvim-tree.lua
	use({
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons", -- optional, for file icons
		},
		tag = "nightly", -- optional, updated every week. (see issue #1193)
	})

	--------------------------------------------------------------------------------
	-- tpope plugins

	use({ "tpope/vim-abolish" }) -- camel to snake and back
	-- use({ "tpope/vim-commentary" }) -- comment things with `gc`
	use({ "tpope/vim-fugitive" }) -- git

	-- Show guides for indent levels
	-- https://github.com/lukas-reineke/indent-blankline.nvim
	use({ "lukas-reineke/indent-blankline.nvim" })

	-- Replacement for vim-commentary that supports tree sitter
	-- https://github.com/numToStr/Comment.nvim
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})

	--------------------------------------------------------------------------------
	-- Languages

	-- Provide standard configs for lsps
	-- https://github.com/neovim/nvim-lspconfig
	use({ "neovim/nvim-lspconfig" })

	-- Treesitter is an AST parser/syntax highlighter
	-- https://github.com/nvim-treesitter/nvim-treesitter
	-- Install new languages with `:TSInstall <language_to_install>`
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })

	-- Standalone UI for nvim-lsp progress
	-- https://github.com/j-hui/fidget.nvim
	use({ "j-hui/fidget.nvim" })

	-- A pretty list for showing diagnostics, references, telescope results, quickfix and location lists to help you solve all the trouble your code is causing.
	-- https://github.com/folke/trouble.nvim
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
	})

	-- CursorHold is used for diagnostic message on hover
	-- https://github.com/antoinemadec/FixCursorHold.nvim
	use({ "antoinemadec/FixCursorHold.nvim" })

	-- Formatter for lua - call with `require('stylua-nvim').format()`
	-- https://github.com/ckipp01/stylua-nvim
	use({ "ckipp01/stylua-nvim", run = "cargo install stylua" })

	-- Git signs
	-- https://github.com/lewis6991/gitsigns.nvim
	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({})
		end,
	})

	-- Null LS is a language server for other tools which aren't full
	-- language servers themselves like linters
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
		},
	})

	-- Snippet Engine for Neovim written in Lua.
	-- https://github.com/L3MON4D3/LuaSnip
	use({ "L3MON4D3/LuaSnip" })

	-- Completion engine
	-- https://github.com/hrsh7th/nvim-cmp
	use({ "hrsh7th/nvim-cmp" })

	-- TODO(jaredw): consider enabling these
	-- use "hrsh7th/cmp-cmdline"
	-- https://github.com/hrsh7th/cmp-emoji

	-- nvim-cmp source for buffer words.
	-- https://github.com/hrsh7th/cmp-buffer
	use({ "hrsh7th/cmp-buffer" })

	-- nvim-cmp source for filesystem paths.
	-- https://github.com/hrsh7th/cmp-path
	use({ "hrsh7th/cmp-path" })

	-- nvim-cmp source for neovim Lua API.
	-- https://github.com/hrsh7th/cmp-nvim-lua
	use({ "hrsh7th/cmp-nvim-lua" })

	-- nvim-cmp source for neovim's built-in language server client.
	-- https://github.com/hrsh7th/cmp-nvim-lsp
	use({ "hrsh7th/cmp-nvim-lsp" })

	-- nvim-cmp source for textDocument/documentSymbol via nvim-lsp.
	-- https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol
	use({ "hrsh7th/cmp-nvim-lsp-document-symbol" })

	-- nvim-cmp source for displaying function signatures with the current parameter emphasized:
	-- https://github.com/hrsh7th/cmp-nvim-lsp-signature-help
	use({ "hrsh7th/cmp-nvim-lsp-signature-help" })

	-- This tiny plugin adds vscode-like pictograms to neovim built-in lsp
	-- https://github.com/onsails/lspkind.nvim
	use({ "onsails/lspkind.nvim" })

	-- lspsaga!
	-- https://github.com/glepnir/lspsaga.nvim
	use({ "glepnir/lspsaga.nvim" })

	-- The Refactoring library based off the Refactoring book by Martin Fowler
	-- https://github.com/ThePrimeagen/refactoring.nvim
	use({
		"ThePrimeagen/refactoring.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-treesitter/nvim-treesitter" },
		},
	})

	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
	})

	-- Open Chrome bookmarks from telescope using fzf
	-- https://github.com/dhruvmanila/telescope-bookmarks.nvim
	use({ "dhruvmanila/telescope-bookmarks.nvim" })

	-- https://github.com/junegunn/vim-easy-align
	use({ "junegunn/vim-easy-align" })

	--------------------------------------------------------------------------------

	-- which key
	use({
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup({})
		end,
	})

	-- Languages
	-- use({ "jvirtanen/vim-hcl" })

	-- TODO: check out if i can install these
	-- cmp source for treesitter
	-- https://github.com/ray-x/cmp-treesitter
	-- Symbol analysis & navigation plugin for Neovim. Navigate codes like a breeze🎐. Exploring LSP and 🌲Treesitter symbols a piece of 🍰. Take control like a boss 🦍.
	-- https://github.com/ray-x/navigator.lua
	-- The goal of nvim-ufo is to make Neovim's fold look modern and keep high performance.
	-- https://github.com/kevinhwang91/nvim-ufo
	-- https://github.com/glepnir/dashboard-nvim

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
