return {
	{
		"luukvbaal/statuscol.nvim",
		init = function()
			vim.opt.number = true
		end,
		config = function()
			local builtin = require("statuscol.builtin")
			require("statuscol").setup({
				relculright = true,
			})
		end,
	},
}
