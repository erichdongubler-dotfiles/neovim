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
		"snacks.nvim",
	},
	opts = {
		git_use_branch_name = true,
		session_lens = {
			-- NOTE: autodetect order is telescope -> fzf -> snacks -> select, so
			-- picking `snacks` has to be explicit. `load_on_setup` is
			-- telescope-only, and warns on every startup if left on alongside
			-- any other picker.
			picker = "snacks",
			load_on_setup = false,
		},
	},
}
