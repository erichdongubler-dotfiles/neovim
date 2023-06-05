return {
	"tpope/vim-eunuch", -- command interface to file operations
	{ "pbrisbin/vim-mkdir", lazy = false }, -- make parent directories automatically
	{ "kopischke/vim-fetch", lazy = false }, -- handle `file:<line>:<col>`
	{ "EinfachToll/DidYouMean", lazy = false }, -- suggest files to edit on prefix match
	{
		"nvim-tree/nvim-tree.lua",
		event = "VeryLazy",
		dependencies = {
			"nvim-web-devicons",
			"which-key.nvim",
		},
		init = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
		end,
		opts = {
			renderer = {
				add_trailing = true,
				group_empty = true,
			},
		},
		config = function()
			local nvim_tree = require("nvim-tree")
			local nvim_tree_api = require("nvim-tree.api")
			local which_key = require("which-key")
			which_key.register({
				["<Leader>k"] = {
					bind_fuse(nvim_tree_api.tree.toggle, false, true),
					"Open file browser sidebar",
				},
				["-"] = {
					bind_fuse(nvim_tree_api.tree.find_file, { open = true }),
					"Find current file in file browser sidebar",
				},
			})
			nvim_tree.setup(opts)
		end,
	},
}
