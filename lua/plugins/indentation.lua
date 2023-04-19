-- TODO: Does this actually work?
if vim.g.erichdongubler_initted_indent_opts == nil then
	vim.opt.backspace = "indent,eol,start"
	vim.opt.shiftwidth = 4
	vim.opt.softtabstop = 4
	vim.opt.tabstop = 4

	vim.g.erichdongubler_initted_indent_opts = true
end

return {
	{
		"NMAC427/guess-indent.nvim",
		event = "BufRead",
	},
	{
		"rhlobo/vim-super-retab",
		event = "VeryLazy",
	},
	{
		"junegunn/vim-easy-align",
		event = "VeryLazy",
		config = function()
			-- map("x", "ga", vim.cmd["<Plug>(EasyAlign)"])
			-- map("n", "ga", vim.cmd["<Plug>(EasyAlign)"])
		end,
	},
}
