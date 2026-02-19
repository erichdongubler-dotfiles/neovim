return {
	{
		"ErichDonGubler/mozilla.nvim",
		virtual = true,
		dependencies = {
			"LuaSnip",
		},
		config = function(_, opts)
			local luasnip = require("luasnip")
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
			for _, ft in pairs(cvs_filetypes) do
				luasnip.add_snippets(ft, cvs_snippets)
			end
		end,
	},

}
