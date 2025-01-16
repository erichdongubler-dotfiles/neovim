vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.cmd("hi! link Search Underlined")

map("", "<Leader>h", ":%s/", { desc = "Search and replace in buffer…" })
map("v", "<Leader>h", ":s/", { desc = "Search and replace in visual range…" })
map("", "<Leader>g", ":%g/", { desc = "Search and replace in buffer…" })
map("v", "<Leader>g", ":g/", { desc = "Search and replace in visual range…" })

return {
	{
		"haya14busa/is.vim",
		event = "VeryLazy",
	},
	{
		"haya14busa/vim-asterisk",
		event = "VeryLazy",
		requires = {
			"is.vim", -- for `is-nohl-1`
		},
		config = function(_, opts)
			local bindings = {
				["*"] = {
					"<Plug>(asterisk-z*)<Plug>(is-nohl-1)",
					"Begin search forward (no initial move)",
				},
				["g*"] = {
					"<Plug>(asterisk-gz*)<Plug>(is-nohl-1)",
					"Begin search forward (no initial move)",
				},
				["#"] = {
					"<Plug>(asterisk-z#)<Plug>(is-nohl-1)",
					"Begin search  (no initial move)",
				},
				["g#"] = {
					"<Plug>(asterisk-gz#)<Plug>(is-nohl-1)",
					"Begin search  (no initial move)",
				},
			}
			for lhs, obj in pairs(bindings) do
				noremap("", lhs, obj[1], { desc = obj[2] })
			end
		end,
	},

	{
		"dyng/ctrlsf.vim",
		event = "VeryLazy",
		setup = function()
			vim.g.ctrlsf_auto_focus = { at = "start" }
			vim.api.nvim_set_keymap("n", "<Leader>H", ":CtrlSF<Space>", { noremap = true })
			vim.g.ctrlsf_indent = 2
			vim.g.ctrlsf_search_mode = "async"
		end,
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		dependencies = {
			"which-key.nvim",
		},
		---@type snacks.Config
		opts = {
			picker = { enabled = true },
		},
		config = function(_, opts)
			local snacks = require("snacks")
			snacks.setup(opts)
			local which_key = require("which-key")
			which_key.add({
				{
					"<Leader>D",
					snacks.picker.diagnostics,
					desc = "Fuzzy-find diagnostics",
				},
				{ "<Leader>O", snacks.picker.buffers, desc = "Fuzzy-find buffers by name" },
				{ "<Leader>T", bind_fuse(snacks.picker), desc = "Fuzzy-find `snack.picker`s" },
				{
					"<Leader>d",
					snacks.picker.diagnostics_buffer,
					desc = "Fuzzy-find diagnostics (current buffer only)",
				},
				{ "<Leader>f", snacks.picker.grep, desc = "Fuzzy-find with live word search" },
				{ "<Leader>o", snacks.picker.recent, desc = "Fuzzy-find recent files" },
				{
					"<Leader>p",
					snacks.picker.files,
					desc = "Fuzzy-find with `snacks.picker.files`",
				},
				{ "<Leader>l<C-]>", snacks.picker.lsp_definitions, desc = "Fuzzy-find LSP definitions" },
				{ "<Leader><F12>", snacks.picker.lsp_definitions, desc = "Fuzzy-find LSP definitions" },
				{ "<Leader>lgd", snacks.picker.lsp_definitions, desc = "Fuzzy-find LSP definitions" },
				{
					"<Leader>lR",
					snacks.picker.lsp_symbols,
					desc = "Fuzzy-find `builtin.lsp_symbols`",
				},
				{ "<Leader>lgi", snacks.picker.lsp_implementations, desc = "Fuzzy-find LSP implementations" },
				{ "<Leader>lgr", snacks.picker.lsp_references, desc = "Fuzzy-find LSP references" },
				{ "<Leader><M-S-F12>", snacks.picker.lsp_references, desc = "Fuzzy-find LSP references" },
				{ "<Leader>lgt", snacks.picker.lsp_type_definitions, desc = "Fuzzy-find LSP type definitions" },
				{ "<Leader>lr", snacks.picker.lsp_symbols, desc = "Fuzzy-find LSP document symbols" },
				{
					"<Leader>lR",
					snacks.picker.lsp_workspace_symbols,
					desc = "Fuzzy-find LSP document symbols (workspace)",
				},
				{ "<Leader><F2>", snacks.picker.help, desc = "Fuzzy-find `help` tags" },
				{
					"<Leader>r",
					bind_fuse(snacks.picker.tags, { workspace = false }),
					desc = "Fuzzy-find LSP document symbols",
				},
				{
					"<Leader>R",
					snacks.picker.tags,
					desc = "Fuzzy-find LSP document symbols (workspace)",
				},
			})
		end,
	},
}
