augroup("ErichDonGublerYank", function(au)
	au("TextYankPost", "*", bind_fuse(vim.highlight.on_yank), { silent = true })
end)

return {
	{
		"AckslD/nvim-neoclip.lua",
		event = "VeryLazy",
		dependencies = {
			"kkharji/sqlite.lua",
			"telescope.nvim",
			"which-key.nvim",
		},
		opts = {
			enable_persistent_history = true,
		},
		config = function(_, opts)
			require("neoclip").setup(opts)
			require("telescope").load_extension("neoclip")
			local which_key = require("which-key")
			which_key.register({
				['<Leader>"'] = {
					bind_fuse(vim.cmd["Telescope"], "neoclip"),
					"Replace unnamed register with fuzzy history selection",
				},
				['<Leader><Leader>"'] = {
					":Telescope neoclip ",
					"Replace register with fuzzy history selection (prompt)",
					silent = false,
				},
			})
		end,
	},
}
