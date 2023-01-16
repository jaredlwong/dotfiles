--------------------------------------------------------------------------------
-- Language Settings (LSP, Treesitter, Completions, Tab Settings)
--------------------------------------------------------------------------------

local lspconfig = require("lspconfig")
local nvim_treesitter_configs = require("nvim-treesitter.configs")
local cmp = require("cmp")
local lspkind = require("lspkind")
local luasnip = require("luasnip")
local null_ls = require("null-ls")
local lspsaga = require("lspsaga")
-- local lsp_status = require("lsp-status")

--------------------------------------------------------------------------------
-- Language Syntax (Treesitter)

-- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
nvim_treesitter_configs.setup({
	-- ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	ensure_installed = "all",

	ignore_install = { "phpdoc" }, -- List of parsers to ignore installing

	highlight = {
		enable = true,
		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
	-- Indentation based on treesitter for the `=` operator
	indent = {
		enable = true,
	},
	query_linter = {
		enable = true,
		use_virtual_text = true,
		lint_events = { "BufWrite", "CursorHold" },
	},
	endwise = {
		enable = true,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
})

vim.cmd([[
	set foldmethod=expr
	set foldexpr=nvim_treesitter#foldexpr()
	" open without folds, fold everything with `zi`
	set nofoldenable
]])

-- Refactoring functions
require("refactoring").setup({})

-- Standalone UI for nvim-lsp progress
require("fidget").setup({})

-- Trouble brings up a quick list for diagnostics
require("trouble").setup({})

--------------------------------------------------------------------------------
-- Language settings (LSPs)
-- https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/server_configurations

-- Make the default settings of lsp diagnostics less annoying
-- https://github.com/neovim/nvim-lspconfig/issues/195

-- diagnotics on hover
vim.cmd([[
	let g:cursorhold_updatetime = 100
	autocmd CursorHold * lua vim.diagnostic.open_float({focusable = false, scope = "c"})
]])

-- How to show the warning messages in the editor
-- :help vim.lsp.diagnostic.on_publish_diagnostics
-- :help vim.diagnostic.config
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	underline = true,

	-- This will disable virtual text, like doing:
	-- let g:diagnostic_enable_virtual_text = 0
	virtual_text = false,
	-- { severity = vim.diagnostic.severity.ERROR },

	-- This is similar to:
	-- let g:diagnostic_show_sign = 1
	-- To configure sign display,
	--  see: ":help vim.lsp.diagnostic.set_signs()"
	signs = true,

	-- This is similar to:
	-- "let g:diagnostic_insert_delay = 1"
	update_in_insert = false,
})

--------------------------------------------------------------------------------

local updated_capabilities = vim.lsp.protocol.make_client_capabilities()

-- Setup completion extension
updated_capabilities = require("cmp_nvim_lsp").default_capabilities(updated_capabilities)
-- updated_capabilities = vim.tbl_extend('keep', updated_capabilities, lsp_status.capabilities)

local function setup_server(server, config)
	config = vim.tbl_deep_extend("force", {
		capabilities = updated_capabilities,
		-- on_attach = lsp_status.on_attach,
	}, config)
	lspconfig[server].setup(config)
end

-- Terraform Language Server
-- `brew install hashicorp/tap/terraform-ls`
setup_server("terraformls", {})

-- Bash Language Server
-- https://github.com/bash-lsp/bash-language-server
-- `npm i -g bash-language-server`
setup_server("bashls", {})

-- Typescript Language Server
-- This language server wraps the tsserver language server bundled with vscode
-- https://github.com/typescript-language-server/typescript-language-server
-- https://github.com/Microsoft/TypeScript/wiki/Standalone-Server-%28tsserver%29
-- `npm install -g typescript typescript-language-server`
setup_server("tsserver", {})

-- Rust Language Server
-- https://github.com/rust-lang/rust-analyzer
-- https://rust-analyzer.github.io/manual.html#installation
-- TODO(jaredw): Ideally this would be available through rustup
-- `brew install rust-analyzer`
-- rustup toolchain install nightly
-- rustup run nightly rust-analyzer
setup_server("rust_analyzer", {
	cmd = { "rustup", "run", "nightly", "rust-analyzer" },
})

-- Go Language Server
-- https://github.com/golang/tools/tree/master/gopls
-- `go install golang.org/x/tools/gopls@latest`
setup_server("gopls", {})

