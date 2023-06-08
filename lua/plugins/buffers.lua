-- Create a VSCode-like tab bar.
return {
	"akinsho/bufferline.nvim",
	version = "v3.*",
	dependencies = {
		{
			"famiu/bufdelete.nvim",
			dependencies = {
				"which-key.nvim",
			},
			config = function(_, opts)
				require("which-key").register({ ["<Leader>w"] = { vim.cmd.Bwipeout, "Close current buffer" } })
			end,
		},
		"nvim-tree/nvim-web-devicons",
		"vim-sublime-monokai",
		"which-key.nvim",
		-- "vim-sublime-monokai",
		-- "vim-unimpaired", -- conflicts with `]b`-ish bindings
	},
	config = function()
		local bufferline = require("bufferline")
		bufferline.setup({
			options = {
				buffer_close_icon = "⤬",
				close_command = function(bufnum)
					require("bufdelete").bufwipeout(bufnum)
				end,
				close_icon = "⤬",
				diagnostics = "nvim_lsp",
				separator_style = "slant",
			},
		})
		local which_key = require("which-key")
		local bufferline = require("bufferline")
		local cycle_next = {
			function()
				bufferline.cycle(1)
			end,
			"Switch to tab on right",
		}
		local cycle_prev = {
			function()
				bufferline.cycle(-1)
			end,
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
			["<Leader>W"] = {
				function()
					bufferline.close_in_direction("left")
					bufferline.close_in_direction("right")
				end,
				"Close all buffers but the current one",
			},
		})
	end,
}
