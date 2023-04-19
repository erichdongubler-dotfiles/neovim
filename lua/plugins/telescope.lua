return {
	"nvim-telescope/telescope.nvim",
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
		which_key.register({
			["D"] = { builtin.diagnostics, "Fuzzy-find diagnostics" },
			["O"] = { builtin.buffers, "Fuzzy-find `builtin.buffers`" },
			["R"] = { builtin.tags, "Fuzzy-find `builtin.tags`" },
			["T"] = { builtin.builtin, "Fuzzy-find `builtin.builtin`" },
			["d"] = {
				function()
					builtin.diagnostics({ bufnr = 0 })
				end,
				"Fuzzy-find diagnostics (current buffer only)",
			},
			["f"] = { builtin.live_grep, "Fuzzy-find `builtin.live_grep`" },
			["o"] = { builtin.oldfiles, "Fuzzy-find `builtin.oldfiles`" },
			["p"] = { builtin.find_files, "Fuzzy-find `builtin.find_files`" },
			["l<C-]>"] = { builtin.lsp_definitions, "Fuzzy-find `builtin.lsp_definitions`" },
			["<F12>"] = { builtin.lsp_definitions, "Fuzzy-find `builtin.lsp_definitions`" },
			["lR"] = { builtin.lsp_dynamic_workspace_symbols, "Fuzzy-find `builtin.lsp_dynamic_workspace_symbols`" },
			["la"] = { vim.lsp.buf.code_action, "Fuzzy-find `vim.lsp.buf.code_action`" },
			["lgd"] = { builtin.lsp_definitions, "Fuzzy-find `builtin.lsp_definitions`" },
			["lgi"] = { builtin.lsp_implementations, "Fuzzy-find `builtin.lsp_implementations`" },
			["lgr"] = { builtin.lsp_references, "Fuzzy-find `builtin.lsp_references`" },
			["<M-S-F12>"] = { builtin.lsp_references, "Fuzzy-find `builtin.lsp_references`" },
			["lgt"] = { builtin.lsp_type_definitions, "Fuzzy-find `builtin.lsp_type_definitions`" },
			["lr"] = { builtin.lsp_document_symbols, "Fuzzy-find `builtin.lsp_document_symbols`" },
			["r"] = { builtin.current_buffer_tags, "Fuzzy-find `builtin.current_buffer_tags`" },
			["<F2>"] = { builtin.help_tags, "Fuzzy-find `builtin.help_tags`" },
		}, { prefix = "<Leader>" })
		which_key.register({
			["<Leader>la"] = { bind_fuse(vim.lsp.buf.code_action), "Fuzzy-find code action(s) in selection" },
		}, { mode = "v", prefix = "<Leader>" })
	end,
}
