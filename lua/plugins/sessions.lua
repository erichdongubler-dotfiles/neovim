vim.opt.sessionoptions:append("folds")
vim.opt.sessionoptions:append("globals")
vim.opt.sessionoptions:append("localoptions")
vim.opt.sessionoptions:append("tabpages")
vim.opt.sessionoptions:append("terminal")
vim.opt.sessionoptions:append("winpos")
vim.opt.sessionoptions:remove("options")

return {
	"rmagatti/auto-session",
	cond = not vim.g.started_by_firenvim,
	dependencies = {
		"snacks.nvim",
	},
	opts = {
		git_use_branch_name = true,
		session_lens = {
			picker = "snacks",
		},
	},
}
