vim.opt.sessionoptions:append("folds")
vim.opt.sessionoptions:remove("options")
vim.opt.sessionoptions:append("tabpages")
vim.opt.sessionoptions:append("terminal")
vim.opt.sessionoptions:append("globals")
vim.opt.sessionoptions:append("winpos")

return {
	"rmagatti/auto-session",
	cond = not vim.g.started_by_firenvim,
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	opts = {
		auto_session_use_git_branch = true,
	},
}
