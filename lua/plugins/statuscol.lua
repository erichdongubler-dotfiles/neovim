return {
	"luukvbaal/statuscol.nvim",
	init = function()
		vim.opt.number = true
	end,
	config = function()
		local builtin = require("statuscol.builtin")
		require("statuscol").setup({
			relculright = true,
			segments = {
				{
					sign = { name = { "Diagnostic" }, maxwidth = 2, auto = true },
					click = "v:lua.ScSa",
				},
				{
					sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true },
					click = "v:lua.ScSa",
				},
				{ text = { builtin.foldfunc }, click = "v:lua.ScFa" },
				{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
			},
		})
	end,
}
