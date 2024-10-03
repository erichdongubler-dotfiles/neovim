vim.opt.splitkeep = "screen"

-- Create a VSCode-like tab bar.
return {
	{
		"romgrk/barbar.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"vim-sublime-monokai",
			-- "vim-sublime-monokai",
			-- "vim-unimpaired", -- conflicts with `]b`-ish bindings
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		opts = {
			auto_hide = vim.g.started_by_firenvim,
			focus_on_close = "left",
			icons = {
				button = "⤬",
				diagnostics = {
					[vim.diagnostic.severity.ERROR] = { enabled = true, icon = "🛇 " },
					[vim.diagnostic.severity.WARN] = { enabled = true },
				},
			},
		},
		event = "VeryLazy",
		keys = {
			-- Replace default bindings
			-- TODO: motion repetitions
			-- TODO: move bindings

			{ "[b", "<cmd>BufferPrevious<CR>", desc = "Switch to tab on left" },
			{ "]b", "<cmd>BufferNext<CR>", desc = "Switch to tab on right" },
			{ "[B", bind_fuse(vim.cmd.BufferFirst), desc = "Switch to furthest tab on left" },
			{ "]B", bind_fuse(vim.cmd.BufferLast), desc = "Switch to furthest tab on right" },
			{ "<C-PageUp>", "<cmd>BufferPrevious<CR>", desc = "Switch to tab on right" },
			{ "<C-PageDown>", "<cmd>BufferNext<CR>", desc = "Switch to tab on right" },
			{ "<C-S-PageUp>", "<cmd>BufferMovePrevious<CR>", desc = "Switch to tab on right" },
			{ "<C-S-PageDown>", "<cmd>BufferMoveNext<CR>", desc = "Switch to tab on right" },
			{ "[b", "<cmd>BufferPrevious<CR>", desc = "Switch to tab on left" },
			{ "<Leader>w", "<cmd>BufferClose<CR>", desc = "Close current buffer" },
			{
				"<Leader>W",
				"<cmd>BufferCloseAllButCurrentOrPinned<CR>",
				desc = "Close all buffers but the current one",
			},
			{ "<Leader><Leader>f", "<cmd>BufferPick<CR>", desc = "Pick buffer to switch to with key…" },
		},
	},
}
