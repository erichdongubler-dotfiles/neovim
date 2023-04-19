function set_listchars(shiftwidth, verbose)
	local listchars = verbose
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

	local opts_short = vim.o
	local opts_long = vim.opt
	-- vim.notify(
	--	"Refreshing listchars (local: "
	--		.. tostring(for_local)
	--		.. ", `shiftwidth`: "
	--		.. shiftwidth
	--		.. ") on "
	--		.. tostring(vim.inspect(opts_short))
	--		.. tostring(vim.inspect(opts_long))
	-- )
	opts_short.list = true
	opts_short.listchars = ""
	opts_long.listchars = listchars
end
_G.set_listchars = set_listchars

local is_indentation_verbose = false
function refresh_listchars()
	set_listchars(vim.o.shiftwidth, is_indentation_verbose)
end
function toggle_list_verbosity()
	if is_indentation_verbose then
		vim.notify("quieting `listchars`")
		is_indentation_verbose = false
	else
		vim.notify("verbosifying `listchars`")
		is_indentation_verbose = true
	end
	refresh_listchars()
end

augroup("RefreshListCharsOnShiftWidthChange", function(au)
	au("OptionSet", "shiftwidth,tabstop,softtabstop", function()
		refresh_listchars(vim.v.option_type ~= "global")
	end)
end)
refresh_listchars()
-- command("RefreshListChars", function()
-- 	refresh_listchars(true)
-- 	-- refresh_listchars(false)
-- end, { nargs = 0 })

return {}
