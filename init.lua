local this_script = vim.fs.normalize(vim.fn.expand("<script>:p"))
local canonical_neovim_lua_config_path = vim.fs.normalize(vim.fn.stdpath("config") .. "/init.lua")

if this_script ~= canonical_neovim_lua_config_path then
	vim.notify(
		"Warning: this script (`"
			.. this_script
			.. "`) expects to be the canonical Neovim Lua config path at `"
			.. canonical_neovim_lua_config_path
			.. "`, but that isn't true. Weirdness may happen, beware!"
	)
end

-- Stolen from https://github.com/wbthomason/packer.nvim#bootstrapping

local packer_bootstrap = false
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	print("`packer` is missing, installing...")
	packer_bootstrap = vim.fn.system({ "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path })
	vim.cmd("packadd packer.nvim")
end

-- Make our own little ecosystem for Vim config...

function _G.bind_fuse(func, ...)
	local args = { ... }
	return function()
		func(unpack(args))
	end
end

function _G.command(name, command, opts)
	opts = opts or {}
	vim.api.nvim_create_user_command(name, command, opts)
end

function _G.map(mode, lhs, rhs, opts)
	vim.keymap.set(mode, lhs, rhs, options)
end

function _G.noremap(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	map(mode, lhs, rhs, options)
end

function _G.augroup(name, callback)
	local augroup_id = vim.api.nvim_create_augroup(name, {})
	function au(name, patterns, cmd)
		local args = { pattern = patterns, group = augroup_id }
		if type(cmd) == "string" then
			args.command = cmd
		else
			args.callback = cmd
		end
		vim.api.nvim_create_autocmd(name, args)
	end
	callback(au)
end

local packer = require("packer")
packer.startup(function()
	function reload_config_and_compile_packer(path)
		vim.cmd.source(path)
		packer.compile()
	end
	augroup("PackerUpdate", function(au)
		au("BufWritePost", "init.lua", function()
			local path_written = vim.fs.normalize(vim.fn.expand("<afile>:p"))
			if path_written == this_script then
				reload_config_and_compile_packer(path_written)
			end
		end)
		au("User", { "PackerCompileDone" }, function()
			vim.notify("Finished compiling Packer startup script from `" .. this_script .. "`", vim.log.levels.INFO, {
				title = "`PackerCompile` finished",
				timeout = 1000, -- ms
			})
		end)
	end)

	noremap("n", "<Leader>vs", function()
		reload_config_and_compile_packer(this_script)
	end)
	noremap("n", "<Leader>ve", bind_fuse(vim.cmd.e, this_script))

	use("wbthomason/packer.nvim")

	-- Disable freezing on Windows when we press `CTRL + Z`.
	if vim.fn.has("win32") then
		noremap("", "<C-z>", "<Nop>")
	end

	vim.opt.mouse = "a"
	vim.cmd("behave xterm")

	vim.opt.wildmode = "longest,list,full"
	vim.opt.iskeyword:remove({ ".", "#" })

	vim.g.mapleader = "\\"
	vim.g.maplocalleader = "|"

	vim.opt.clipboard = "unnamed,unnamedplus"

	vim.opt.encoding = "utf-8"
	vim.opt.fileencoding = "utf-8"
	use("s3rvac/AutoFenc")

	--   Make Neovim's "default" notification sink a nice set of pop-ups on the side.
	use({
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({
				stages = "slide",
			})
			vim.notify = notify
		end,
	})

	-- Buffer rendering

	vim.opt.cursorline = true
	vim.opt.number = true
	vim.opt.scrolloff = 5

	use({
		"xuyuanp/scrollbar.nvim",
		config = function()
			local scrollbar = require("scrollbar")
			function show()
				scrollbar.show()
			end
			function clear()
				scrollbar.clear()
			end
			augroup("ScrollbarInit", function(au)
				au({ "CursorMoved", "VimResized", "QuitPre", "WinEnter", "FocusGained" }, "*", show, { silent = true })
				au({ "WinLeave", "BufLeave", "BufWinLeave", "FocusLost" }, "*", clear, { silent = true })
			end)
		end,
	})

	-- Replace several vanilla Neovim/Vim UIs with nicer ones
	use("stevearc/dressing.nvim")

	-- vimdiff: use vertical layout
	vim.opt.diffopt = vim.opt.diffopt + { "vertical" }

	--   Whitespace

	function set_listchars_verbose()
		vim.o.list = true
		vim.o.listchars = ""
		vim.opt.listchars = {
			eol = "$",
			extends = ">",
			nbsp = "⊘",
			precedes = "<",
			space = "·",
			tab = "├─",
			trail = "~",
		}
	end
	_G.set_listchars_verbose = set_listchars_verbose

	function set_listchars_quiet()
		vim.o.list = true
		vim.o.listchars = ""
		vim.opt.listchars = {
			extends = ">",
			precedes = "<",
			tab = "┆ ",
		}
	end
	_G.set_listchars_quiet = set_listchars_quiet

	vim_indentguides_disabled = false
	use({
		"thaerkh/vim-indentguides",
		disable = vim_indentguides_disabled,
		setup = function()
			-- NOTE: keep these in sync with `set_listchars_quiet`
			vim.g.indentguides_spacechar = "·"
			vim.g.indentguides_tabchar = "┆"
		end,
		config = function()
			set_listchars_quiet() -- silly `vim-indentguides`, stop stomping mah `listchars`!
		end,
	}) -- NOTE: Some functionality below depends on this.

	local toggle_list_verbosity
	if not vim_indentguides_disabled then
		function disable_indentguides()
			vim.b.toggle_indentguides = 0
			vim.cmd.IndentGuidesToggle()
			set_listchars_verbose()
		end

		function enable_indentguides()
			vim.b.toggle_indentguides = 1
			vim.cmd.IndentGuidesToggle()
			set_listchars_quiet()
		end

		local is_indentation_verbose = false -- `vim-indentguides` is definitely enabled if we arrive here.
		toggle_list_verbosity = function()
			if is_indentation_verbose then
				vim.notify("quieting vim-indentguides")
				is_indentation_verbose = false
				enable_indentguides()
			else
				vim.notify("verbosifying vim-indentguides")
				is_indentation_verbose = true
				disable_indentguides()
			end
		end
	else
		set_listchars_quiet()
		local is_indentation_verbose = false
		toggle_list_verbosity = function()
			if is_indentation_verbose then
				vim.notify("quieting vanilla")
				is_indentation_verbose = false
				set_listchars_quiet()
			else
				vim.notify("verbosifying vanilla")
				is_indentation_verbose = true
				set_listchars_verbose()
			end
		end
	end

	command("ToggleListVerbosity", toggle_list_verbosity, { nargs = 0 })
	noremap("n", "<Leader>i", toggle_list_verbosity)

	--   TODO: `limelight` and `goyo`?

	-- GUI-specific configuration; see `ginit.vim` for non-package stuff

	--   Fonts
	use("drmikehenry/vim-fontdetect")

	-- Fix terminal-specific settings so we get the correct colors and keybinds

	-- --   Force background drawing in truecolor terminals
	-- vim.opt.t_ut = ''

	--   MinTTY bindings
	local mintty_keybind_modifiers_map = {
		["2"] = "S",
		["3"] = "M",
		["4"] = "M-S",
		["5"] = "C",
		["6"] = "C-S",
	}
	local mintty_keys_to_map = {
		["Up"] = "1;%sA",
		["Down"] = "1;%sB",
		["Right"] = "1;%sC",
		["Left"] = "1;%sD",
		["PageUp"] = "5;%s~",
	}
	for vim_keycode_name, mintty_key_escape_pattern in pairs(mintty_keys_to_map) do
		for escape_modifier_num, vim_modifier in pairs(mintty_keybind_modifiers_map) do
			local subbed = mintty_key_escape_pattern:gsub("%%s", escape_modifier_num)
			local binding = "<Esc>[" .. subbed
			local mapped = "<" .. vim_modifier .. "-" .. vim_keycode_name .. ">"
			map("", binding, mapped)
			noremap("i", binding, mapped)
		end
	end

	--   rvxt bindings

	map("", "<Esc>Oa", "<C-Up")
	map("", "<Esc>Ob", "<C-Down")
	map("", "<Esc>Oc", "<C-Right")
	map("", "<Esc>Od", "<C-Left")
	map("", "<Esc>[5^", "<C-PageUp")
	map("", "<Esc>[6^", "<C-PageDown>")

	--

	-- TODO: `list` and altering how to present characters

	-- Buffer/pane management

	vim.opt.hidden = true
	vim.opt.splitbelow = true
	vim.opt.splitright = true

	--   Alias Q to do what we really want
	command("Q", vim.cmd.q)
	command("Q", vim.cmd["q!"], { bang = true })
	command("Qa", vim.cmd.qa)
	command("Qa", vim.cmd["qa!"], { bang = true })
	command("QA", vim.cmd.qa)
	command("QA", vim.cmd["qa!"], { bang = true })
	noremap("n", "<Leader>q", vim.cmd.q)
	noremap("n", "<Leader>Q", vim.cmd["q!"])
	noremap("n", "<Leader>", vim.cmd["qa!"])
	-- Get a Leader mapping for saves
	noremap("n", "<Leader>s", vim.cmd.w)
	command("W", ":w!", { bang = true })

	--   File change management
	vim.opt.undofile = true
	vim.opt.autoread = true
	use("mbbill/undotree")
	use({ "ErichDonGubler/vim-playnice", branch = "initial-release" })

	--   Buffer display above
	use({
		"famiu/bufdelete.nvim",
		config = function()
			noremap("n", "<Leader>w", vim.cmd.Bwipeout)
		end,
	})
	use({
		"akinsho/bufferline.nvim",
		tag = "v3.*",
		after = {
			"bufdelete.nvim",
			"vim-sublime-monokai",
			"vim-unimpaired", -- conflicts with `]b`-ish bindings
		},
		requires = {
			"bufdelete.nvim",
			"vim-sublime-monokai",
		},
		config = function()
			local bufferline = require("bufferline")

			function cycle_next()
				bufferline.cycle(1)
			end
			function cycle_prev()
				bufferline.cycle(-1)
			end
			local bufferline_bindings = {
				-- Replace default bindings
				["]b"] = cycle_next,
				["[b"] = cycle_prev,
				["<C-PageUp>"] = cycle_prev,
				["<C-PageDown>"] = cycle_next,

				["<Leader>W"] = function()
					bufferline.close_in_direction("left")
					bufferline.close_in_direction("right")
				end,
			}
			for binding, cmd in pairs(bufferline_bindings) do
				noremap("n", binding, cmd, { silent = true })
			end

			vim.cmd([[
			hi! link BufferLineBackground TabLineFill
			hi! link BufferLineBuffer TabLineFill
			hi! link BufferLineCloseButton TabLineFill
			hi! link BufferLineFill TabLineFill
			hi! link BufferLineModified TabLineFill
			hi! link BufferLineSeparator TabLineFill
			hi! link BufferLineTab TabLineFill
			hi! link BufferLineTabBackground TabLineFill
			hi! link BufferLineTabSeparator TabLineFill

			hi! link BufferLineBufferSelected TabLineSel
			hi! link BufferLineIndicatorSelected TabLineSel
			hi! link BufferLineCloseButtonSelected TabLineSel
			hi! link BufferLineModifiedSelected TabLineSel
			hi! link BufferLineTabSelected TabLineSel
			hi! link BufferLineTabSeparatorSelected TabLineSel

			hi! link BufferLineBufferVisible TabLine
			hi! link BufferLineIndicatorVisible TabLine
			hi! link BufferLineCloseButtonVisible TabLine
			hi! link BufferLineSeparatorVisible TabLine
			hi! link BufferLineTabClose TabLine

			hi! link BufferLinePick SublimeAqua
			hi! link BufferLinePickSelected SublimeAqua
			hi! link BufferLinePickVisible SublimeAqua
			]])
			bufferline.setup({
				options = {
					buffer_close_icon = "⤬",
					close_command = function(bufnum)
						require("bufdelete").bufwipeout(bufnum)
					end,
					close_icon = "⤬",
					indicator = {
						style = "none",
					},
					left_trunc_marker = "«",
					right_trunc_marker = "»",
					separator_style = { "|", "|" },
					show_buffer_default_icon = false,
					show_buffer_icons = false,
				},
			})
		end,
	})

	--   Temporarily narrow to a single window
	use("vim-scripts/ZoomWin")

	--   Resize windows easily via keyboard
	use("simeji/winresizer")
	vim.g.winresizer_start_key = "<Leader><CR>"

	-- TODO: Investigate `*CurrentFile` breakage here.
	use({
		"ErichDonGubler/vim-file-browser-integration",
		config = function()
			local fb_bindings = {
				["<Leader>e"] = vim.cmd.SelectCurrentFile,
				["<Leader>x"] = vim.cmd.OpenCurrentFile,
				["<Leader>E"] = vim.cmd.OpenCWD,
			}
			for binding, cmd in pairs(fb_bindings) do
				noremap("n", binding, cmd)
			end
		end,
	})

	-- Project flows

	--   Session management

	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local actions = require("telescope.actions")
			local builtin = require("telescope.builtin")
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					color_devicons = false,
					dynamic_preview_title = true,
					mappings = {
						n = {
							["<C-C>"] = actions.close,
						},
					},
					layout_strategy = "flex",
					path_display = { "smart" },
				},
			})
			local telescope_mappings = {
				n = {
					["<Leader>D"] = builtin.diagnostics,
					["<Leader>O"] = builtin.buffers,
					["<Leader>R"] = builtin.tags,
					["<Leader>T"] = builtin.builtin,
					["<Leader>d"] = function()
						builtin.diagnostics({ bufnr = 0 })
					end,
					["<Leader>f"] = builtin.live_grep,
					["<Leader>o"] = builtin.oldfiles,
					["<Leader>p"] = builtin.find_files,
					["<Leader>l<C-]>"] = builtin.lsp_definitions,
					["<Leader><F12>"] = builtin.lsp_definitions,
					["<Leader>lR"] = builtin.lsp_dynamic_workspace_symbols,
					["<Leader>la"] = vim.lsp.buf.code_action,
					["<Leader>lgd"] = builtin.lsp_definitions,
					["<Leader>lgi"] = builtin.lsp_implementations,
					["<Leader>lgr"] = builtin.lsp_references,
					["<Leader><M-S-F12>"] = builtin.lsp_references,
					["<Leader>lgt"] = builtin.lsp_type_definitions,
					["<Leader>lr"] = builtin.lsp_document_symbols,
					["<Leader>r"] = builtin.current_buffer_tags,
				},
				v = {
					["<Leader>la"] = vim.lsp.buf.range_code_action,
				},
			}

			for mode, rest in pairs(telescope_mappings) do
				for binding, cmd in pairs(rest) do
					noremap(mode, binding, cmd)
				end
			end
		end,
	})

	use({
		"ivalkeen/vim-ctrlp-tjump",
		requires = {
			"ctrlpvim/ctrlp.vim",
		},
		setup = function()
			vim.g.ctrlp_tjump_only_silent = 1
		end,
		config = function()
			noremap("n", "<C-]>", vim.cmd.CtrlPtjump)
			noremap("v", "<C-]>", vim.cmd.CtrlPtjumpVisual)
		end,
	})

	vim.opt.sessionoptions:remove("options")
	vim.opt.sessionoptions:append("tabpages")
	vim.opt.sessionoptions:append("globals")

	use({
		"dhruvasagar/vim-prosession",
		requires = {
			"tpope/vim-obsession",
		},
	})
	-- TODO: fuzzy session selection?

	--   These make using the command-line interface much easier.
	use("EinfachToll/DidYouMean")
	use("pbrisbin/vim-mkdir") -- make parent directories automatically
	use("kopischke/vim-fetch") -- handle `file:<line>:<col>`

	--   Project configuration

	use({
		"embear/vim-localvimrc",
		setup = function()
			vim.g.localvimrc_persistent = 1
			vim.g.localvimrc_sandbox = false
		end,
	})

	--   File management

	use({
		"nvim-tree/nvim-tree.lua",
		event = {
			"BufReadPost",
		},
		config = function()
			local nvim_tree = require("nvim-tree")
			noremap("n", "<Leader>k", nvim_tree.toggle)
			noremap("n", "-", function()
				nvim_tree.find_file(true)
			end)
			nvim_tree.setup({
				renderer = {
					add_trailing = true,
					group_empty = true,
					icons = {
						glyphs = {
							folder = {
								arrow_closed = "▸",
								arrow_open = "▾",
							},
							git = {
								deleted = "✖",
								ignored = "⊘",
								renamed = "➜",
								staged = "⊕",
								unmerged = "⑂",
								unstaged = "⊛",
								untracked = "?",
							},
						},
						show = {
							file = false,
							folder = false,
						},
					},
				},
			})
		end,
	})

	-- Get some nice command aliases for basic file management
	use("tpope/vim-eunuch")

	-- Color scheme and highlighting configuration

	--   Highlights inspection
	--   TODO: I think this could be better?
	function syntax_stack()
		if not vim.fn.exists("*synstack") then
			return
		end
		return vim.fn.map(vim.fn.synstack(vim.fn.line("."), vim.fn.col(".")), 'synIDattr(v:val, "name")')
	end
	command("EchoHighlightingGroup", syntax_stack, { nargs = 0 })
	noremap("n", "<Leader>0", syntax_stack)

	use({
		"ErichDonGubler/vim-sublime-monokai",
		event = {
			"VimEnter",
		},
		setup = function()
			vim.g.sublimemonokai_term_italic = true
		end,
		config = function()
			vim.cmd("colorscheme sublimemonokai")

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

			local lsp_highlight_groups = {
				["Error"] = {
					[""] = "Error",
					["Sign"] = "Error",
					["Underline"] = "SpellBad",
					["VirtualText"] = "Comment",
				},
				["Warn"] = {
					[""] = "SpellCap",
					["Sign"] = "SpellCap",
					["Underline"] = "SpellCap",
					["VirtualText"] = "Comment",
				},
				["Info"] = {
					[""] = "Comment",
				},
				["Hint"] = {
					[""] = "Comment",
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
	})

	-- Status line

	vim.opt.laststatus = 2
	vim.opt.showmode = false

	use({
		"hoob3rt/lualine.nvim",
		after = {
			"vim-sublime-monokai",
		},
		requires = {
			"vim-sublime-monokai",
		},
		config = function()
			require("lualine").setup({
				options = {
					component_separators = "",
					icons_enabled = false,
					section_separators = "",
					theme = "powerline",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "filename" },
					lualine_c = { { "diagnostics", sources = { "nvim_diagnostic" } } },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	})

	-- Navigation

	--   Basic keyboard navigation bindings

	noremap("v", "<C-Left>", "B")
	noremap("v", "<C-Right>", "E")
	--   Make Home go to the beginning of the indented line, not the line itself
	noremap("", "<Home>", "^")
	-- Xterm bindings
	map("i", "", "<C-o>o")
	map("i", "", "<C-o>O")

	-- These are annoying! Just disable them.
	noremap("", "<S-Up>", "<Nop>")
	noremap("", "<S-Down>", "<Nop>")

	use({
		"dominikduda/vim_current_word",
		after = {
			"vim-sublime-monokai",
		},
		setup = function()
			vim.g["vim_current_word#highlight_only_in_focused_window"] = 1
		end,
		config = function()
			vim.cmd([[
			hi! link CurrentWord Underlined
			hi! link CurrentWordTwins Underlined
			]])
		end,
	})

	--   Mouse scrolling

	noremap("", "<C-ScrollWheelDown>", "3zl")
	noremap("", "<C-ScrollWheelUp>", "3zh")

	--   Text search

	vim.opt.hlsearch = true
	vim.opt.ignorecase = true
	vim.opt.incsearch = true
	vim.opt.smartcase = true
	vim.cmd([[hi! link Search Underlined]])

	use("haya14busa/is.vim")

	use({
		"haya14busa/vim-asterisk",
		config = function()
			map("", "*", " <Plug>(asterisk-z*)<Plug>(is-nohl-1)")
			map("", "g*", "<Plug>(asterisk-gz*)<Plug>(is-nohl-1)")
			map("", "#", " <Plug>(asterisk-z#)<Plug>(is-nohl-1)")
			map("", "g#", "<Plug>(asterisk-gz#)<Plug>(is-nohl-1)")
		end,
	})

	use({
		"osyo-manga/vim-anzu",
		config = function()
			map("", "n", "<Plug>(is-nohl)<Plug>(anzu-n-with-echo)")
			map("", "N", "<Plug>(is-nohl)<Plug>(anzu-N-with-echo)")
		end,
	})

	use({
		"dyng/ctrlsf.vim",
		event = { "BufEnter" },
		setup = function()
			vim.g.ctrlsf_auto_focus = { at = "start" }
			vim.api.nvim_set_keymap("n", "<Leader>H", ":CtrlSF<Space>", { noremap = true })
			vim.g.ctrlsf_indent = 2
			vim.g.ctrlsf_search_mode = "async"
		end,
	})

	--   TODO: Tag search

	-- Buffer manipulation

	use("tpope/vim-repeat")

	use("christoomey/vim-sort-motion")

	use("tpope/vim-unimpaired") -- sort of a kitchen sink plugin

	use("tpope/vim-endwise")

	--   Default max document width

	-- TODO: only do this once?
	vim.opt.colorcolumn = "+1"
	vim.opt.formatoptions = vim.opt.formatoptions - { "l" } + { "t" }
	vim.opt.textwidth = 100

	function set_row_limit(textwidth)
		vim.opt_local = textwidth
	end
	command("SetRowLimit", set_row_limit, { nargs = 1 })
	augroup("DefaultRowLimit", function(au)
		au("FileType", "*", function()
			vim.cmd.SetRowLimit(100)
		end)
	end)

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
		command("Append" .. name, cmd)
		noremap("n", "<Leader>" .. sequence, cmd)
	end
	map_device_character_append(";", "Semicolon")
	map_device_character_append(".", "Period")
	map_device_character_append(",", "Comma")

	--   Yanking

	use({
		"machakann/vim-highlightedyank",
		setup = function()
			vim.g.highlightedyank_highlight_duration = 50
		end,
	})

	--   Search-and-replace

	map("", "<Leader>h", ":%s/")
	map("v", "<Leader>h", ":s/")

	use("mg979/vim-visual-multi")

	--   Indentation/whitespace

	-- TODO: Does this actually work?
	if vim.g.erichdongubler_initted_indent_opts == nil then
		vim.opt.autoindent = true
		vim.opt.backspace = "indent,eol,start"
		vim.opt.shiftwidth = 4
		vim.opt.softtabstop = 4
		vim.opt.tabstop = 4

		vim.g.erichdongubler_initted_indent_opts = true
	end

	use({
		"ciaranm/detectindent",
		config = function()
			augroup("DetectIndent", function(au)
				au("BufReadPost", "*", function()
					vim.cmd.DetectIndent()
				end)
			end)
		end,
	})

	use("rhlobo/vim-super-retab")

	use({
		"junegunn/vim-easy-align",
		config = function()
			map("x", "ga", vim.cmd["<Plug>(EasyAlign)"])
			map("n", "ga", vim.cmd["<Plug>(EasyAlign)"])
		end,
	})

	--   Line breaks

	vim.opt.display:append({ "lastline" })
	vim.opt.formatoptions:remove({
		"t", -- Disable hard breaks at textwidth boundary
	})
	-- Show soft-wrapped text with extra indent of 2 spaces
	vim.opt.breakindentopt = "shift:2"
	vim.opt.showbreak = "->"

	function word_wrap_opts_namespace(global)
		return global and vim.o or vim.wo
	end
	function toggle_word_wrap(global)
		set_word_wrap(not word_wrap_opts_namespace(global).wrap, global)
	end
	function set_word_wrap(enabled, global)
		local opts_namespace = word_wrap_opts_namespace(global)
		opts_namespace.breakindent = enabled
		opts_namespace.linebreak = enabled
		opts_namespace.wrap = enabled
	end
	set_word_wrap(false, true)
	command("DisableWordWrap", bind_fuse(set_word_wrap, false), { nargs = 0 })
	command("EnableWordWrap", bind_fuse(set_word_wrap, true), { nargs = 0 })
	noremap("n", "<Leader><Tab>", bind_fuse(toggle_word_wrap, false))
	noremap("n", "<Leader><S-Tab>", bind_fuse(toggle_word_wrap, true))

	--   Brackets

	use({
		"cohama/lexima.vim",
		event = { "BufRead" },
		setup = function()
			vim.g.lexima_no_default_rules = true
		end,
		config = function()
			vim.fn["lexima#set_default_rules"]()
		end,
	})

	use({
		"andymass/vim-matchup",
		after = {
			"vim-sublime-monokai",
			"vim-sandwich",
		},
		requires = {
			"vim-sublime-monokai",
		},
		setup = function()
			vim.g.matchup_matchparen_deferred = 1
			vim.g.matchup_matchparen_hi_surround_always = 1
			vim.g.matchup_override_vimtex = 1
			vim.g.matchup_surround_enabled = 1
		end,
		config = function()
			vim.cmd([[
			hi! clear MatchParenCur
			hi! clear MatchWordCur
			]])
			vim.fn["g:SublimeMonokaiHighlight"]("MatchParen", { format = "reverse" })
			vim.fn["g:SublimeMonokaiHighlight"]("MatchTag", { format = "reverse" })
			vim.fn["g:SublimeMonokaiHighlight"]("MatchWord", { format = "reverse" })
		end,
	})

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

	use({
		"machakann/vim-sandwich",
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
	})

	--   Casing

	use({
		"arthurxavierx/vim-caser",
		event = { "BufEnter" },
		setup = function()
			vim.g.caser_prefix = "gS"
		end,
	})

	--   Commentary

	-- -- TODO: Is this better than `vim-commentary`?
	use({
		"b3nj5m1n/kommentary",
		event = { "BufEnter" },
		config = function()
			require("kommentary.config").configure_language("default", {
				prefer_single_line_comments = true,
				use_consistent_indentation = true,
			})
		end,
	})
	-- use 'tpope/vim-commentary'

	--   Text object/smart content manipulation

	use({
		"FooSoft/vim-argwrap",
		config = function()
			noremap("n", "<Leader>]", vim.cmd.ArgWrap, { silent = true })
		end,
	})
	use("peterrincker/vim-argumentative")

	use("tommcdo/vim-ninja-feet")
	use("wellle/targets.vim")
	use("glts/vim-textobj-comment")
	use("kana/vim-textobj-entire")
	use("kana/vim-textobj-function")
	use("kana/vim-textobj-indent")
	use("kana/vim-textobj-line")
	use("kana/vim-textobj-user")
	use("thalesmello/vim-textobj-methodcall")

	--     URLs

	use("mattn/vim-textobj-url")
	use({
		"tyru/open-browser.vim",
		config = function()
			map("", "<Leader>u", "<Plug>(openbrowser-smart-search)")
		end,
	})

	-- CVS integration

	use("knsh14/vim-github-link")

	use({
		"lewis6991/gitsigns.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
		},
		event = { "BufReadPost" },
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { hl = "GitSignsAdd", text = "+", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
					change = {
						hl = "GitSignsChange",
						text = "|",
						numhl = "GitSignsChangeNr",
						linehl = "GitSignsChangeLn",
					},
					delete = {
						hl = "GitSignsDelete",
						text = "_",
						numhl = "GitSignsDeleteNr",
						linehl = "GitSignsDeleteLn",
					},
					topdelete = {
						hl = "GitSignsDelete",
						text = "‾",
						numhl = "GitSignsDeleteNr",
						linehl = "GitSignsDeleteLn",
					},
					changedelete = {
						hl = "GitSignsChange",
						text = "~",
						numhl = "GitSignsChangeNr",
						linehl = "GitSignsChangeLn",
					},
				},
				keymaps = {
					noremap = true,

					["n ]h"] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'" },
					["v ]h"] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'" },
					["n [h"] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'" },
					["v [h"] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'" },

					["n ghs"] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
					["v ghs"] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
					["n ghu"] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
					["v ghu"] = '<cmd>lua require"gitsigns".undo_stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
					["n ghr"] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
					["v ghr"] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
					["n ghR"] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
					["n ghp"] = '<cmd>lua require"gitsigns".preview_hunk_inline()<CR>',
					["n ghb"] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',
					["n ghS"] = '<cmd>lua require"gitsigns".stage_buffer()<CR>',
					["n ghU"] = '<cmd>lua require"gitsigns".reset_buffer_index()<CR>',

					-- Text objects
					["o ih"] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
					["x ih"] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
				},
			})
		end,
	})

	use({
		"tpope/vim-fugitive",
		config = function()
			local git = vim.cmd.Git
			noremap("n", "ghB", function()
				git("blame")
			end)
		end,
	})

	-- Time tracking via Wakatime
	use({
		"ErichDonGubler/vim-wakatime", -- TODO: use upstream
		branch = "neovim-no-detach",
	})

	-- fix `tmux` focus
	use("tmux-plugins/vim-tmux-focus-events")

	-- Advanced IDE-like experience

	--   Tags: the poor man's Intellisense database

	vim.opt.tags = ".tags"
	augroup("tags", function(au)
		au({ "BufNewFile", "BufRead" }, ".tags", function()
			vim.opt_local.filetype = "tags"
		end)
	end)
	use({
		"ludovicchabant/vim-gutentags",
		setup = function()
			if vim.fn.executable("fd") then
				vim.g.gutentags_file_list_command = "fd --follow --type file"
			elseif vim.fn.executable("rg") then
				vim.g.gutentags_file_list_command = "rg --follow --files"
			else
				vim.g.gutentags_resolve_symlinks = 1
			end

			vim.g.gutentags_cache_dir = vim.fn.stdpath("cache") .. "/gutentags"
			if not vim.fn.isdirectory(vim.g.gutentags_cache_dir) then
				vim.fn.mkdir(vim.g.gutentags_cache_dir)
			end

			vim.g.gutentags_ctags_tagfile = ".tags"
		end,
	})

	use({
		"majutsushi/tagbar",
		config = function()
			noremap("n", "<Leader>t", vim.cmd.TagbarToggle)
		end,
	})

	--   Snippets

	use({
		"SirVer/ultisnips",
		event = { "BufEnter" },
		disable = vim.fn.has("python3") == 0,
		requires = {
			"honza/vim-snippets",
		},
		setup = function()
			vim.g.UltiSnipsExpandTrigger = "<Tab>"
			vim.g.UltiSnipsJumpForwardTrigger = "<Tab>"
			vim.g.UltiSnipsJumpBackwardTrigger = "<S-Tab>"
		end,
	})
	-- -- TODO: Determine if this is better than Ultisnips
	-- use 'hrsh7th/vim-vsnip'

	--   LSP

	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
		virtual_text = {
			prefix = "»",
			spacing = 2,
		},
		signs = true,
		update_in_insert = true,
	})
	vim.fn.sign_define("DiagnosticSignError", { text = ">>", texthl = "DiagnosticSignError" })
	vim.fn.sign_define("DiagnosticSignWarn", { text = ">>", texthl = "DiagnosticSignWarn" })
	vim.fn.sign_define("DiagnosticSignInfo", { text = "!!", texthl = "DiagnosticSignInfo" })
	vim.fn.sign_define("DiagnosticSignHint", { text = "??", texthl = "DiagnosticSignHint" })

	--     Show a nice diagnostic spinner for LSP operations
	use({
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup()
		end,
	})

	--     LSP bindings

	noremap("n", "<Leader>l<F2>", vim.lsp.buf.rename)
	noremap("n", "<Leader>lK", vim.lsp.buf.hover)
	noremap("n", "<Leader>lci", vim.lsp.buf.incoming_calls)
	noremap("n", "<Leader>lco", vim.lsp.buf.outgoing_calls)
	noremap("n", "[d", vim.diagnostic.goto_prev)
	noremap("n", "]d", vim.diagnostic.goto_next)

	-- TODO: Get colors and highlighting for LSP actually looking good
	augroup("ErichDonGublerCursorHoldLsp", function(au)
		au({ "CursorHold", "CursorHoldI" }, "*", vim.lsp.buf.document_highlight)
		au("CursorMoved", "*", vim.lsp.buf.clear_references)
	end)
	use({ "neovim/nvim-lspconfig" })

	use({
		"folke/lsp-trouble.nvim",
		event = {
			"BufReadPost",
		},
		config = function()
			local trouble = require("trouble")
			trouble.setup({
				fold_closed = ">",
				fold_open = "v",
				icons = false,
				use_diagnostic_signs = true,
			})
			local trouble_bindings_normal = {
				["<Leader>M"] = trouble.toggle,
				["<Leader>md"] = bind_fuse(trouble.toggle, "document_diagnostics"),
				["<Leader>mq"] = bind_fuse(trouble.toggle, "loclist"),
				["<Leader>mw"] = bind_fuse(trouble.toggle, "workspace_diagnostics"),
			}
			for binding, cmd in pairs(trouble_bindings_normal) do
				noremap("n", binding, cmd, { silent = true })
			end
		end,
	})

	--   Completion

	vim.opt.completeopt = "menuone,noinsert,noselect"
	-- vim.opt.shortmess:append({ 'c' })

	use({
		"hrsh7th/nvim-cmp",
		event = { "BufEnter" },
		requires = {
			"cmp-buffer",
			"cmp-cmdline",
			"cmp-nvim-lsp",
			"cmp-nvim-tags",
			"cmp-nvim-ultisnips",
			"cmp-path",
			"ultisnips",
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
					["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
					["<C-y>"] = cmp.config.disable,
					["<C-e>"] = cmp.mapping({
						i = cmp.mapping.abort(),
						c = cmp.mapping.close(),
					}),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
				}),
				snippet = {
					expand = function(args)
						vim.fn["UltiSnips#Anon"](args.body)
					end,
				},
				sources = cmp.config.sources({
					{ name = "buffer" },
					{ name = "nvim_lsp" },
					{ name = "tags" },
					{ name = "ultisnips" },
				}),
			})

			for _, cmd_type in ipairs({ "/", "?" }) do
				cmp.setup.cmdline(cmd_type, {
					sources = {
						{ name = "buffer" },
					},
				})
			end

			cmp.setup.cmdline(":", {
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	})
	use({
		"hrsh7th/cmp-buffer",
		after = "nvim-cmp",
	})
	use({
		"hrsh7th/cmp-cmdline",
		after = "nvim-cmp",
	})
	use({
		"hrsh7th/cmp-nvim-lsp",
		after = {
			"nvim-cmp",
			"nvim-lspconfig",
		},
		config = function()
			require("lspconfig").clangd.setup({
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})
		end,
	})
	use({
		"hrsh7th/cmp-path",
		after = "nvim-cmp",
	})
	use({
		"quangnguyen30192/cmp-nvim-tags",
		after = "nvim-cmp",
	})
	use({
		"quangnguyen30192/cmp-nvim-ultisnips",
		after = "nvim-cmp",
	})

	--   Auto-formatting

	use({
		"ntpeters/vim-better-whitespace",
		after = {
			"vim-sublime-monokai",
		},
		setup = function()
			vim.g.better_whitespace_operator = "_s"
			vim.g.show_spaces_that_precede_tabs = 0
			vim.g.strip_whitespace_confirm = 0
			vim.cmd([[
			hi! link ExtraWhitespace Error
			]])
		end,
	})

	use({
		"Chiel92/vim-autoformat",
		disable = vim.fn.has("python3") == 0,
		config = function()
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

			local switch_to_file_events = { "BufNewFile", "BufRead" }

			local file_type_event = { "FileType" }

			local blacklist_entries = {}
			function blacklist(event, pattern, callback)
				blacklist_entries[event] = blacklist_entries[event] or {}
				local event = blacklist_entries[event]

				event[callback] = event[callback] or {}
				local callback = event[callback]

				callback[pattern] = {}
			end

			blacklist(switch_to_file_events, "*.diff", disable_whitespace_fixing)
			blacklist(switch_to_file_events, "*.patch", disable_whitespace_fixing)
			blacklist(file_type_event, "diff", disable_whitespace_fixing)
			blacklist(file_type_event, "ctrlsf", disable_whitespace_fixing)
			blacklist(file_type_event, "git", disable_whitespace_fixing)
			blacklist(file_type_event, "gitrebase", disable_whitespace_fixing)
			blacklist(file_type_event, "gitcommit", disable_indentation_fixing)

			blacklist(switch_to_file_events, "git-rebase-todo", disable_whitespace_fixing)
			blacklist(switch_to_file_events, "git-revise-todo", disable_whitespace_fixing)
			blacklist(switch_to_file_events, "*.md", disable_indentation_fixing)
			blacklist(file_type_event, "markdown", disable_indentation_fixing)
			blacklist(file_type_event, "snippets", disable_whitespace_fixing)
			blacklist(file_type_event, "typescript", disable_indentation_fixing)
			blacklist(file_type_event, "javascript", disable_indentation_fixing)
			blacklist(file_type_event, "rust", disable_indentation_fixing)
			blacklist(file_type_event, "toml", disable_indentation_fixing)
			blacklist(file_type_event, "sh", disable_indentation_fixing)
			blacklist(file_type_event, "dot", disable_indentation_fixing)
			blacklist(file_type_event, "xml", disable_indentation_fixing)
			blacklist(file_type_event, "cpp", disable_whitespace_fixing)
			blacklist(file_type_event, "csv", disable_whitespace_fixing)
			blacklist(file_type_event, "dosini", disable_indentation_fixing)

			augroup("WhitespaceAutoformatBlacklist", function(au)
				for events, rest in pairs(blacklist_entries) do
					for callback, rest in pairs(rest) do
						for pattern, _should_be_nil in pairs(rest) do
							au(events, pattern, callback)
						end
					end
				end
			end)
		end,
	})

	-- Debugging
	-- TODO: Investigate https://github.com/mfussenegger/nvim-dap

	-- Specialized editing modes

	use("vitalk/vim-shebang")

	use("fidian/hexmode")

	--   Language-specific integration

	--     Document languages

	use({
		"plasticboy/vim-markdown",
		requires = {
			"tagbar",
		},
		config = function()
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
	})
	use({
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	})

	use({
		"liuchengxu/graphviz.vim",
		setup = function()
			vim.g.graphviz_output_format = "svg"
		end,
	})

	use({
		"jceb/vim-orgmode",
		requires = {
			"tpope/vim-speeddating",
		},
		setup = function()
			vim.g.org_heading_highlight_colors = { "Identifier" }
			vim.g.org_heading_highlight_levels = 10
		end,
		config = function()
			augroup("orgmode", function(au)
				au("FileType", { "text", "org" }, vim.cmd.EnableWordWrap)
			end)
		end,
	})

	--     Shell scripting languages

	use("pprovost/vim-ps1")

	--     Data/configuration/IDL-ish languages

	use("gisphm/vim-gitignore")

	use("cespare/vim-toml")

	use("zchee/vim-flatbuffers")

	use("gutenye/json5.vim")

	--     Native world

	use("pboettch/vim-cmake-syntax")

	use("octol/vim-cpp-enhanced-highlight")

	use({
		"rust-lang/rust.vim",
		after = {
			"cmp-nvim-lsp",
			"nvim-lspconfig",
			"vim-sublime-monokai",
			"vim-sandwich",
		},
		requires = {
			"cmp-nvim-lsp",
			"nvim-lspconfig",
			"vim-sandwich",
			"vim-shebang",
			"vim-sublime-monokai",
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
			end)

			-- TODO
			function configure_rust()
				local cargo = vim.cmd.Cargo
				local rust_bindings = {
					b = bind_fuse(cargo, "build"),
					B = bind_fuse(cargo, "build", "--release"),
					c = bind_fuse(cargo, "check"),
					d = bind_fuse(cargo, "doc"),
					D = bind_fuse(cargo, "doc", "--open"),
					F = bind_fuse(cargo, "fmt"),
					f = vim.cmd.RustFmt,
					p = vim.cmd.RustPlay,
					r = bind_fuse(cargo, "run"),
					R = bind_fuse(cargo, "run", "--release"),
					s = function()
						cargo("script", vim.cmd.expand("%"))
					end,
					t = vim.cmd.RustTest,
					T = bind_fuse(cargo, "test"),
				}
				for binding, cmd in pairs(rust_bindings) do
					noremap("n", "<LocalLeader>" .. binding, cmd)
				end
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
	})

	--     Web

	use({
		"pangloss/vim-javascript",
		requires = {
			"tagbar",
			"vim-sublime-monokai",
		},
		setup = function()
			vim.g.tagbar_type_javascript = {
				ctagstype = "JavaScript",
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
			hi! link jsRegexpCharClass  Special
			hi! link jsRegexpBackRef    SpecialChar
			hi! link jsRegexpMod        SpecialChar
			hi! link jsRegexpOr         SpecialChar
			]])
		end,
	})

	use("mxw/vim-jsx")

	use({
		"leafgarland/typescript-vim",
		after = {
			"cmp-nvim-lsp",
			"nvim-lspconfig",
		},
		requires = {
			"cmp-nvim-lsp",
			"nvim-lspconfig",
		},
		config = function()
			require("lspconfig").tsserver.setup({
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})
		end,
	})

	use({
		"posva/vim-vue",
		ft = { "markdown" },
		run = function()
			if vim.fn.executable("npm") then
				vim.cmd("silent !npm i -g eslint eslint-plugin-vue")
			end
		end,
	})

	use("andys8/vim-elm-syntax")

	--     Other general-purpose languages

	vim.g.java_comment_strings = 1
	vim.g.java_highlight_functions = 1
	vim.g.java_highlight_java_lang_ids = 1

	use("OrangeT/vim-csharp")

	use({
		"fatih/vim-go",
		after = {
			"vim-sublime-monokai",
		},
		setup = function()
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
	})

	use({
		"StanAngeloff/php.vim",
		after = {
			"vim-sublime-monokai",
		},
		setup = function()
			vim.g.php_var_selector_is_identifier = 1
		end,
		config = function()
			vim.cmd([[
			hi! link phpMemberSelector Keyword
			]])
		end,
	})

	-- NOTE: This _must_ be at the end!
	if packer_bootstrap then
		require("packer").sync()
	end
end)
