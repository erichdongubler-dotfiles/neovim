return {
	{
		"glacambre/firenvim",
		cond = not not vim.g.started_by_firenvim,
		build = function()
			require("lazy").load({ plugins = "firenvim", wait = true })
			vim.fn["firenvim#install"](0)
		end,
		init = function()
			vim.g.firenvim_config = {
				localSettings = {
					[".*"] = { takeover = "never" },
				},
			}
		end,
		config = function()
			augroup("Firenvim", function(au)
				au("BufEnter", {
					"github.com_*.txt",
					"bugzilla.mozilla.org_show-bug-cgi_TEXTAREA-id-comment_*.txt",
				}, function()
					vim.bo.filetype = "markdown"
				end)
				-- au({ "TextChanged", "TextChangedI" }, "*", function()
				-- 	if vim.g.timer_started == true then
				-- 		return
				-- 	end
				-- 	vim.g.timer_started = true
				-- 	-- TODO: restart timer if necessary using returned timer ID
				-- 	vim.fn.timer_start(10000, function()
				-- 		vim.g.timer_started = false
				-- 		vim.cmd.write()
				-- 	end)
				-- end)
			end)
		end,
	},
}
