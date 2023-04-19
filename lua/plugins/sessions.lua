vim.opt.sessionoptions:remove("options")
vim.opt.sessionoptions:append("tabpages")
vim.opt.sessionoptions:append("globals")

return {
	"dhruvasagar/vim-prosession",
	dependencies = {
		"tpope/vim-obsession",
	},
}
-- TODO: fuzzy session selection?
