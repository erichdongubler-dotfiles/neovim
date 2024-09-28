vim.opt.formatoptions:remove({
	"t", -- Disable hard breaks at textwidth boundary
})
-- Show soft-wrapped text with extra indent of 2 spaces
vim.opt.breakindentopt = "shift:2"
vim.opt.showbreak = "->"

function word_wrap_opts_namespace(global)
	return global and vim.o or vim.wo
end
function toggle_word_wrap(global)
	set_word_wrap(not word_wrap_opts_namespace(global).wrap, global)
end
function set_word_wrap(enabled, global)
	local opts_namespace = word_wrap_opts_namespace(global)
	opts_namespace.breakindent = enabled
	opts_namespace.linebreak = enabled
	opts_namespace.wrap = enabled
end
set_word_wrap(false, true)
command("DisableWordWrap", bind_fuse(set_word_wrap, false), { nargs = 0 })
command("EnableWordWrap", bind_fuse(set_word_wrap, true), { nargs = 0 })
noremap("n", "<Leader><Tab>", bind_fuse(toggle_word_wrap, false))
noremap("n", "<Leader><S-Tab>", bind_fuse(toggle_word_wrap, true))

-- Default max document width

-- TODO: only do this once?
vim.opt.colorcolumn = "+1"
vim.opt.formatoptions = vim.opt.formatoptions - { "l" } + { "t" }
vim.opt.textwidth = 100

function set_row_limit(textwidth)
	vim.bo.textwidth = textwidth
end
command("SetRowLimit", function(opts)
	set_row_limit(tonumber(opts.args))
end, { nargs = 1 })

return {}
