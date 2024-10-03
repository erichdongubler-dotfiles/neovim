if vim.g.neovide then
	-- Get paste back
	noremap({ "", "i" }, "<C-S-V>", "<C-R>+")
end

noremap("n", "<Leader>ve", ":e " .. vim.fn.stdpath("config"), { desc = "Edit Neovim configuration" })
noremap("n", "<Leader>", vim.cmd["qa!"], { desc = "Quit (force on all windows)" })
noremap("n", "<Leader>Q", vim.cmd["q!"], { desc = "Quit (force on current window)" })
noremap("n", "<Leader>q", vim.cmd.q, { desc = "Quit" })
noremap("n", "<Leader>s", vim.cmd.w, { desc = "Write to file" })
noremap("n", "<Leader>0", vim.cmd.Inspect, { desc = "Inspect current items at cursor (i.e., highlights)" })

return {
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				hidden = true,

				-- rvxt bindings
				{ "<Esc>Oa", "<C-Up>" },
				{ "<Esc>Ob", "<C-Down>" },
				{ "<Esc>Oc", "<C-Right>" },
				{ "<Esc>Od", "<C-Left>" },
				{ "<Esc>[5^", "<C-PageUp>" },
				{ "<Esc>[6^", "<C-PageDown>" },
			},
		},
	},
}
