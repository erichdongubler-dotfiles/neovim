return {
	{
		"ErichDonGubler/wgpu.nvim",
		virtual = true,
		dependencies = {
			"LuaSnip",
		},
		config = function(_, opts)
			local luasnip = require("luasnip")
			luasnip.add_snippets("markdown", {
				luasnip.snippet("wgpuchangelog", {
					luasnip.insert_node(1, "TODO"),
					luasnip.text_node(". By "),
					luasnip.insert_node(2, "@ErichDonGubler"),
					luasnip.text_node(" in "),
					luasnip.insert_node(3, "[????](https://github.com/gfx-rs/wgpu/pull/????)"),
					luasnip.text_node("."),
				}),
			})
		end,
	},
}
