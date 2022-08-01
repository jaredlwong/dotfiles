local wk = require("which-key")
wk.setup({})

wk.register({
	g = {
		name = "+Global",
		d = { vim.lsp.buf.definition, "go to definition" },
		D = { vim.lsp.buf.declaration, "go to declaration" },
		T = { vim.lsp.buf.type_definition, "go to type definition" },
	},
}, {
	mode = "n", -- NORMAL mode
	prefix = "",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = false, -- use `nowait` when creating keymaps
})

-- visual mode
wk.register({ga = {"<Plug>(EasyAlign)", "Align", mode = "x"}})

local normal_leader_opts = {
	mode = "n", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = false, -- use `nowait` when creating keymaps
}

-- https://github.com/thuan1412/vim-config/blob/55667cec5de95cfb0d6c2cf40ea84701067bfb6c/lua/pl-which-key.lua
-- https://github.com/yosink/learn-neovim-lua/blob/de6e98337a112947f9450619b932ac8a03d91b75/lua/plugin-config/which-key.lua
wk.register({
	c = {
		name = "+Commands",
		l = {
			require("stylua-nvim").format_file,
			"format lua",
		},
		c = { "<cmd>Cheatsheet<cr>", "cheatsheet" },
	},
	e = { "<cmd>NvimTreeToggle<cr>", "Toogle Tree" },
	E = {
		name = "+explorer (nvim tree)",
		f = { "<cmd>NvimTreeFindFile<cr>", "Find current file" },
		c = { "<cmd>NvimTreeCollapse<cr>", "Collapse" },
	},

	f = {
		name = "+find",
		b = { "<cmd>Telescope buffers<cr>", "buffers" },
		["."] = {
			function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
			end,
			"find files in current file dir",
		},
		c = { "<cmd>Telescope commands<cr>", "commands" },
		C = { "<cmd>Telescope command_history<cr>", "history" },
		f = { "<cmd>Telescope find_files<cr>", "find_files (cwd)" },
		g = { "<cmd>Telescope live_grep<cr>", "grep (live_grep)" },
		p = { "<cmd>Telescope git_files<cr>", "project files (.git)" },
		h = { "<cmd>Telescope oldfiles<cr>", "oldfiles" },
		o = { "<cmd>Telescope file_browser<cr>", "open file_browser" },
		r = { "<cmd>Telescope frecency<cr>", "frecency (recent)" },
		w = { "<cmd>Telescope grep_string<cr>", "grep word under (cwd)" },
		s = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "search current buffer" },
		S = { "<cmd>Telescope search_history<cr>", "search_history" },
		t = { "<cmd>TodoTelescope<cr>", "todos!" },
	},

	-- https://github.com/thuan1412/vim-config/blob/55667cec5de95cfb0d6c2cf40ea84701067bfb6c/lua/pl-which-key.lua
	-- https://github.com/yosink/learn-neovim-lua/blob/de6e98337a112947f9450619b932ac8a03d91b75/lua/plugin-config/which-key.lua
	l = {
		name = "+LSP",
		D = { vim.lsp.buf.declaration, "go to declaration" },
		f = { vim.lsp.buf.formatting, "Format" },
		h = { vim.lsp.buf.hover, "Hover" },

		d = { "<cmd>Telescope lsp_definitions<cr>", "(t) go to definition" },
		i = { "<cmd>Telescope lsp_implementations<cr>", "(t) implementations" },
		r = { "<cmd>Telescope lsp_references<cr>", "(t) references symbol under cursor" },
		s = { "<cmd>Telescope lsp_document_symbols sorting_strategy=ascending<cr>", "(t) symbols in current buffer" },
		S = { "<cmd>Telescope lsp_workspace_symbols<cr>", "(t) workspace symbols" },
		t = { "<cmd>Telescope treesitter<cr>", "(t) treesitter" },
		T = { "<cmd>Telescope lsp_type_definitions<cr>", "(t) go to type definition" },
		w = { "<cmd>Telescope diagnostics<cr>", "(t) diagnostics" },
		W = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "(t) lsp_dynamic_workspace_symbols" },
	},

	p = {
		name = "+possession (sessions)",
		l = { require("telescope").extensions.possession.list, "list" },
		s = { "<cmd>PossessionSave<cr>", "save" },
		o = { "<cmd>PossessionLoad<cr>", "open" },
		c = { "<cmd>PossessionClose<cr>", "close" },
		d = { "<cmd>PossessionDelete<cr>", "delete" },
		S = { "<cmd>PossessionShow<cr>", "show" },
		L = { "<cmd>PossessionList<cr>", "list (non telescope)" },
		m = { "<cmd>PossessionMigrate<cr>", "migrate" },
	},

	-- this is just # or *, remap those if you really want it again
	-- s = { "viwy/<C-R>0<CR>N", "Search for word in current file" },
	s = {
		name = "+lspsaga",
		a = { "<cmd>Lspsaga code_action<CR>", "code_action" },
		A = { "<cmd>Lspsaga range_code_action<CR>", "selection_action" },
		d = { "<cmd>Lspsaga show_line_diagnostics<CR>", "show_line_diagnostics" },
		h = { "<cmd>Lspsaga hover_doc<CR>", "hover_doc" },
		l = { "<cmd>Lspsaga lsp_finder<CR>", "lsp_finder" },
		o = { "<cmd>LSoutlineToggle<CR>", "outline" },
		p = { "<cmd>Lspsaga preview_definition<CR>", "Preview symbol definition" },
		r = { "<cmd>Lspsaga rename<CR>", "Rename symbol" },
		s = { "<cmd>Lspsaga signature_help<CR>", "signature_help" },
	},

	t = {
		name = "+tabs",
		n = { "<cmd>tabnew<cr>", "Create New Tab" },
		x = { "<cmd>tabclose<cr>", "Close Tab" },
		h = { "<cmd>tabprevious<cr>", "Previous Tab" },
		l = { "<cmd>tabnext<cr>", "Next Tab" },
	},

	v = {
		name = "+view (vim)",
		a = { "<cmd>Telescope colorscheme<cr>", "colorscheme" }, -- a for art?
		e = { "<cmd>execute 'e '. resolve(expand($MYVIMRC))<CR>", "Open nvimrc" },
		j = { "<cmd>Telescope jumplist<cr>", "jumplist" },
		l = { "<cmd>Telescope loclist<cr>", "loclist" },
		m = { "<cmd>Telescope man_pages<cr>", "man_pages" },
		M = { "<cmd>Telescope marks<cr>", "marks" },
		o = { "<cmd>execute 'e '. resolve(expand($MYVIMRC))<CR>", "Open nvimrc" },
		p = { "<cmd>Telescope pickers<cr>", "pickers" },
		q = { "<cmd>Telescope quickfix<cr>", "quickfix" },
		Q = { "<cmd>Telescope quickfixhistory<cr>", "quickfixhistory" },
		r = { "<cmd>Telescope registers<cr>", "registers" },

		-- G = { '<cmd>Telescope tags<cr>', 'Tags' },

		-- l = { '<cmd>lua require("legendary").find()<cr>', 'Legendary' },
		-- n = { "<cmd>Telescope node_modules list<cr>", "Node modules" },
		-- t = { '<cmd>TroubleToggle<cr>', 'Trouble window' },
		-- S = { '<cmd>Telescope session-lens search_session<cr>', 'Show sessions' },
		-- T = { '<cmd>TodoTelescope<cr>', 'Todo window' },
	},
}, normal_leader_opts)

-- Visual-mode range formatting
wk.register({
	l = {
		name = "+LSP",
		f = { vim.lsp.buf.range_formatting, "Format range", mode = "v" },
	},
}, {
	mode = "v",
	prefix = "<leader>",
})
