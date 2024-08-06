vim.opt.sessionoptions:append("folds")
vim.opt.sessionoptions:remove("options")
vim.opt.sessionoptions:append("tabpages")
vim.opt.sessionoptions:append("terminal")
vim.opt.sessionoptions:append("globals")
vim.opt.sessionoptions:append("winpos")

return {
	"dhruvasagar/vim-prosession",
	cond = not vim.g.started_by_firenvim,
	dependencies = {
		"tpope/vim-obsession",
		"vim-fugitive", -- required for `prosession_per_branch`
	},
	init = function()
		vim.g.prosession_per_branch = 1
	end,
}
-- TODO: fuzzy session selection?
