-- TODO: Fix `cgg` not working as expected

-- Set default keyword character group
vim.opt.iskeyword:remove({ ".", "#" })

--   Add some common line-ending shortcuts
function append_chars(sequence)
	local line = vim.fn.line(".")
	local col = vim.fn.col(".")
	vim.cmd("exec 'normal! A" .. sequence .. "'")
	vim.fn.cursor(line, col)
end
function map_device_character_append(sequence, name)
	function cmd()
		append_chars(sequence)
	end
	local opts = { desc = "Append `" .. sequence .. "` to end of line" }
	command("Append" .. name, cmd, opts)
	noremap("n", "<Leader>" .. sequence, cmd, opts)
end
map_device_character_append(";", "Semicolon")
map_device_character_append(".", "Period")
map_device_character_append(",", "Comma")

-- Create some lazy init. machinery for plugins that init. or consume
-- `vim-sandwich`

sandwich_initted = false
function _G.add_sandwich_recipes(callback)
	if not sandwich_initted then
		-- Not sure why this needs to be in vimscript. :scratch-head:
		vim.cmd("let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)")
		sandwich_initted = true
	end
	local recipes = vim.g["sandwich#recipes"]
	function add_entry(recipe)
		table.insert(recipes, recipe)
	end
	callback(add_entry)
	vim.g["sandwich#recipes"] = recipes
end

return {
	{
		"echasnovski/mini.bracketed",
		version = "*",
		event = "VeryLazy",
		opts = {
			-- Disable these because Neovim 0.11 already binds them.
			buffer = { suffix = "" },
			diagnostic = { suffix = "" },
		},
	},
	{
		"christoomey/vim-sort-motion",
		event = "VeryLazy",
	},
	{
		"mg979/vim-visual-multi",
		event = "VeryLazy",
	},
	{
		"FooSoft/vim-argwrap",
		event = "VeryLazy",
		config = function()
			noremap("n", "<Leader>]", vim.cmd.ArgWrap, { desc = "Toggle linedness of argument list" })
		end,
	},
	{
		"peterrincker/vim-argumentative",
		event = "VeryLazy",
	},

	{
		"tommcdo/vim-ninja-feet",
		event = "VeryLazy",
	},
	{
		"wellle/targets.vim",
		event = "VeryLazy",
	},
	{
		"glts/vim-textobj-comment",
		event = "VeryLazy",
		dependencies = {
			"kana/vim-textobj-user",
		},
	},
	{
		"kana/vim-textobj-entire",
		event = "VeryLazy",
		dependencies = {
			"kana/vim-textobj-user",
		},
	},
	{
		"kana/vim-textobj-function",
		event = "VeryLazy",
		dependencies = {
			"kana/vim-textobj-user",
		},
	},
	{
		"kana/vim-textobj-indent",
		event = "VeryLazy",
		dependencies = {
			"kana/vim-textobj-user",
		},
	},
	{
		"kana/vim-textobj-line",
		event = "VeryLazy",
		dependencies = {
			"kana/vim-textobj-user",
		},
	},
	{
		"thalesmello/vim-textobj-methodcall",
		event = "VeryLazy",
		dependencies = {
			"kana/vim-textobj-user",
		},
	},
	{
		"mattn/vim-textobj-url",
		event = "VeryLazy",
		dependencies = {
			"kana/vim-textobj-user",
		},
	},

	-- Auto-pairing

	"tpope/vim-endwise",
	{
		"windwp/nvim-autopairs",
		opts = {},
	},
	{
		"andymass/vim-matchup",
		dependencies = {
			"vim-sublime-monokai",
			"vim-sandwich", -- No hard dependency, just needs to be after.
		},
		init = function()
			vim.g.matchup_matchparen_deferred = 1
			vim.g.matchup_matchparen_hi_surround_always = 1
			vim.g.matchup_override_vimtex = 1
			vim.g.matchup_surround_enabled = 1
		end,
		config = function(_, opts)
			vim.cmd([[
			hi! clear MatchParenCur
			hi! clear MatchWordCur
			]])
			vim.fn["g:SublimeMonokaiHighlight"]("MatchParen", { format = "reverse" })
			vim.fn["g:SublimeMonokaiHighlight"]("MatchTag", { format = "reverse" })
			vim.fn["g:SublimeMonokaiHighlight"]("MatchWord", { format = "reverse" })
		end,
	},
	{
		"machakann/vim-sandwich",
		event = "VeryLazy",
		event = {
			"BufEnter",
		},
		config = function()
			_G.add_sandwich_recipes(function(add_recipe)
				local vim_surround_ish_recipes = {
					{
						buns = { "{ ", " }" },
						nesting = 1,
						match_syntax = 1,
						kind = { "add", "replace" },
						action = { "add" },
						input = { "{" },
					},
					{
						buns = { "[ ", " ]" },
						nesting = 1,
						match_syntax = 1,
						kind = { "add", "replace" },
						action = { "add" },
						input = { "[" },
					},
					{
						buns = { "( ", " )" },
						nesting = 1,
						match_syntax = 1,
						kind = { "add", "replace" },
						action = { "add" },
						input = { "(" },
					},
					{
						buns = { "{\\s*", "\\s*}" },
						nesting = 1,
						regex = 1,
						match_syntax = 1,
						kind = { "delete", "replace", "textobj" },
						action = { "delete" },
						input = { "{" },
					},
					{
						buns = { "\\[\\s*", "\\s*\\]" },
						nesting = 1,
						regex = 1,
						match_syntax = 1,
						kind = { "delete", "replace", "textobj" },
						action = { "delete" },
						input = { "[" },
					},
					{
						buns = { "(\\s*", "\\s*)" },
						nesting = 1,
						regex = 1,
						match_syntax = 1,
						kind = { "delete", "replace", "textobj" },
						action = { "delete" },
						input = { "(" },
					},
				}

				for _, recipe in pairs(vim_surround_ish_recipes) do
					add_recipe(recipe)
				end
			end)
		end,
	},

	-- TODO: Hoist everything below up
	{
		"echasnovski/mini.align",
		event = "VeryLazy",
		opts = {},
	},

	{
		"numToStr/Comment.nvim",
		opts = {},
	},

	{
		"ntpeters/vim-better-whitespace",
		event = "VeryLazy",
		depdendencies = {
			"vim-sublime-monokai",
		},
		init = function()
			vim.g.better_whitespace_operator = "_s"
			vim.g.show_spaces_that_precede_tabs = 0
			vim.g.strip_whitespace_confirm = 0
			vim.cmd([[
			hi! link ExtraWhitespace Error
			]])
		end,
	},

	{
		"arthurxavierx/vim-caser",
		init = function()
			vim.g.caser_prefix = "gS"
		end,
	},
}
