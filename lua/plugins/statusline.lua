return {
	"hoob3rt/lualine.nvim",
	dependencies = {
		"vim-sublime-monokai",
	},
	init = function()
		vim.opt.laststatus = 3
		vim.opt.showmode = false
	end,
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
