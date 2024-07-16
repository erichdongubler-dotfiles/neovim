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
		"nvim-telescope/telescope.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"which-key.nvim",
		},
		config = function()
			local actions = require("telescope.actions")
			local builtin = require("telescope.builtin")
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					dynamic_preview_title = true,
					mappings = {
						n = {
							["<C-C>"] = actions.close,
						},
					},
					layout_strategy = "flex",
					path_display = { "smart" },
				},
			})
			local which_key = require("which-key")
			which_key.add({
				{ "<Leader>D", builtin.diagnostics, desc = "Fuzzy-find diagnostics" },
				{ "<Leader>O", builtin.buffers, desc = "Fuzzy-find `builtin.buffers`" },
				{ "<Leader>R", builtin.tags, desc = "Fuzzy-find `builtin.tags`" },
				{ "<Leader>T", builtin.builtin, desc = "Fuzzy-find `builtin.builtin`" },
				{
					"<Leader>d",
					function()
						builtin.diagnostics({ bufnr = 0 })
					end,
					desc = "Fuzzy-find diagnostics (current buffer only)",
				},
				{ "<Leader>f", builtin.live_grep, desc = "Fuzzy-find `builtin.live_grep`" },
				{ "<Leader>o", builtin.oldfiles, desc = "Fuzzy-find `builtin.oldfiles`" },
				{ "<Leader>p", builtin.find_files, desc = "Fuzzy-find `builtin.find_files`" },
				{ "<Leader>l<C-]>", builtin.lsp_definitions, desc = "Fuzzy-find `builtin.lsp_definitions`" },
				{ "<Leader><F12>", builtin.lsp_definitions, desc = "Fuzzy-find `builtin.lsp_definitions`" },
				{
					"<Leader>lR",
					builtin.lsp_dynamic_workspace_symbols,
					desc = "Fuzzy-find `builtin.lsp_dynamic_workspace_symbols`",
				},
				{ "<Leader>la", vim.lsp.buf.code_action, desc = "Fuzzy-find `vim.lsp.buf.code_action`" },
				{ "<Leader>lgd", builtin.lsp_definitions, desc = "Fuzzy-find `builtin.lsp_definitions`" },
				{ "<Leader>lgi", builtin.lsp_implementations, desc = "Fuzzy-find `builtin.lsp_implementations`" },
				{ "<Leader>lgr", builtin.lsp_references, desc = "Fuzzy-find `builtin.lsp_references`" },
				{ "<Leader><M-S-F12>", builtin.lsp_references, desc = "Fuzzy-find `builtin.lsp_references`" },
				{ "<Leader>lgt", builtin.lsp_type_definitions, desc = "Fuzzy-find `builtin.lsp_type_definitions`" },
				{ "<Leader>lr", builtin.lsp_document_symbols, desc = "Fuzzy-find `builtin.lsp_document_symbols`" },
				{ "<Leader>r", builtin.current_buffer_tags, desc = "Fuzzy-find `builtin.current_buffer_tags`" },
				{ "<Leader><F2>", builtin.help_tags, desc = "Fuzzy-find `builtin.help_tags`" },
			})
			which_key.add({
				{ "<Leader>la", bind_fuse(vim.lsp.buf.code_action), desc = "Fuzzy-find code action(s) in selection" },
			}, { mode = "v" })
		end,
	},
}
