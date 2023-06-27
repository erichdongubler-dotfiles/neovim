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
				add = { hl = "GitSignsAdd", text = "+", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
				change = {
					hl = "GitSignsChange",
					text = "|",
					numhl = "GitSignsChangeNr",
					linehl = "GitSignsChangeLn",
				},
				delete = {
					hl = "GitSignsDelete",
					text = "_",
					numhl = "GitSignsDeleteNr",
					linehl = "GitSignsDeleteLn",
				},
				topdelete = {
					hl = "GitSignsDelete",
					text = "‾",
					numhl = "GitSignsDeleteNr",
					linehl = "GitSignsDeleteLn",
				},
				changedelete = {
					hl = "GitSignsChange",
					text = "~",
					numhl = "GitSignsChangeNr",
					linehl = "GitSignsChangeLn",
				},
			},
		},
		config = function(_, opts)
			local gitsigns = require("gitsigns")
			gitsigns.setup(opts)

			local which_key = require("which-key")
			local get_visual_range = function()
				return { vim.fn.line("."), vim.fn.line("v") }
			end
			which_key.register({
				["]h"] = {
					expr = true,
					"&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'",
					"Motion to next hunk",
				},
				["[h"] = {
					expr = true,
					"&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'",
					"Motion to previous hunk",
				},
				ghR = {
					bind_fuse(gitsigns.reset_buffer),
					"Restore all hunks in current file",
				},
				ghS = {
					bind_fuse(gitsigns.stage_buffer),
					"Stage all hunks in current file",
				},
				ghU = {
					bind_fuse(gitsigns.reset_buffer_index),
					"Unstage all hunks in current file",
				},
				ghb = {
					bind_fuse(gitsigns.blame_line, true),
					"Show blame for the current line",
				},
				ghp = {
					bind_fuse(gitsigns.preview_hunk_inline),
					"Preview current hunk (line)",
				},
				ghr = {
					bind_fuse(gitsigns.reset_hunk),
					"Restore current hunk (line)",
				},
				ghs = {
					bind_fuse(gitsigns.stage_hunk),
					"Stage current hunk (line)",
				},
				ghu = {
					bind_fuse(gitsigns.undo_stage_hunk),
					"Unstage current hunk (line)",
				},
			})
			which_key.register({
				["]h"] = {
					expr = true,
					"&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'",
					"Motion to next hunk",
				},
				["[h"] = {
					expr = true,
					"&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'",
					"Motion to previous hunk",
				},
				["ghp"] = {
					function()
						gitsigns.preview_hunk_inline(get_visual_range())
					end,
					"Preview current hunk (range, inline)",
				},
				["ghr"] = {
					function()
						gitsigns.reset_hunk(get_visual_range())
					end,
					"Reset hunk(s) in range",
				},
				["ghs"] = {
					function()
						gitsigns.stage_hunk(get_visual_range())
					end,
					"Stage hunk(s) in range",
				},
				["ghu"] = {
					function()
						gitsigns.undo_stage_hunk(get_visual_range())
					end,
					"Unstage hunk(s) in range",
				},
			}, { mode = "v" })
			which_key.register({
				ih = {
					':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
					"inner hunk",
				},
			}, { mode = "o" })
			which_key.register({
				ih = {
					':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
					"inner hunk",
				},
			}, { mode = "x" })
		end,
	},
}
