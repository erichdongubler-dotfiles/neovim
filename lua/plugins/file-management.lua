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
		config = function(_, opts)
			require("nvim-tree").setup(opts)
			local nvim_tree_api = require("nvim-tree.api")
			local which_key = require("which-key")
			which_key.add({
				{
					"<Leader>k",
					bind_fuse(nvim_tree_api.tree.toggle, { focus = true }),
					desc = "Open file browser sidebar",
				},
				{
					"-",
					bind_fuse(nvim_tree_api.tree.find_file, { focus = true, open = true }),
					desc = "Find current file in file browser sidebar",
				},
			})
		end,
	},
	{
		"ErichDonGubler/vim-file-browser-integration",
		config = function()
			-- TODO: This sort of binding seems to happen multiple times. Maybe factoring out is
			-- interesting?
			local fb_bindings = {
				["<Leader>e"] = vim.cmd.SelectCurrentFile,
				["<Leader>x"] = vim.cmd.OpenCurrentFile,
				["<Leader>E"] = vim.cmd.OpenCWD,
			}
			for binding, cmd in pairs(fb_bindings) do
				noremap("n", binding, cmd)
			end
		end,
	},
}
