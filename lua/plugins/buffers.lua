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
	config = function(_, opts)
		require("barbar").setup(opts)
		local which_key = require("which-key")
		local cycle_next = function(binding)
			return {
				binding,
				bind_fuse(vim.cmd.BufferNext),
				desc = "Switch to tab on right",
			}
		end
		local cycle_prev = function(binding)
			return {
				binding,
				bind_fuse(vim.cmd.BufferPrevious),
				desc = "Switch to tab on left",
			}
		end
		which_key.add({
			-- Replace default bindings
			-- TODO: motion repetitions
			-- TODO: move bindings

			-- NOTE: These bracket bindings conflict with `mini.bracketed` and `vim-unimpaired` by
			-- default. Other configuration (i.e., of those plugins) should eliminate these
			-- conflicts by not mapping them in the first place.
			cycle_next("]b"),
			cycle_prev("[b"),
			{ "]B", bind_fuse(vim.cmd.BufferLast), desc = "Switch to furthest tab on right" },
			{ "[B", bind_fuse(vim.cmd.BufferFirst), desc = "Switch to furthest tab on left" },
			cycle_prev("<C-PageUp>"),
			cycle_next("<C-PageDown>"),
			{
				"<C-S-PageUp>",
				bind_fuse(vim.cmd.BufferMovePrevious),
				desc = "Move current buffer tab to the left",
			},
			{
				"<C-S-PageDown>",
				bind_fuse(vim.cmd.BufferMoveNext),
				desc = "Move current buffer tab to the right",
			},
			{ "<Leader>w", bind_fuse(vim.cmd.BufferClose), desc = "Close current buffer" },
			{
				"<Leader>W",
				bind_fuse(vim.cmd.BufferCloseAllButCurrentOrPinned),
				desc = "Close all buffers but the current one",
			},
			{
				"<Leader><Leader>f",
				bind_fuse(vim.cmd.BufferPick),
				desc = "Pick buffer to switch to with key…",
			},
		})
	end,
}
