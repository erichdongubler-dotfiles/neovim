noremap("n", "<Leader>l<F2>", vim.lsp.buf.rename, { desc = "Rename symbol under cursor" })
noremap("n", "<Leader>lK", vim.lsp.buf.hover, { desc = "Show hover pop-up for symbol under cursor" })
noremap("n", "<Leader>lci", vim.lsp.buf.incoming_calls, { desc = "Show incoming calls for symbol under cursor" })
noremap("n", "<Leader>lco", vim.lsp.buf.outgoing_calls, { desc = "Show outgoing calls for symbol under cursor" })

vim.g.java_comment_strings = 1
vim.g.java_highlight_functions = 1
vim.g.java_highlight_java_lang_ids = 1

return {
	"vitalk/vim-shebang",

	-- LSP-oriented integration
	{
		"williamboman/mason.nvim",
		event = "VeryLazy",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = {
			"mason.nvim",
		},
		opts = {
			ensure_installed = {
				"lua_ls",
				"rust_analyzer",
				"tsserver",
				"wgsl_analyzer",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
	},
	{
		"j-hui/fidget.nvim",
		event = "VeryLazy",
		config = true,
	},
	{
		"folke/lsp-trouble.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-web-devicons",
		},
		opts = {
			use_diagnostic_signs = true,
		},
		config = function(_, opts)
			local trouble = require("trouble")
			trouble.setup(opts)
			require("which-key").register({
				M = {
					trouble.toggle,
					"Toggle `trouble`",
				},
				md = {
					bind_fuse(trouble.toggle, "document_diagnostics"),
					"Toggle `trouble` in document diagnostic mode",
				},
				mq = {
					bind_fuse(trouble.toggle, "loclist"),
					"Toggle `trouble` in location list mode",
				},
				mw = {
					bind_fuse(trouble.toggle, "workspace_diagnostics"),
					"Toggle `trouble` in workspace diagnostic mode",
				},
			}, { prefix = "<Leader>" })
		end,
	},
	{
		"SmiteshP/nvim-navic",
		event = "VeryLazy",
		init = function()
			vim.g.navic_silence = true
			augroup("NvimNavicLspAttach", function(au)
				au("LspAttach", nil, function(args)
					local buffer = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client.server_capabilities.documentSymbolProvider then
						require("nvim-navic").attach(client, buffer)
					end
				end)
			end)
		end,
		opts = function()
			return {
				separator = " ",
				highlight = true,
				depth_limit = 5,
				-- icons = require("lazyvim.config").icons.kinds,
			}
		end,
	},

	-- Formatting
	{
		"Chiel92/vim-autoformat",
		event = "VeryLazy",
		enabled = vim.fn.has("python3") == 1,
		config = function()
			vim.opt.autoindent = true

			augroup("WhitespaceAutoformat", function(au)
				au("BufWrite", "*", ":Autoformat")
			end)

			function disable_trailing_whitespace_stripping()
				vim.b.autoformat_remove_trailing_spaces = 0
			end
			function disable_indentation_fixing()
				vim.b.autoformat_autoindent = 0
			end
			function disable_retab()
				vim.b.autoformat_retab = 0
			end
			function disable_whitespace_fixing()
				disable_trailing_whitespace_stripping()
				disable_indentation_fixing()
				disable_retab()
			end

			local blacklist_entries = {
				[{ "BufNewFile", "BufRead" }] = {
					-- TODO: Can we eliminate this with a syntax?
					[disable_whitespace_fixing] = {
						"git-revise-todo",
					},
				},
				[{ "FileType" }] = {
					[disable_whitespace_fixing] = {
						"cpp",
						"csv",
						"ctrlsf",
						"diff",
						"git",
						"gitrebase",
						"snippets",
						"txt",
					},
					[disable_indentation_fixing] = {
						"dosini",
						"dot",
						"gitcommit",
						"hgcommit",
						"javascript",
						"kdl",
						"markdown",
						"rust",
						"sh",
						"toml",
						"typescript",
						"xml",
					},
				},
			}

			augroup("WhitespaceAutoformatBlacklist", function(au)
				for events, rest in pairs(blacklist_entries) do
					for callback, rest in pairs(rest) do
						for _idx, pattern in pairs(rest) do
							au(events, pattern, callback)
						end
					end
				end
			end)
		end,
	},

	-- Debugging

	-- Specific languages

	--     Document languages

	{
		"plasticboy/vim-markdown",
		dependencies = {
			-- "tagbar", -- TODO: Do we even still want this?
		},
		config = function(_, opts)
			augroup("markdown", function()
				au("FileType", "markdown", function()
					vim.cmd.SetRowLimit(80)
					vim.cmd.EnableWordWrap()
				end)
			end)
			vim.g.tagbar_type_markdown = {
				ctagstype = "markdown",
				kinds = {
					"h:Heading_L1",
					"i:Heading_L2",
					"k:Heading_L3",
				},
			}
		end,
	},

	{
		"liuchengxu/graphviz.vim",
		init = function()
			vim.g.graphviz_output_format = "svg"
		end,
	},

	{
		"jceb/vim-orgmode",
		dependencies = {
			"tpope/vim-speeddating",
		},
		init = function()
			vim.g.org_heading_highlight_colors = { "Identifier" }
			vim.g.org_heading_highlight_levels = 10
		end,
		config = function(_, opts)
			augroup("orgmode", function(au)
				au("FileType", { "text", "org" }, bind_fuse(vim.cmd.EnableWordWrap))
			end)
		end,
	},

	--     Shell scripting languages

	"pprovost/vim-ps1",

	--     Data/configuration/IDL-ish languages

	"gisphm/vim-gitignore",

	"cespare/vim-toml",

	"zchee/vim-flatbuffers",

	"gutenye/json5.vim",

	"imsnif/kdl.vim",

	--     Native world

	"pboettch/vim-cmake-syntax",

	"octol/vim-cpp-enhanced-highlight",

	{
		"rust-lang/rust.vim",
		ft = "rust",
		dependencies = {
			"cmp-nvim-lsp",
			"mason-lspconfig.nvim",
			"vim-sandwich",
			"vim-shebang",
			"vim-sublime-monokai",
			"which-key.nvim",
		},
		config = function()
			_G.add_sandwich_recipes(function(add_recipe)
				local add_rust_sandwich_binding = function(input, start, end_)
					add_recipe({
						buns = { start, end_ },
						filetype = { "rust" },
						input = { input },
						nesting = 1,
						indent = 1,
					})
				end
				add_rust_sandwich_binding("A", "Arc<", ">")
				add_rust_sandwich_binding("B", "Box<", ">")
				add_rust_sandwich_binding("O", "Option<", ">")
				add_rust_sandwich_binding("P", "PhantomData<", ">")
				add_rust_sandwich_binding("R", "Result<", ">")
				add_rust_sandwich_binding("V", "Vec<", ">")
				add_rust_sandwich_binding("a", "Arc::new(", ")")
				add_rust_sandwich_binding("b", "Box::new(", ")")
				add_rust_sandwich_binding("d", "dbg!(", ")")
				add_rust_sandwich_binding("o", "Some(", ")")
				add_rust_sandwich_binding("r", "Ok(", ")")
				add_rust_sandwich_binding("u", "unsafe { ", " }")
				add_rust_sandwich_binding("v", "vec![", "]")
				add_rust_sandwich_binding("y", function()
					local ty_name = vim.fn.input("Type a type name...")
					return ty_name .. "<"
				end, ">")
			end)

			-- TODO
			function configure_rust()
				local cargo = vim.cmd.Cargo
				require("which-key").register({
					b = {
						bind_fuse(cargo, "build"),
						"Run `cargo build`",
					},
					B = {
						bind_fuse(cargo, "build", "--release"),
						"Run `cargo build --release`",
					},
					c = {
						bind_fuse(cargo, "check"),
						"Run `cargo check`",
					},
					d = {
						bind_fuse(cargo, "doc"),
						"Run `cargo doc`",
					},
					D = {
						bind_fuse(cargo, "doc", "--open"),
						"Run `cargo doc --open`",
					},
					F = {
						bind_fuse(cargo, "fmt"),
						"Run `cargo fmt`",
					},
					f = {
						vim.cmd.RustFmt,
						"Run `cargo fmt` on current file",
					},
					p = {
						vim.cmd.RustPlay,
						"Run `cargo ???`",
					},
					r = {
						bind_fuse(cargo, "run"),
						"Run `cargo run`",
					},
					R = {
						bind_fuse(cargo, "run", "--release"),
						"Run `cargo run --release`",
					},
					s = {
						function()
							cargo("script", vim.cmd.expand("%"))
						end,
						"Run `cargo script` on current file",
					},
					t = {
						vim.cmd.RustTest,
						"Run `cargo test` on test under cursor",
					},
					T = {
						bind_fuse(cargo, "test"),
						"Run `cargo test`",
					},
				}, { prefix = "<LocalLeader>", buffer = 0 })
			end
			augroup("rust", function(au)
				au("FileType", "rust", configure_rust)
			end)

			vim.cmd([[
			AddShebangPattern! rust ^#!.*/bin/env\s\+run-cargo-(script|eval)\>
			AddShebangPattern! rust ^#!.*/bin/run-cargo-(script|eval)\>
			]])

			require("lspconfig").rust_analyzer.setup({
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
				settings = {
					["rust-analyzer"] = {
						cargo = { runBuildScripts = true },
						procMacro = {
							enable = true,
						},
					},
				},
			})

			vim.cmd([[
			hi! link rustAttribute      SublimeDocumentation
			hi! link rustDerive         SublimeDocumentation
			hi! link rustDeriveTrait    SublimeDocumentation
			hi! link rustLifetime       Special
			]])
		end,
	},

	--     web

	{
		"pangloss/vim-javascript",
		dependencies = {
			-- "tagbar", -- TODO: Do we even still want this?
			"vim-sublime-monokai",
		},
		init = function()
			vim.g.tagbar_type_javascript = {
				ctagstype = "javascript",
				kinds = {
					"o:objects",
					"c:classes",
					"f:functions",
					"a:arrays",
					"m:methods",
					"n:constants",
					"s:strings",
				},
			}
			vim.cmd([[
			hi! link jsregexpcharclass  special
			hi! link jsregexpbackref    specialchar
			hi! link jsregexpmod        specialchar
			hi! link jsregexpor         specialchar
			]])
		end,
	},

	"mxw/vim-jsx",

	{
		"posva/vim-vue",
		ft = { "markdown" },
		run = function()
			if vim.fn.executable("npm") then
				-- TODO: I wonder if we can use Mason here?
				vim.cmd("silent !npm i -g eslint eslint-plugin-vue")
			end
		end,
	},

	"andys8/vim-elm-syntax",

	--     other general-purpose languages

	"OrangeT/vim-csharp",

	{
		"fatih/vim-go",
		dependencies = {
			"vim-sublime-monokai",
		},
		init = function()
			vim.g.go_highlight_format_strings = 1
			vim.g.go_highlight_function_arguments = 1
			vim.g.go_highlight_function_calls = 1
			vim.g.go_highlight_functions = 1
			vim.g.go_highlight_operators = 1
			vim.g.go_highlight_types = 1

			vim.g.go_highlight_extra_types = 1
			vim.g.go_highlight_fields = 1
			vim.g.go_highlight_generate_tags = 1
			vim.g.go_highlight_variable_assignments = 1
			vim.g.go_highlight_variable_declarations = 1

			vim.cmd([[
			hi! link goExtraType        Special
			hi! link goTypeConstructor  SublimeType
			]])
		end,
	},

	{
		"StanAngeloff/php.vim",
		dependencies = {
			"vim-sublime-monokai",
		},
		init = function()
			vim.g.php_var_selector_is_identifier = 1
		end,
		config = function(_, opts)
			vim.cmd([[
			hi! link phpMemberSelector Keyword
			]])
		end,
	},

	{
		"DingDean/wgsl.vim",
		dependencies = {
			"mason-lspconfig.nvim",
		},
		config = function(_, opts)
			require("lspconfig").wgsl_analyzer.setup({
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})
		end,
	},
}
