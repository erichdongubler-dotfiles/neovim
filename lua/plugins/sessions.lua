vim.opt.sessionoptions:remove("options")
vim.opt.sessionoptions:append("tabpages")
vim.opt.sessionoptions:append("globals")

return {
	"dhruvasagar/vim-prosession",
	dependencies = {
		"tpope/vim-obsession",
		"vim-fugitive", -- required for `prosession_per_branch`
	},
	init = function()
		vim.g.prosession_per_branch = 1
	end,
}
-- TODO: fuzzy session selection?
