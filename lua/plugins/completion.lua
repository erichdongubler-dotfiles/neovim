vim.opt.wildmode = "longest,list,full"

return {
	{
		"L3MON4D3/LuaSnip",
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
				"jj",
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
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
		},
		opts = function()
			local cmp = require("cmp")
			return {
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<Tab>"] = cmp.mapping.confirm({ select = true }),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<S-CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				experimental = {
					ghost_text = {
						hl_group = "LspCodeLens",
					},
				},
			}
		end,
	},
}
