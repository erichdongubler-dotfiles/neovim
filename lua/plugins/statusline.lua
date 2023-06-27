if not vim.g.started_by_firenvim then
	vim.opt.laststatus = 0
else
	vim.opt.laststatus = 3
	vim.opt.showmode = false
end
return {
	"hoob3rt/lualine.nvim",
	cond = not vim.g.started_by_firenvim,
	dependencies = {
		"vim-sublime-monokai",
	},
	opts = {
		options = {
			component_separators = "",
			section_separators = "",
			theme = "powerline",
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "filename" },
			lualine_c = { { "diagnostics", sources = { "nvim_diagnostic" } } },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	},
}
