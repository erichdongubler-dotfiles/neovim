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
			vim.opt.laststatus = 0
		end,
		config = function()
			augroup("Firenvim", function(au)
				au("BufEnter", {
					"github.com_*.txt",
					"bugzilla.mozilla.org_show-bug-cgi_TEXTAREA-id-comment_*.txt",
				}, function()
					vim.bo.filetype = "markdown"
				end)
				local timer = vim.uv.new_timer()
				if timer then
					au({ "TextChanged", "TextChangedI" }, "*", function()
						timer:start(
							1000,
							0,
							vim.schedule_wrap(function()
								vim.cmd("silent! w")
							end)
						)
					end)
				end
			end)
		end,
	},
}