-- Lua Language Server
-- `brew install lua-language-server`
setup_server("sumneko_lua", {
	settings = {
		Lua = {
			-- disable annoying text completion for cmp coming from this lsp
			-- https://github.com/hrsh7th/nvim-cmp/issues/684
			completion = {
				workspaceWord = false,
				showWord = "Disable",
			},
			-- Make the lsp recognize vim.
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
})

setup_server("sorbet", {
	cmd = { "bundle", "exec", "srb", "typecheck", "--lsp", "--enable-all-experimental-lsp-features", "/Users/jaredw/figma/figma/sinatra" },
	root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
})

null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
	},
})

-- lspsaga ui!
lspsaga.init_lsp_saga({
	-- mostly defaults
	show_outline = {
		win_position = 'right',
		-- set the special filetype in there which in left like nvimtree neotree defx
		left_with = '',
		win_width = 50,
		auto_enter = true,
		auto_preview = false,  -- turn off previews, kind annoying
		virt_text = '┃',
		jump_key = 'o',
	},
})

--------------------------------------------------------------------------------
-- Completions


cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-j>"] = cmp.mapping.select_next_item(), -- { behavior = cmp.SelectBehavior.Insert }
		["<C-k>"] = cmp.mapping.select_prev_item(), -- { behavior = cmp.SelectBehavior.Insert }
		["<C-u>"] = cmp.mapping.scroll_docs(4), -- scrolling in docs panel
		["<C-d>"] = cmp.mapping.scroll_docs(-4), -- scrolling in docs panel
		["<C-Space>"] = cmp.mapping.complete(), -- pull up all completions
		["<C-e>"] = cmp.mapping({ -- exit out of cmp
			i = cmp.mapping.abort(), -- insert mode
			c = cmp.mapping.close(), -- command mode
		}),
		-- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	-- The order of your sources matter (by default). That gives them priority you can configure:
	sources = cmp.config.sources({
		-- Could enable this only for lua, but nvim_lua handles that already.
		{ name = "nvim_lsp_signature_help" },
		{ name = "nvim_lua" },
		{ name = "nvim_lsp" },
		{ name = "path" },
		{ name = "luasnip" },
		{ name = "buffer", keyword_length = 5 },
	}),
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol", -- show only symbol annotations
			maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
		}),
	},
})

-- Type /@ to search for symbols in document
-- I think I'd prefer telescope versus this
-- cmp.setup.cmdline("/", {
-- 	sources = cmp.config.sources({
-- 		{ name = "nvim_lsp_document_symbol" },
-- 	}),
-- })

--------------------------------------------------------------------------------
-- Tab Settings

local function echoerr(msg)
	vim.cmd("echohl WarningMsg")
	vim.cmd(string.format("echomsg '%s'", msg))
	vim.cmd("echohl None")
end

local function require_key(t, key)
	local value = t[key]
	if value == nil then
		echoerr(key .. " unset")
	end
	return value
end

-- filetype [String] cpp|go|java|...
-- use_tabs [Boolean] true|false
-- indent_size [Integer] 2-8
local function set_tab_settings(t)
	local filetype = require_key(t, "filetype")
	local use_tabs = require_key(t, "use_tabs")
	local indent_size = require_key(t, "indent_size")

	local expandtab
	local shiftwidth
	local softtabstop

	-- shiftwidth: Number of spaces to use for each step of (auto)indent.
	-- softtabstop: Number of spaces that a <Tab> counts for while performing editing operations, like inserting a <Tab> or using <BS>.
	if use_tabs then
		expandtab = "noexpandtab"
		shiftwidth = indent_size
		softtabstop = 0
	else
		expandtab = "expandtab"
		shiftwidth = indent_size
		softtabstop = indent_size
	end
	local command = string.format("setlocal shiftwidth=%d softtabstop=%d %s", shiftwidth, softtabstop, expandtab)
	vim.api.nvim_create_autocmd("FileType", { pattern = filetype, command = command })
end

set_tab_settings({ filetype = "bzl", use_tabs = false, indent_size = 4 })
set_tab_settings({ filetype = "c", use_tabs = true, indent_size = 8 })
set_tab_settings({ filetype = "cpp", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "elixir", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "go", use_tabs = true, indent_size = 8 })
set_tab_settings({ filetype = "haskell", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "hcl", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "html", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "java", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "javascript", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "json", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "kotlin", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "lua", use_tabs = true, indent_size = 8 })
set_tab_settings({ filetype = "markdown", use_tabs = false, indent_size = 4 })
set_tab_settings({ filetype = "ocaml", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "python", use_tabs = false, indent_size = 4 })
set_tab_settings({ filetype = "ruby", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "sql", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "terraform", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "thrift", use_tabs = false, indent_size = 4 })
set_tab_settings({ filetype = "typescript", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "typescriptreact", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "xml", use_tabs = false, indent_size = 2 })
set_tab_settings({ filetype = "toml", use_tabs = false, indent_size = 2 })
