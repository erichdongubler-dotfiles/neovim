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
}
