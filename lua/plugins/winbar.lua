return {
	{
		"ErichDonGubler/dropbar.nvim",
		cond = not vim.g.started_by_firenvim,
		branch = "fix-outside-paths",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},
}
