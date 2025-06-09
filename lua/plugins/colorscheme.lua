return {
	{
		"ErichDonGubler/vim-sublime-monokai",
		lazy = false,
		priority = 1000,
		init = function()
			vim.opt.termguicolors = true
			vim.g.sublimemonokai_term_italic = true
		end,
		config = function(_, opts)
			vim.cmd.colorscheme("sublimemonokai")

			local sublime_monokai_highlight = vim.fn["g:SublimeMonokaiHighlight"]

			-- TODO: Get this moved to a better place
			sublime_monokai_highlight("BreezeHlElement", { format = "reverse" })

			-- TODO: What the crap, man!
			sublime_monokai_highlight("Todo", { fg = vim.g.sublimemonokai_orange, format = "bold,italic" })

			-- FIXME: Apparently "new" file and file are mixed up for the diff
			-- highlightlight groups. Ew!
			-- FIXME: There's no distinguishing between the second file and the `diff`
			-- line. Ew!
			vim.cmd([[
			hi! link cmakeVariableValue SublimeAqua
			hi! link cssMediaType       Special
			hi! link diffLine           SublimeAqua
			hi! link diffNewFile        SublimeBrightWhite
			hi! link dotBrackEncl       Keyword
			" It's nice to have the builtins highlighted, but they can cause some conflicts
			hi! link pythonBuiltInObj   Constant
			hi! link pythonBuiltInType  Constant
			hi! link rustMacroVariable  SublimeContextParam
			hi! link xmlProcessingDelim Comment
			hi! link zshOption          Special
			hi! link zshTypes           SublimeType
			]])

			-- TODO: upstream these?
			local lsp_highlight_groups = {
				["Error"] = {
					[""] = "Error",
					["Sign"] = "Error",
					["Underline"] = "SpellBad",
					["VirtualText"] = "NonText",
				},
				["Warn"] = {
					[""] = "SpellCap",
					["Sign"] = "SpellCap",
					["Underline"] = "SpellCap",
					["VirtualText"] = "NonText",
				},
				["Info"] = {
					[""] = "Comment",
					["VirtualText"] = "NonText",
				},
				["Hint"] = {
					[""] = "Comment",
					["VirtualText"] = "NonText",
				},
			}
			for severity, rest in pairs(lsp_highlight_groups) do
				for highlight_location, highlight_spec in pairs(rest) do
					local highlight_group = "Diagnostic" .. highlight_location .. severity
					if type(highlight_spec) == "string" then
						vim.cmd("hi! link " .. highlight_group .. " " .. highlight_spec)
					else
						sublime_monokai_highlight(highlight_group, highlight_spec)
					end
				end
			end

			sublime_monokai_highlight("LspReferenceText", { bg = vim.g.sublimemonokai_darkgrey })
			sublime_monokai_highlight("LspReferenceRead", { bg = vim.g.sublimemonokai_addbg })
			sublime_monokai_highlight("LspReferenceWrite", { bg = vim.g.sublimemonokai_changebg })

			function _G.hi_link(from, to)
				vim.api.nvim_set_hl(0, from, { link = to })
			end

			function _G.hi_clear(name)
				vim.api.nvim_set_hl(0, name, {})
			end

			hi_clear("@lsp")
			hi_link("@lsp.mod.declaration", "Tag")
			hi_link("@lsp.type.builtinType", "SublimeType")
			hi_link("@lsp.type.enum", "SublimeType")
			hi_link("@lsp.type.function", "SublimeFunctionCall")
			hi_link("@lsp.type.interface", "SublimeType")
			hi_link("@lsp.type.macro", "SublimeFunctionCall")
			hi_link("@lsp.type.method", "SublimeFunctionCall")
			hi_link("@lsp.type.namespace", "Normal")
			hi_link("@lsp.type.namespace.rust", "SublimeType")
			hi_link("@lsp.type.parameter", "SublimeContextParam")
			hi_link("@lsp.type.struct", "SublimeType")
			hi_link("@lsp.type.typeAlias", "SublimeType")
			hi_link("@lsp.type.union", "SublimeType")
			hi_link("@lsp.type.unresolvedReference", "SpellBad")
			hi_link("@lsp.typemod.decorator.attribute.rust", "SublimeUserAttribute")
			hi_link("@lsp.typemod.enumMember.declaration", "SublimePurple")
			hi_link("@lsp.typemod.namespace.attribute.rust", "SublimeUserAttribute")
			hi_link("@lsp.typemod.parameter.declaration", "SublimeContextParam")
			hi_link("@lsp.typemod.property.declaration.rust", "Normal")
			hi_link("@lsp.typemod.selfKeyword.declaration", "SublimeContextParam")
			hi_link("@lsp.typemod.selfKeyword.reference", "SublimeContextParam")
			hi_link("@lsp.typemod.typeParameter.declaration", "Normal") -- TODO: maybe italic?
			hi_link("@lsp.typemod.variable.constant", "SublimePurple")
			hi_link("@lsp.typemod.variable.declaration", "Normal")
		end,

		-- TODO: Make `lazy` highlights _not suck_:
		-- * Plugin reload messages be _dark red_ 😱

		-- TODO: Make `barbar` tabs not look stupid plz. 🥺
	},
}
