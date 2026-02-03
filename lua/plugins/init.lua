return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "folke/neoconf.nvim" },
	{ "stevearc/dressing.nvim", event = "VeryLazy" },
	{ "nvim-tree/nvim-web-devicons", lazy = true },
}
