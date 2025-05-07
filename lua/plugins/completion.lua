vim.opt.wildmode = "longest,list,full"

return {
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*", -- NOTE: keep in sync. with `blink.cmp` dep.
		event = "InsertEnter",
		build = (not jit.os:find("Windows"))
				and "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
			or nil,
		dependencies = {
			"rafamadriz/friendly-snippets",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
		keys = {
			{
				"<tab>",
				function()
					return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
				end,
				expr = true,
				silent = true,
				mode = "i",
			},
			{
				"<tab>",
				function()
					require("luasnip").jump(1)
				end,
				mode = "s",
			},
			{
				"<s-tab>",
				function()
					require("luasnip").jump(-1)
				end,
				mode = { "i", "s" },
			},
		},
		config = function(_, opts)
			local luasnip = require("luasnip")
			luasnip.setup(opts)
			local cvs_filetypes = {
				"gitcommit",
				"hgcommit",
				"jjdescription",
			}
			local cvs_snippets = {
				luasnip.snippet("mozdiffrev", {
					luasnip.text_node("Differential Revision: https://phabricator.services.mozilla.com/"),
					luasnip.insert_node(1, "D??????"),
				}),
				luasnip.snippet("mozpatch", {
					luasnip.text_node("Bug "),
					luasnip.insert_node(1, "???????"),
					luasnip.text_node(" - "),
					luasnip.insert_node(2, "TODO"),
					luasnip.text_node(" r="),
					luasnip.insert_node(3, "TODO"),
				}),
				luasnip.snippet("webgpupatch", {
					luasnip.text_node("Bug "),
					luasnip.insert_node(1, "???????"),
					luasnip.text_node(" - "),
					luasnip.insert_node(2, "TODO"),
					luasnip.text_node(" r=#webgpu-reviewers!"),
				}),
			}
			for _idx, ft in pairs(cvs_filetypes) do
				luasnip.add_snippets(ft, cvs_snippets)
			end
		end,
	},
	{
		"Saghen/blink.cmp",
		version = "v1.*",
		dependencies = {
			{ "L3MON4D3/LuaSnip", version = "v2.*" }, -- NOTE: keep in sync. with entry above
		},
		opts = {
			signature = { enabled = true },
			snippets = {
				preset = "luasnip",
			},
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
				  lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				  },
				},
			},
		},
	},
}
