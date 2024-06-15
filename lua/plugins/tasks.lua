return {
	{
		"stevearc/overseer.nvim",
		event = "VeryLazy",
		dependencies = {
			"telescope.nvim",
		},
		opts = {},
		config = function(_, opts)
			local overseer = require("overseer")
			overseer.setup(opts)
			noremap("n", "<Leader>jt", bind_fuse(overseer.toggle))
			noremap("n", "<Leader>jr", "<cmd>OverseerRun<CR>")
		end,
	},
}
