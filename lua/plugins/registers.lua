augroup("ErichDonGublerYank", function(au)
	au("TextYankPost", "*", bind_fuse(vim.highlight.on_yank), { silent = true })
end)

return {
	{
		"gbprod/yanky.nvim",
		event = "VeryLazy",
		dependencies = {
			"snacks.nvim",
		},
		opts = {},
		config = function(_, opts)
			require("yanky").setup(opts)
			local which_key = require("which-key")
			which_key.add({
				{
					'<Leader>"',
					bind_fuse(Snacks.picker.yanky),
					desc = "Replace unnamed register with fuzzy history selection",
				},
			})
		end,
	},
}
