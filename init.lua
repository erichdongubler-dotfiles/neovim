-- Stolen from https://github.com/wbthomason/packer.nvim#bootstrapping

local packer_bootstrap = false
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	print("`packer` is missing, installing...")
	packer_bootstrap = vim.fn.system({ "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path })
	vim.cmd("packadd packer.nvim")
end

require("packer").startup(function()
	vim.cmd([[
	augroup PackerUpdate
	au!
	au BufWritePost init.lua source <afile> | PackerCompile profile=true
	au User PackerCompileDone lua vim.notify('Finished compiling Packer startup script.', nil, { title = "`PackerCompile` finished" })
	augroup END
	]])
	vim.cmd("nnoremap <Leader>vs <cmd>source " .. vim.fn.stdpath("config") .. "/init.lua <Bar> PackerCompile<CR>")
	vim.cmd("nnoremap <Leader>ve <cmd>e " .. vim.fn.stdpath("config") .. "/init.lua<CR>")

	use("wbthomason/packer.nvim")

	-- Disable freezing on Windows when we press `CTRL + Z`.
	if vim.fn.has("win32") then
		vim.api.nvim_set_keymap("", "<C-z>", "<Nop>", {})
	end

	vim.opt.mouse = "a"
	vim.cmd("behave xterm")

	vim.opt.wildmode = "longest,list,full"
	vim.cmd([[set iskeyword-=.#]])

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
			vim.cmd([[
			augroup ScrollbarInit
			autocmd!
			autocmd CursorMoved,VimResized,QuitPre * silent! lua require('scrollbar').show()
			autocmd WinEnter,FocusGained           * silent! lua require('scrollbar').show()
			autocmd WinLeave,BufLeave,BufWinLeave,FocusLost            * silent! lua require('scrollbar').clear()
			augroup end
			]])
		end,
	})

	-- Replace several vanilla Neovim/Vim UIs with nicer ones
	use("stevearc/dressing.nvim")

	-- vimdiff: use vertical layout
	vim.opt.diffopt = vim.opt.diffopt + { "vertical" }

	--   Whitespace

	function set_listchars_verbose()
		vim.opt.list = true
		vim.cmd([[ set listchars= ]]) -- NOTE: this is a hack -- there's no clearing or resetting from assignment below. :(
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
		vim.opt.list = true
		vim.cmd([[ set listchars= ]]) -- NOTE: this is a hack -- there's no clearing or resetting from assignment below. :(
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

	if not vim_indentguides_disabled then
		function disable_indentguides()
			vim.b.toggle_indentguides = 0
			vim.cmd([[
			IndentGuidesToggle
			]])
			set_listchars_verbose()
		end
		_G.disable_indentguides = disable_indentguides

		function enable_indentguides()
			vim.b.toggle_indentguides = 1
			vim.cmd([[
			IndentGuidesToggle
			]])
			set_listchars_quiet()
		end
		_G.enable_indentguides = enable_indentguides

		local is_indentation_verbose = false -- `vim-indentguides` is definitely enabled if we arrive here.
		function _G.toggle_list_verbosity()
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
		function _G.toggle_list_verbosity()
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

	vim.cmd([[
	command! -nargs=0 ToggleListVerbosity call v:lua.toggle_list_verbosity()
	nnoremap <Leader>i :call v:lua.toggle_list_verbosity()<CR>
	]])

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
			vim.cmd("map <Esc>[" .. subbed .. " <" .. vim_modifier .. "-" .. vim_keycode_name .. ">")
			vim.cmd("inoremap <Esc>[" .. subbed .. " <" .. vim_modifier .. "-" .. vim_keycode_name .. ">")
		end
	end

	--   rvxt bindings

	vim.cmd([[
	map <Esc>Oa <C-Up>
	map <Esc>Ob <C-Down>
	map <Esc>Oc <C-Right>
	map <Esc>Od <C-Left>
	map <Esc>[5^ <C-PageUp>
	map <Esc>[6^ <C-PageDown>
	]])

	--

	-- TODO: `list` and altering how to present characters

	-- Buffer/pane management

	vim.opt.hidden = true
	vim.opt.splitbelow = true
	vim.opt.splitright = true

	vim.cmd([[
	"   Alias Q to do what we really want
	command! Q :q
	command! -bang Q :q!
	command! Qa :qa
	command! -bang Qa :qa!
	command! QA :qa
	command! -bang QA :qa!
	nnoremap <Leader>q <cmd>q<CR>
	nnoremap <Leader>Q <cmd>q!<CR>
	nnoremap <Leader> <cmd>qa!<CR>
	"   Get a Leader mapping for saves
	nmap <Leader>s <cmd>w<CR>
	command! -bang W :w!
	]])

	--   File change management
	vim.opt.undofile = true
	use("mbbill/undotree")
	use({
		"ErichDonGubler/vim-playnice",
		branch = "initial-release",
		setup = function()
			vim.opt.autoread = true
		end,
	})

	--   Buffer display above
	use({
		"famiu/bufdelete.nvim",
		config = function()
			vim.cmd([[
			nnoremap <Leader>w <cmd>:bw<CR>
			]])
		end,
	})
	use({
		"akinsho/bufferline.nvim",
		tag = "v3.*",
		after = {
			"bufdelete.nvim",
			"vim-sublime-monokai",
		},
		requires = {
			"bufdelete.nvim",
			"vim-sublime-monokai",
		},
		config = function()
			vim.cmd([[
			" Replace default bindings
			nnoremap <silent> ]b <cmd>BufferLineCycleNext<CR>
			nnoremap <silent> [b <cmd>BufferLineCyclePrev<CR>
			nnoremap <silent> <C-PageUp> <cmd>BufferPrevious<CR>
			nnoremap <silent> <C-PageDown> <cmd>BufferNext<CR>

			nnoremap <Leader>W :BufferLineCloseRight<CR>:BufferLineCloseLeft<CR>

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
			require("bufferline").setup({
				options = {
					buffer_close_icon = "⤬",
					close_command = function(bufnum)
						require("bufdelete").bufdelete(bufnum, true)
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
			vim.cmd([[
			nnoremap <Leader>e <cmd>SelectCurrentFile<CR>
			nnoremap <Leader>x <cmd>OpenCurrentFile<CR>
			nnoremap <Leader>E <cmd>OpenCWD<CR>
			]])
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
			require("telescope").setup({
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
			vim.cmd([[
			nnoremap <Leader>D <cmd>Telescope diagnostics<CR>
			nnoremap <Leader>O <cmd>Telescope buffers<CR>
			nnoremap <Leader>R <cmd>Telescope tags<CR>
			nnoremap <Leader>T <cmd>Telescope builtin<CR>
			nnoremap <Leader>d <cmd>Telescope diagnostics bufnr=0<CR>
			nnoremap <Leader>f <cmd>Telescope live_grep<CR>
			nnoremap <Leader>o <cmd>Telescope oldfiles<CR>
			nnoremap <Leader>p <cmd>Telescope find_files<CR>
			nnoremap <Leader>l<C-]> <cmd>Telescope lsp_definitions<CR>
			nnoremap <Leader><F12> <cmd>Telescope lsp_definitions<CR>
			nnoremap <Leader>lR <cmd>Telescope lsp_dynamic_workspace_symbols<CR>
			nnoremap <Leader>la <cmd>lua vim.lsp.buf.code_action()<CR>
			nnoremap <Leader>lgd <cmd>Telescope lsp_definitions<CR>
			nnoremap <Leader>lgi <cmd>Telescope lsp_implementations<CR>
			nnoremap <Leader>lgr <cmd>Telescope lsp_references<CR>
			nnoremap <Leader><M-S-F12> <cmd>Telescope lsp_references<CR>
			nnoremap <Leader>lgt <cmd>Telescope lsp_type_definitions<CR>
			nnoremap <Leader>lr <cmd>Telescope lsp_document_symbols<CR>
			nnoremap <Leader>r <cmd>Telescope current_buffer_tags<CR>

			vnoremap <Leader>la <cmd>lua vim.lsp.buf.range_code_action()<CR>
			]])
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
			vim.cmd([[
			nnoremap <c-]> <cmd>CtrlPtjump<CR>
			vnoremap <c-]> <cmd>CtrlPtjumpVisual<CR>
			]])
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
		"kyazdani42/nvim-tree.lua",
		event = {
			"BufReadPost",
		},
		config = function()
			vim.cmd([[
			nnoremap <Leader>k <cmd>NvimTreeToggle<CR>
			nnoremap - <cmd>NvimTreeFindFile<CR>
			]])
			require("nvim-tree").setup({
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
	function _G.syntax_stack()
		if not vim.fn.exists("*synstack") then
			return
		end
		return vim.fn.map(vim.fn.synstack(vim.fn.line("."), vim.fn.col(".")), 'synIDattr(v:val, "name")')
	end
	vim.cmd([[
	command! -nargs=0 EchoHighlightingGroup echo v:lua.syntax_stack()
	nnoremap <leader>0 :EchoHighlightingGroup<CR>
	]])

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

	vim.cmd([[
	vnoremap <C-Left> B
	vnoremap <C-Right> E
	"   Make Home go to the beginning of the indented line, not the line itself
	noremap <Home> ^
	" Xterm bindings
	imap  <C-o>o
	imap  <C-o>O

	" These are annoying! Just disable them.
	noremap <S-Up> <Nop>
	noremap <S-Down> <Nop>
	]])

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

	vim.cmd([[
	noremap <C-ScrollWheelDown> 3zl
	noremap <C-ScrollWheelUp> 3zh
	]])

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
			vim.cmd([[
			map *  <Plug>(asterisk-z*)<Plug>(is-nohl-1)
			map g* <Plug>(asterisk-gz*)<Plug>(is-nohl-1)
			map #  <Plug>(asterisk-z#)<Plug>(is-nohl-1)
			map g# <Plug>(asterisk-gz#)<Plug>(is-nohl-1)
			]])
		end,
	})

	use({
		"osyo-manga/vim-anzu",
		config = function()
			vim.cmd([[
			map n <Plug>(is-nohl)<Plug>(anzu-n-with-echo)
			map N <Plug>(is-nohl)<Plug>(anzu-N-with-echo)
			]])
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

	--   Default max document width

	-- TODO: only do this once?
	vim.opt.colorcolumn = "+1"
	vim.opt.formatoptions = vim.opt.formatoptions - { "l" } + { "t" }
	vim.opt.textwidth = 100

	vim.cmd([[
	command! -nargs=1 SetRowLimit setlocal textwidth=<args>

	augroup DefaultRowLimit
	au!
	au FileType * SetRowLimit 100
	augroup END
	]])

	--   Add some common line-ending shortcuts
	function _G.append_chars(sequence)
		local line = vim.fn.line(".")
		local col = vim.fn.col(".")
		vim.cmd("exec 'normal! A" .. sequence .. "'")
		vim.fn.cursor(line, col)
	end
	function map_device_character_append(sequence, name)
		vim.cmd("command! -nargs=0 Append" .. name .. " call v:lua.append_chars('" .. sequence .. "')")
		vim.cmd("nnoremap <Leader>" .. sequence .. " <cmd>Append" .. name .. "<CR>")
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

	vim.cmd([[
	map <Leader>h :%s/
	vmap <Leader>h :s/
	]])

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
			vim.cmd([[
			augroup DetectIndent
			au!
			au BufReadPost * :DetectIndent
			augroup END
			]])
		end,
	})

	use("rhlobo/vim-super-retab")

	use({
		"junegunn/vim-easy-align",
		config = function()
			vim.cmd([[
			xmap ga <Plug>(EasyAlign)
			nmap ga <Plug>(EasyAlign)
			]])
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
	function _G.toggle_word_wrap(global)
		_G.set_word_wrap(not word_wrap_opts_namespace(global).wrap, global)
	end
	function _G.set_word_wrap(enabled, global)
		local opts_namespace = word_wrap_opts_namespace(global)
		opts_namespace.breakindent = enabled
		opts_namespace.linebreak = enabled
		opts_namespace.wrap = enabled
	end
	_G.set_word_wrap(false, true)
	vim.cmd([[
	command! -nargs=0 DisableWordWrap call v:lua.set_word_wrap(v:false)
	command! -nargs=0 EnableWordWrap call v:lua.set_word_wrap(v:true)
	]])
	vim.api.nvim_set_keymap("n", "<Leader><Tab>", ":call v:lua.toggle_word_wrap(v:false)<CR>", { noremap = true })
	vim.api.nvim_set_keymap("n", "<Leader><S-Tab>", ":call v:lua.toggle_word_wrap(v:true)<CR>", { noremap = true })

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
	function _G.init_sandwich_recipes_once()
		if not sandwich_initted then
			-- Not sure why this needs to be in vimscript. :scratch-head:
			vim.cmd("let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)")
			sandwich_initted = true
		end
	end

	use({
		"machakann/vim-sandwich",
		event = { "BufEnter" },
		config = function()
			_G.init_sandwich_recipes_once()

			local recipes = vim.g["sandwich#recipes"]
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
			for _, v in pairs(vim_surround_ish_recipes) do
				table.insert(recipes, v)
			end

			vim.g["sandwich#recipes"] = recipes
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
			vim.cmd([[
			nnoremap <silent> <leader>] <cmd>ArgWrap<CR>
			]])
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
			vim.cmd([[
			map <Leader>u <Plug>(openbrowser-smart-search)
			]])
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
			vim.cmd([[
			nnoremap ghB <cmd>Git blame<CR>
			]])
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
	vim.cmd([[
	augroup tags
	au!
	au BufNewFile,BufRead .tags setlocal filetype=tags
	augroup END
	]])
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
			vim.cmd([[nmap <Leader>t <cmd>TagbarToggle<CR>]])
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

	vim.cmd([[
	nnoremap <Leader>l<F2> <cmd>lua vim.lsp.buf.rename()<CR>
	nnoremap <Leader>lK <cmd>lua vim.lsp.buf.hover()<CR>
	nnoremap <Leader>lci <cmd>lua vim.lsp.buf.incoming_calls()<CR>
	nnoremap <Leader>lco <cmd>lua vim.lsp.buf.outgoing_calls()<CR>
	nnoremap [d :lua vim.diagnostic.goto_prev()<cr>
	nnoremap ]d :lua vim.diagnostic.goto_next()<cr>
	]])

	-- TODO: Get colors and highlighting for LSP actually looking good
	vim.cmd([[
	augroup ErichDonGublerCursorHoldLsp
	au!
	au CursorHold  * lua vim.lsp.buf.document_highlight()
	au CursorHoldI * lua vim.lsp.buf.document_highlight()
	au CursorMoved * lua vim.lsp.buf.clear_references()
	augroup END
	]])
	use({ "neovim/nvim-lspconfig" })

	use({
		"folke/lsp-trouble.nvim",
		event = {
			"BufReadPost",
		},
		config = function()
			local trouble_bindings_normal = {
				M = "TroubleToggle",
				md = "TroubleToggle document_diagnostics",
				mq = "TroubleToggle loclist",
				mw = "TroubleToggle workspace_diagnostics",
			}
			for binding, cmd in pairs(trouble_bindings_normal) do
				vim.keymap.set("n", "<Leader>" .. binding, "<cmd>" .. cmd .. "<cr>", { silent = true, noremap = true })
			end
			require("trouble").setup({
				fold_closed = ">",
				fold_open = "v",
				icons = false,
				use_diagnostic_signs = true,
			})
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
			"cmp-calc",
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
					{ name = "calc" },
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
		"hrsh7th/cmp-calc",
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
			vim.cmd([[
			augroup WhitespaceAutoformat
			au!
			au BufWrite * :Autoformat
			augroup END
			]])

			function _G.disable_trailing_whitespace_stripping()
				vim.b.autoformat_remove_trailing_spaces = 0
			end
			function _G.disable_indentation_fixing()
				vim.b.autoformat_autoindent = 0
			end
			function _G.disable_retab()
				vim.b.autoformat_retab = 0
			end
			function _G.disable_whitespace_fixing()
				_G.disable_trailing_whitespace_stripping()
				_G.disable_indentation_fixing()
				_G.disable_retab()
			end
			vim.cmd([[
			augroup WhitespaceAutoformatBlacklist
			au!
			au BufNewFile,BufRead *.diff call v:lua.disable_whitespace_fixing()
			au BufNewFile,BufRead *.patch call v:lua.disable_whitespace_fixing()
			au FileType diff call v:lua.disable_whitespace_fixing()
			au FileType ctrlsf call v:lua.disable_whitespace_fixing()
			au FileType git call v:lua.disable_whitespace_fixing()
			au FileType gitrebase call v:lua.disable_whitespace_fixing()
			au FileType gitcommit call v:lua.disable_indentation_fixing()
			au BufNewFile,BufRead git-rebase-todo call v:lua.disable_whitespace_fixing()
			au BufNewFile,BufRead git-revise-todo call v:lua.disable_whitespace_fixing()
			au BufNewFile,BufRead *.md call v:lua.disable_indentation_fixing()
			au FileType markdown call v:lua.disable_indentation_fixing()
			au FileType snippets call v:lua.disable_whitespace_fixing()
			au FileType typescript call v:lua.disable_indentation_fixing()
			au FileType javascript call v:lua.disable_indentation_fixing()
			au FileType rust call v:lua.disable_indentation_fixing()
			au FileType toml call v:lua.disable_indentation_fixing()
			au FileType sh call v:lua.disable_indentation_fixing()
			au FileType dot call v:lua.disable_indentation_fixing()
			au FileType xml call v:lua.disable_indentation_fixing()
			au FileType cpp call v:lua.disable_whitespace_fixing()
			au FileType csv call v:lua.disable_whitespace_fixing()
			augroup END
			]])
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
			vim.cmd([[
			augroup markdown
			au!
			au FileType markdown SetRowLimit 80
			au FileType markdown EnableWordWrap
			augroup END
			]])
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
			vim.cmd([[
			augroup orgmode
			au!
			au FileType text,org :EnableWordWrap
			augroup END
			]])
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
		},
		requires = {
			"cmp-nvim-lsp",
			"nvim-lspconfig",
			"vim-sandwich",
			"vim-shebang",
			"vim-sublime-monokai",
		},
		config = function()
			_G.init_sandwich_recipes_once()

			local recipes = vim.g["sandwich#recipes"]

			-- TODO: These are broken. :(
			local add_rust_sandwich_binding = function(input, start, end_)
				table.insert(recipes, {
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

			vim.g["sandwich#recipes"] = recipes

			-- TODO
			function _G.configure_rust()
				vim.cmd([[
				nnoremap <LocalLeader>b <cmd>Cargo build<CR>
				nnoremap <LocalLeader>B <cmd>Cargo build --release<CR>
				nnoremap <LocalLeader>c <cmd>Cargo check<CR>
				nnoremap <LocalLeader>d <cmd>Cargo doc<CR>
				nnoremap <LocalLeader>D <cmd>Cargo doc --open<CR>
				nnoremap <LocalLeader>F <cmd>Cargo fmt<CR>
				nnoremap <LocalLeader>f <cmd>RustFmt<CR>
				nnoremap <LocalLeader>p <cmd>RustPlay<CR>
				nnoremap <LocalLeader>r <cmd>Cargo run<CR>
				nnoremap <LocalLeader>R <cmd>Cargo run --release<CR>
				nnoremap <LocalLeader>s <cmd>Cargo script "%"<CR>
				nnoremap <LocalLeader>t <cmd>RustTest<CR>
				nnoremap <LocalLeader>T <cmd>Cargo test<CR>
				]])
			end
			vim.cmd([[
			augroup rust
			au!
			au FileType rust call v:lua.configure_rust()
			augroup end
			]])

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
