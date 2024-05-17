local is_indentation_verbose = false
function refresh_listchars(is_local)
	local shiftwidth = is_local and vim.bo.shiftwidth or vim.o.shiftwidth
	local listchars = is_indentation_verbose
			and {
				eol = "$",
				extends = ">",
				lead = "·",
				leadmultispace = "∘" .. string.rep("·", shiftwidth - 1),
				nbsp = "⊘",
				precedes = "<",
				space = "·",
				tab = "├─",
				trail = "~",
			}
		or {
			extends = ">",
			lead = "·",
			leadmultispace = "·" .. string.rep(" ", shiftwidth - 1),
			precedes = "<",
			tab = "┆ ",
			trail = "·",
		}

	local list_opts_short = is_local and vim.wo or vim.o
	local listchars_opts_short = is_local and vim.wo or vim.o
	local listchars_opts_long = is_local and vim.opt_local or vim.opt
	list_opts_short.list = true
	listchars_opts_short.listchars = ""
	listchars_opts_long.listchars = listchars
end
function toggle_list_verbosity(is_local)
	if is_indentation_verbose then
		vim.notify("quieting `listchars`; `is_local`: " .. vim.inspect(is_local))
		is_indentation_verbose = false
	else
		vim.notify("verbosifying `listchars`; `is_local`: " .. vim.inspect(is_local))
		is_indentation_verbose = true
	end
	refresh_listchars(is_local)
end

augroup("RefreshListCharsOnOptsChange", function(au)
	au("OptionSet", "shiftwidth,tabstop,softtabstop", function()
		refresh_listchars(vim.v.option_type ~= "global")
	end)
end)
command("RefreshListChars", function()
	refresh_listchars(true)
end, { nargs = 0 })

-- TODO: Does this actually work?
if vim.g.erichdongubler_initted_indent_opts == nil then
	vim.opt.shiftwidth = 4
	vim.opt.softtabstop = 4
	vim.opt.tabstop = 4
	refresh_listchars(true)

	vim.g.erichdongubler_initted_indent_opts = true
end

return {
	{
		"NMAC427/guess-indent.nvim",
		opts = {},
		config = function(_, opts)
			local guess_indent = require("guess-indent")
			guess_indent.setup(opts)
			local run_guess_indent = bind_fuse(guess_indent.set_from_buffer, "auto_cmd")
			local run_guess_indent = function()
				-- TODO: figure out if there's a way we can represent `silent!` in Lua
				vim.cmd([[
				silent! lua require("guess_indent").set_from_buffer("auto_cmd")
				silent! RefreshListChars
				]])
				-- guess_indent.set_from_buffer("auto_cmd")
				-- refresh_listchars(true)
			end
			-- This `augroup` definition is taken from upstream, but modified to include
			-- `refresh_listchars`.
			augroup("RefreshListCharsOnIndentChange", function(au, augroup_id)
				au("BufReadPost", "*", run_guess_indent)
				au("BufNewFile", "*", function(event)
					vim.api.nvim_create_autocmd("BufWritePost", {
						buffer = event.buf,
						group = augroup_id,
						callback = run_guess_indent,
						once = true,
					})
				end)
			end)
		end,
	},
	{
		"rhlobo/vim-super-retab",
		event = "VeryLazy",
	},
}
