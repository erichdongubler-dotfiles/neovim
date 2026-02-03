return {
	{
		"nvim-orgmode/orgmode",
		event = "VeryLazy",
		ft = { "org" },
		config = function()
			local orgfiles_root = "~/Downloads/Sync/erichdongubler/documents/orgfiles"
			require("orgmode").setup({
				input = {
					use_vim_ui = true,
				},
				mappings = {
					prefix = "go",
				},
				org_agenda_files = orgfiles_root .. "/**/*",
				org_default_notes_file = orgfiles_root .. "/refile.org",
			})
			vim.lsp.enable("org")
		end,
	},
}
