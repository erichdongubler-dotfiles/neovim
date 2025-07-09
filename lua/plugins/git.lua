return {
	"knsh14/vim-github-link",
	{
		"tpope/vim-fugitive",
		config = function(_, opts)
			noremap("n", "ghB", bind_fuse(vim.cmd.Git, "blame"), { desc = "Show `git blame`" })
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"which-key.nvim",
		},
		event = { "BufReadPost" },
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "|" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signs_staged = {
				add = { text = "+" },
				change = { text = "|" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
		},
		config = function(_, opts)
			local gitsigns = require("gitsigns")
			gitsigns.setup(opts)

			local which_key = require("which-key")
			local get_visual_range = function()
				return { vim.fn.line("."), vim.fn.line("v") }
			end
			which_key.add({
				{
					mode = { "n", "v" },
					{
						"[h",
						"&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'",
						desc = "Motion to previous hunk",
						expr = true,
						replace_keycodes = false,
					},
					{
						"]h",
						"&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'",
						desc = "Motion to next hunk",
						expr = true,
						replace_keycodes = false,
					},
				},
				{ "ghR", bind_fuse(gitsigns.reset_buffer), desc = "Restore all hunks in current file" },
				{ "ghS", bind_fuse(gitsigns.stage_buffer), desc = "Stage all hunks in current file" },
				{
					"ghU",
					bind_fuse(gitsigns.reset_buffer_index),
					desc = "Unstage all hunks in current file",
				},
				{ "ghb", bind_fuse(gitsigns.blame_line, true), desc = "Show blame for the current line" },
				{ "ghp", bind_fuse(gitsigns.preview_hunk_inline), desc = "Preview current hunk (line)" },
				{ "ghr", bind_fuse(gitsigns.reset_hunk), desc = "Restore current hunk (line)" },
				{ "ghs", bind_fuse(gitsigns.stage_hunk), desc = "Stage current hunk (line)" },
				{ "ghu", bind_fuse(gitsigns.undo_stage_hunk), desc = "Unstage current hunk (line)" },
				{
					mode = { "v" },
					{
						"ghp",
						function()
							gitsigns.preview_hunk_inline()
						end,
						desc = "Preview current hunk (range, inline)",
					},
					{
						"ghr",
						function()
							gitsigns.reset_hunk(get_visual_range())
						end,
						desc = "Reset hunk(s) in range",
					},
					{
						"ghs",
						function()
							gitsigns.stage_hunk(get_visual_range())
						end,
						desc = "Stage hunk(s) in range",
					},
					{
						"ghu",
						function()
							gitsigns.undo_stage_hunk()
						end,
						desc = "Unstage hunk(s) in range",
					},
				},
				{
					mode = { "o", "x" },
					{
						"ih",
						':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
						desc = "inner hunk",
					},
				},
			})
		end,
	},
	"sindrets/diffview.nvim",
}
