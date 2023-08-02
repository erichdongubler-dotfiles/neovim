vim.opt.splitkeep = "screen"

-- Create a VSCode-like tab bar.
return {
	"romgrk/barbar.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"vim-sublime-monokai",
		"which-key.nvim",
		-- "vim-sublime-monokai",
		-- "vim-unimpaired", -- conflicts with `]b`-ish bindings
	},
	init = function()
		vim.g.barbar_auto_setup = false
	end,
	opts = {
		focus_on_close = "left",
		icons = {
			button = "⤬",
			diagnostics = {
				[vim.diagnostic.severity.ERROR] = { enabled = true, icon = "🛇 " },
				[vim.diagnostic.severity.WARN] = { enabled = true },
			},
		},
	},
	config = function(_, opts)
		require("barbar").setup(opts)
		local which_key = require("which-key")
		local cycle_next = {
			bind_fuse(vim.cmd.BufferNext),
			"Switch to tab on right",
		}
		local cycle_prev = {
			bind_fuse(vim.cmd.BufferPrevious),
			"Switch to tab on left",
		}
		which_key.register({
			-- Replace default bindings
			-- TODO: motion repetitions
			-- TODO: move bindings
			["]b"] = cycle_next,
			["[b"] = cycle_prev,
			["<C-PageUp>"] = cycle_prev,
			["<C-PageDown>"] = cycle_next,
			["<Leader>w"] = {
				bind_fuse(vim.cmd.BufferClose),
				"Close current buffer",
			},
			["<Leader>W"] = {
				bind_fuse(vim.cmd.BufferCloseAllButCurrentOrPinned),
				"Close all buffers but the current one",
			},
		})
	end,
}
