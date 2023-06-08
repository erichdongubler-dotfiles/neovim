return {
	{
		"ErichDonGubler/vim-sublime-monokai",
		lazy = false,
		priority = 1000,
		init = function()
			vim.g.sublimemonokai_term_italic = true
		end,
		config = function(_, opts)
			vim.cmd["colorscheme"]("sublimemonokai")

			-- TODO: Get this moved to a better place
			vim.fn["g:SublimeMonokaiHighlight"]("BreezeHlElement", { format = "reverse" })

			-- TODO: What the crap, man!
			vim.fn["g:SublimeMonokaiHighlight"]("Todo", { fg = vim.g.sublimemonokai_orange, format = "bold,italic" })

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
						vim.fn["g:SublimeMonokaiHighlight"](highlight_group, highlight_spec)
					end
				end
			end

			vim.fn["g:SublimeMonokaiHighlight"]("LspReferenceText", { bg = vim.g.sublimemonokai_darkgrey })
			vim.fn["g:SublimeMonokaiHighlight"]("LspReferenceRead", { bg = vim.g.sublimemonokai_addbg })
			vim.fn["g:SublimeMonokaiHighlight"]("LspReferenceWrite", { bg = vim.g.sublimemonokai_changebg })
		end,

		-- TODO: Make `lazy` highlights _not suck_:
		-- * Plugin reload messages be _dark red_ 😱

		-- TODO: Make `bufferline` tabs not look stupid plz. 🥺
	},
}
