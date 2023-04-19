--   rvxt bindings

vim.keymap.set("", "<Esc>Oa", "<C-Up")
vim.keymap.set("", "<Esc>Ob", "<C-Down")
vim.keymap.set("", "<Esc>Oc", "<C-Right")
vim.keymap.set("", "<Esc>Od", "<C-Left")
vim.keymap.set("", "<Esc>[5^", "<C-PageUp")
vim.keymap.set("", "<Esc>[6^", "<C-PageDown>")

return {
	{
		"folke/which-key.nvim",
		config = function(_, opts)
			local which_key = require("which-key")
			which_key.setup(opts)

			which_key.register({
				["ve"] = {
					":e " .. vim.fn.stdpath("config"),
					"Edit Neovim configuration",
				},
			}, { prefix = "<Leader>", silent = false })
			which_key.register({
				[""] = { vim.cmd["qa!"], "Quit (force on all windows)" },
				["Q"] = { vim.cmd["q!"], "Quit (force on current window)" },
				["q"] = { vim.cmd.q, "Quit" },

				["s"] = { vim.cmd.w, "Write to file" },

				["0"] = { ":Inspect<CR>", "Inspect current items at cursor (i.e., highlights)" },
			}, { prefix = "<Leader>" })
		end,
	},
}
