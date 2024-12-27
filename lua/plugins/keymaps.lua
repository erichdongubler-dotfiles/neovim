-- Make Home go to the beginning of the indented line, not the line itself
vim.keymap.set("", "<Home>", "^")

-- Ctrl-Enter to go to a new line
map("i", "<C-CR>", "<C-o>o")
map("i", "<C-S-CR>", "<C-o>O")

-- Use Shift-Delete to delete the current line
map("n", "<S-Del>", "dd")
map("i", "<S-Del>", "<C-o>dd")
map("v", "<S-Del>", "<Del>") --…but actually just make this like VS Code.

-- Shift-Up and Shift-Down are _really_ annoying for me.
vim.keymap.set("", "<S-Up>", "<Nop>")
vim.keymap.set("", "<S-Down>", "<Nop>")

if vim.g.neovide then
	-- Get paste back
	noremap({ "", "i" }, "<C-S-V>", "<C-R>+") -- Windows/Linux

	if vim.fn.has("mac") then
		-- Fix reversed trackpad scrolling
		noremap({ "", "i" }, "<ScrollWheelLeft>", "<ScrollWheelRight>")
		noremap({ "", "i" }, "<ScrollWheelRight>", "<ScrollWheelLeft>")

		-- Make `<CMD> + v` work again.
		noremap({ "", "i" }, "<D-v>", "<C-R>+")
	end
end

noremap("n", "<Leader>ve", ":e " .. vim.fn.stdpath("config"), { desc = "Edit Neovim configuration" })
noremap("n", "<Leader>", "<cmd>qa!<CR>", { desc = "Quit (force on all windows)" })
noremap("n", "<Leader>Q", "<cmd>q!<CR>", { desc = "Quit (force on current window)" })
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
