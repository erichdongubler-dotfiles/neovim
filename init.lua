local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	-- Bootstrap!
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

vim.g.number = true
vim.g.mapleader = "\\"
vim.g.maplocalleader = "|"

function _G.bind_fuse(func, ...)
	local args = { ... }
	return function()
		func(unpack(args))
	end
end

function _G.command(name, command, opts)
	opts = opts or {}
	vim.api.nvim_create_user_command(name, command, opts)
end

_G.map = vim.keymap.set

function _G.noremap(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	map(mode, lhs, rhs, options)
end

function _G.augroup(name, callback)
	local augroup_id = vim.api.nvim_create_augroup(name, {})
	function au(name, patterns, cmd)
		local args = { pattern = patterns, group = augroup_id }
		if type(cmd) == "string" then
			args.command = cmd
		else
			args.callback = cmd
		end
		vim.api.nvim_create_autocmd(name, args)
	end
	callback(au, augroup_id) -- TODO: reorder?
end

require("lazy").setup({
	spec = {
		import = "plugins",
	},
	dev = {
		path = "~/workspace/erichdongubler-dotfiles/neovim",
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				-- "matchit",
				-- "matchparen",
				-- "netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
