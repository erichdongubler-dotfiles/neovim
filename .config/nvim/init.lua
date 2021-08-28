-- Stolen from https://github.com/wbthomason/packer.nvim#bootstrapping

local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	print("`packer` is missing, installing...")
	vim.fn.system({ 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path })
	vim.cmd 'packadd packer.nvim'
end

require('packer').startup(function()
	vim.cmd([[
	augroup PackerUpdate
	au!
	au BufWritePost init.lua source <afile> | PackerCompile
	augroup END
	]])
	vim.cmd('nnoremap <Leader>vs :source ' .. vim.fn.stdpath('config') .. '/init.lua<CR>')
	vim.cmd('nnoremap <Leader>ve :e ' .. vim.fn.stdpath('config') .. '/init.lua<CR>')

	use 'wbthomason/packer.nvim'

	vim.opt.mouse = 'a'

	vim.opt.wildmode = 'longest,list,full'
	vim.cmd [[set iskeyword-=.#]]

	vim.g.mapleader = '\\'
	vim.g.maplocalleader = '|'

	vim.opt.clipboard = 'unnamed,unnamedplus'

	vim.opt.encoding = 'utf-8'
	vim.opt.fileencoding = 'utf-8'
	use 's3rvac/AutoFenc'

	-- Buffer rendering

	vim.opt.cursorline = true
	vim.opt.number = true
	-- vim.opt.lazyredraw = true
	vim.opt.scrolloff = 5

	-- vimdiff: use vertical layout
	vim.opt.diffopt = vim.opt.diffopt + { 'vertical' }

	--   Whitespace

	-- -- TODO: This...doesn't seem great.
	-- vim.opt.fillchars = "vert:|"
	-- use {
	-- 	'lukas-reineke/indent-blankline.nvim',
	-- 	config = function()
	-- 		require("indent_blankline").setup {
	-- 			char = '┆',
	-- 			buftype_exclude = {"terminal"}
	-- 		}
	-- 	end
	-- }

	--   TODO: `limelight` and `goyo`?

	--   GUI fonts

	if vim.fn.has("gui_macvim") == 0 then
		vim.opt.guifont = 'Menlo Regular:h14'
	elseif vim.fn.has("gui_win32") == 0 then
		vim.opt.guifont = 'Consolas:h12'
		use {
			'drmikehenry/vim-fontdetect',
			config = function()
				if vim.fn['fontdetect#hasFontFamily']('Source Code Pro') then
					vim.opt.guifont = 'Source Code Pro:h11'
				end
			end
		}
	else
		vim.opt.guifont = 'Inconsolata 14'
	end

	-- Fix terminal-specific settings so we get the correct colors and keybinds

	-- --   Force background drawing in truecolor terminals
	-- vim.opt.t_ut = ''

	--   MinTTY bindings
	local mintty_keybind_modifiers_map = {
		['2'] = 'S',
		['3'] = 'M',
		['4'] = 'M-S',
		['5'] = 'C',
		['6'] = 'C-S',
	}
	local mintty_keys_to_map = {
		['Up']     = '1;%sA',
		['Down']   = '1;%sB',
		['Right']  = '1;%sC',
		['Left']   = '1;%sD',
		['PageUp'] = '5;%s~',
	}
	for vim_keycode_name, mintty_key_escape_pattern in pairs(mintty_keys_to_map) do
		for escape_modifier_num, vim_modifier in pairs(mintty_keybind_modifiers_map) do
			local subbed = mintty_key_escape_pattern:gsub("%%s", escape_modifier_num)
			vim.cmd('map <Esc>['..subbed..' <'..vim_modifier..'-'..vim_keycode_name..'>')
			vim.cmd('inoremap <Esc>['..subbed..' <'..vim_modifier..'-'..vim_keycode_name..'>')
		end
	end

	--   rvxt bindings

	vim.cmd [[
	map <Esc>Oa <C-Up>
	map <Esc>Ob <C-Down>
	map <Esc>Oc <C-Right>
	map <Esc>Od <C-Left>
	map <Esc>[5^ <C-PageUp>
	map <Esc>[6^ <C-PageDown>
	]]

	--

	-- TODO: `list` and altering how to present characters

	-- Buffer/pane management

	vim.opt.hidden = true
	vim.opt.splitbelow = true
	vim.opt.splitright = true

	vim.cmd [[
	"   Alias Q to do what we really want
	command! Q :q
	command! -bang Q :q!
	command! Qa :qa
	command! -bang Qa :qa!
	command! QA :qa
	command! -bang QA :qa!
	nnoremap <Leader>q :q<CR>
	nnoremap <Leader>Q :q!<CR>
	nnoremap <Leader> :qa!<CR>
	"   Get a Leader mapping for saves
	nmap <Leader>s :w<CR>
	command! -bang W :w!
	]]

	--   File change management
	vim.opt.undofile = true
	use 'djoshea/vim-autoread'

	--   Buffer display above
	vim.g.wintabs_ui_show_vimtab_name = 2
	vim.cmd [[
	map <C-PageUp> :WintabsPrevious<CR>
	map <C-PageDown> :WintabsNext<CR>
	map <Leader>w :WintabsClose<CR>
	map <Leader>W :WintabsOnly<CR>:WintabsClose<CR>
	]]
	use 'zefei/vim-wintabs'

	--   Temporarily narrow to a single window
	use 'vim-scripts/ZoomWin'

	--   Resize windows easily via keyboard
	use 'simeji/winresizer'
	vim.g.winresizer_start_key = '<Leader><CR>'

	-- vim.cmd([[
	-- let bufferline = get(g:, 'bufferline', {})
	-- let bufferline.icons = 'numbers'
	-- let bufferline.icon_separator_active = '|'
	-- let bufferline.icon_separator_inactive = '|'
	-- let bufferline.icon_close_tab = 'x'
	-- let bufferline.icon_close_tab_modified = '*'
	--
	-- nnoremap <silent> <C-PageUp> :BufferPrevious<CR>
	-- nnoremap <silent> <C-PageDown> :BufferNext<CR>
	-- ]])
	-- use 'romgrk/barbar.nvim'

	-- TODO: Investigate `*CurrentFile` breakage here.
	use {
		'ErichDonGubler/vim-file-browser-integration',
		config = function()
			vim.cmd [[
			nnoremap <Leader>e :SelectCurrentFile<CR>
			nnoremap <Leader>x :OpenCurrentFile<CR>
			nnoremap <Leader>E :OpenCWD<CR>
			]]
		end,
	}

	-- Project flows

	--   GUI-specific configuration
	--
	--   Just gimme a rendering window, we'll do the fancy stuff ourselves!

	vim.cmd [[
	set guioptions-=M " Don't source the menu bar script
	set guioptions-=m " Don't show the menu bar, either. ;)
	set guioptions-=T " Don't show the toolbar
	set guioptions-=e " Don't show GUI tabs
	set guioptions-=r " Don't show right-hand scrollbar
	set guioptions-=L " Don't show left-hand scrollbar
	]]
	vim.opt.mousemodel = '' -- Don't use right-click menu

	--   Session management

	use {
		'ctrlpvim/ctrlp.vim',
		setup = function()
			vim.g.ctrlp_bufname_mod = ':t'
			vim.g.ctrlp_bufpath_mod = ':~:.:h'
			vim.g.ctrlp_by_filename = 1
			vim.g.ctrlp_extensions = { 'buffertag', 'line', 'rtscript' }
			vim.g.ctrlp_follow_symlinks = 1
			if vim.fn.executable('fd') then
				vim.g.ctrlp_use_caching = 0
				vim.g.ctrlp_user_command = 'fd "" %s --follow --type file'
			elseif vim.fn.executable('rg') then
				vim.g.ctrlp_use_caching = 0
				vim.g.ctrlp_user_command = 'rg "" %s --follow --files'
			end
			vim.g.ctrlp_map = '<Leader>p'
		end,
		config = function()
			vim.cmd [[
			map <Leader>p :CtrlP<CR>
			map <Leader>o :CtrlPMRU<CR>
			map <Leader>O :CtrlPBuffer<CR>
			map <Leader>r :CtrlPBufTag %<CR>
			map <Leader>R :CtrlPTag<CR>
			map <Leader>/ :CtrlPLine<CR>
			]]
		end,
	}
	-- use {
	-- 	'FelikZ/ctrlp-py-matcher',
	-- 	requires = 'ctrlpvim/ctrlp.vim'
	-- }
	-- vim.g.ctrlp_match_func = { match = 'pymatcher#PyMatch' }

	use {
		'ivalkeen/vim-ctrlp-tjump',
		requires = 'ctrlpvim/ctrlp.vim',
		setup = function()
			vim.g.ctrlp_tjump_only_silent = 1
		end,
		config = function()
			vim.cmd [[
			nnoremap <c-]> :CtrlPtjump<CR>
			vnoremap <c-]> :CtrlPtjumpVisual<CR>
			]]
		end,
	}

	vim.opt.sessionoptions:remove('options')
	vim.opt.sessionoptions:append('tabpages')
	vim.opt.sessionoptions:append('globals')

	use 'tpope/vim-obsession'
	use {
		'dhruvasagar/vim-prosession',
		requires = 'tpope/vim-obsession',
	}
	-- TODO: fuzzy session selection?


	--   These make using the command-line interface much easier.
	use 'EinfachToll/DidYouMean'
	use 'pbrisbin/vim-mkdir' -- make parent directories automatically
	use 'kopischke/vim-fetch' -- handle `file:<line>:<col>`

	--   Project configuration

	use {
		'embear/vim-localvimrc',
		setup = function()
			vim.g.localvimrc_persistent = 1
			vim.g.localvimrc_sandbox = false
		end,
	}

	--   File management

	-- Get some nice command aliases for basic file management
	use 'tpope/vim-eunuch'

	use {
		'Xuyuanp/nerdtree-git-plugin',
		setup = function()
			vim.g.NERDTreeIndicatorMapCustom = {
				Clean     = "✓",
				Deleted   = "✖",
				Dirty     = "*",
				Ignored   = "Ø",
				Modified  = "*",
				Renamed   = "➜",
				Staged    = "+",
				Unknown   = "?",
				Unmerged  = "=",
				Untracked = "_",
			}
		end,
	}

	-- Color scheme and highlighting configuration

	use {
		'ErichDonGubler/vim-sublime-monokai',
		setup = function()
			vim.g.sublimemonokai_term_italic = true
		end,
		config = function()
			vim.cmd 'colorscheme sublimemonokai'

			-- TODO: Get this moved to a better place
			vim.fn['g:SublimeMonokaiHighlight']('BreezeHlElement', { format = 'reverse' })

			-- TODO: What the crap, man!
			vim.fn['g:SublimeMonokaiHighlight']('Todo', { fg = vim.g.sublimemonokai_orange, format = 'bold,italic' })

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
			hi! link goExtraType        Special
			hi! link goTypeConstructor  SublimeType
			hi! link jsRegexpCharClass  Special
			hi! link jsRegexpBackRef    SpecialChar
			hi! link jsRegexpMod        SpecialChar
			hi! link jsRegexpOr         SpecialChar
			" It's nice to have the builtins highlighted, but they can cause some conflicts
			hi! link pythonBuiltInObj   Constant
			hi! link pythonBuiltInType  Constant
			hi! link rustAttribute      SublimeDocumentation
			hi! link rustDerive         SublimeDocumentation
			hi! link rustDeriveTrait    SublimeDocumentation
			hi! link rustLifetime       Special
			hi! link xmlProcessingDelim Comment
			hi! link zshOption          Special
			hi! link zshTypes           SublimeType
			]])
		end
	}

	-- Status line

	vim.opt.laststatus = 2
	vim.opt.showmode = false
	-- TODO: Disable lightline `tab` functionality?
	-- use {
	-- 	'itchyny/lightline.vim',
	-- 	config = function()
	-- 		vim.g.lightline = {
	-- 			enable = { tabline = false }
	-- 		}
	-- 	end
	-- }
	use {
		'hoob3rt/lualine.nvim',
		config = function()
			require('lualine').setup({
				theme = 'powerline',
			})
		end
	}

	-- Navigation

	--   Basic keyboard navigation bindings

	vim.cmd [[
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
	]]

	use 'dominikduda/vim_current_word'
	vim.g['vim_current_word#highlight_only_in_focused_window'] = 1
	vim.cmd [[hi link CurrentWord Underlined]]

	--   Mouse scrolling

	vim.cmd [[
	noremap <C-ScrollWheelDown> 3zl
	noremap <C-ScrollWheelUp> 3zh
	]]

	--   Text search

	vim.opt.hlsearch = true
	vim.opt.ignorecase = true
	vim.opt.incsearch = true
	vim.opt.smartcase = true
	vim.cmd [[hi! link Search Underlined]]

	use 'haya14busa/is.vim'

	use {
		'haya14busa/vim-asterisk',
		config = function()
			vim.cmd [[
			map *  <Plug>(asterisk-z*)<Plug>(is-nohl-1)
			map g* <Plug>(asterisk-gz*)<Plug>(is-nohl-1)
			map #  <Plug>(asterisk-z#)<Plug>(is-nohl-1)
			map g# <Plug>(asterisk-gz#)<Plug>(is-nohl-1)
			]]
		end,
	}

	use {
		'osyo-manga/vim-anzu',
		config = function()
			vim.cmd [[
			map n <Plug>(is-nohl)<Plug>(anzu-n-with-echo)
			map N <Plug>(is-nohl)<Plug>(anzu-N-with-echo)
			]]
		end,
	}

	use {
		'dyng/ctrlsf.vim',
		setup = function()
			vim.g.ctrlsf_auto_focus = { at = 'start' }
			vim.api.nvim_set_keymap('n', '<Leader>f', ':CtrlSFToggle<CR>', { noremap = true })
			vim.api.nvim_set_keymap('n', '<Leader>F', ':CtrlSF<Space>', { noremap = true })
			vim.g.ctrlsf_default_view_mode = 'compact'
			vim.g.ctrlsf_indent = 2
			vim.g.ctrlsf_populate_qflist = 1
			vim.g.ctrlsf_search_mode = 'async'
		end,
	}

	--   TODO: Tag search

	-- Buffer manipulation

	use 'tpope/vim-repeat'

	use 'christoomey/vim-sort-motion'

	use 'tpope/vim-unimpaired' -- sort of a kitchen sink plugin

	--   Add some common line-ending shortcuts
	function _G.append_chars(sequence)
		local line = vim.fn.line('.')
		local col = vim.fn.col('.')
		vim.cmd('exec \'normal! A' .. sequence .. '\'')
		vim.fn.cursor(line, col)
	end
	function map_device_character_append(sequence, name)
		vim.cmd('command! -nargs=0 Append' .. name .. ' call v:lua.append_chars(\'' .. sequence .. '\')')
		vim.cmd('nnoremap <Leader>' .. sequence .. ' :Append' .. name .. '<CR>')
	end
	map_device_character_append(';', 'Semicolon')
	map_device_character_append('.', 'Period')
	map_device_character_append(',', 'Comma')

	--   Yanking

	use {
		'machakann/vim-highlightedyank',
		setup = function()
			vim.g.highlightedyank_highlight_duration = 50
		end,
	}

	--   Search-and-replace

	vim.cmd([[
	map <Leader>h :%s/
	vmap <Leader>h :s/
	]])

	use 'mg979/vim-visual-multi'

	--   Indentation/whitespace

	-- TODO: Does this actually work?
	if vim.g.erichdongubler_initted_indent_opts == nil then
		vim.opt.autoindent = true
		vim.opt.backspace = 'indent,eol,start'
		vim.opt.shiftwidth = 4
		vim.opt.softtabstop = 4
		vim.opt.tabstop = 4

		vim.g.erichdongubler_initted_indent_opts = true
	end

	use {
		'ciaranm/detectindent',
		config = function()
			vim.cmd([[
			augroup DetectIndent
			au!
			au BufReadPost * :DetectIndent
			augroup END
			]])
		end,
	}

	use 'rhlobo/vim-super-retab'

	use {
		'junegunn/vim-easy-align',
		config = function()
			vim.cmd [[
			xmap ga <Plug>(EasyAlign)
			nmap ga <Plug>(EasyAlign)
			]]
		end,
	}

	--   Line breaks

	vim.opt.display:append({ 'lastline' })
	vim.opt.formatoptions:remove({
		't' -- Disable hard breaks at textwidth boundary
	})
	-- Show soft-wrapped text with extra indent of 2 spaces
	vim.opt.breakindentopt = 'shift:2'
	vim.opt.showbreak = '->'

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
	vim.cmd [[
	command! -nargs=0 DisableWordWrap call v:lua.set_word_wrap(0)
	command! -nargs=0 EnableWordWrap call v:lua.set_word_wrap(1)
	]]
	vim.api.nvim_set_keymap('n', '<Leader><Tab>', ':call v:lua.toggle_word_wrap(v:false)<CR>', { noremap = true })
	vim.api.nvim_set_keymap('n', '<Leader><S-Tab>', ':call v:lua.toggle_word_wrap(v:true)<CR>', { noremap = true })

	--   Brackets

	use {
		'cohama/lexima.vim',
		setup = function()
			vim.g.lexima_no_default_rules = true
		end,
		config = function()
			vim.fn['lexima#set_default_rules']()
		end
	}

	use {
		'andymass/vim-matchup',
		after = { 'vim-sublime-monokai', 'vim-sandwich' },
		setup = function()
			vim.g.matchup_matchparen_deferred = 1
			vim.g.matchup_matchparen_hi_surround_always = 1
			vim.g.matchup_override_vimtex = 1
			vim.g.matchup_surround_enabled = 1
		end,
		config = function()
			vim.cmd [[
			hi! clear MatchParenCur
			hi! clear MatchWordCur
			]]
			vim.fn['g:SublimeMonokaiHighlight']('MatchParen', { format = 'reverse' })
			vim.fn['g:SublimeMonokaiHighlight']('MatchTag', { format = 'reverse' })
			vim.fn['g:SublimeMonokaiHighlight']('MatchWord', { format = 'reverse' })
		end
	}

	use {
		'machakann/vim-sandwich',
		config = function()
			-- Not sure why this needs to be in vimscript. :scratch-head:
			vim.cmd 'let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)'
			local recipes = vim.g['sandwich#recipes'] 
			print(recipes)

			local vim_surround_ish_recipes = {
				{buns = {'{ ', ' }'}, nesting = 1, match_syntax = 1, kind = {'add', 'replace'}, action = {'add'}, input = {'{'}},
				{buns = {'[ ', ' ]'}, nesting = 1, match_syntax = 1, kind = {'add', 'replace'}, action = {'add'}, input = {'['}},
				{buns = {'( ', ' )'}, nesting = 1, match_syntax = 1, kind = {'add', 'replace'}, action = {'add'}, input = {'('}},
				{buns = {'{\\s*', '\\s*}'}, nesting = 1, regex = 1, match_syntax = 1, kind = {'delete', 'replace', 'textobj'}, action = {'delete'}, input = {'{'}},
				{buns = {'\\[\\s*', '\\s*\\]'}, nesting = 1, regex = 1, match_syntax = 1, kind = {'delete', 'replace', 'textobj'}, action = {'delete'}, input = {'['}},
				{buns = {'(\\s*', '\\s*)'}, nesting = 1, regex = 1, match_syntax = 1, kind = {'delete', 'replace', 'textobj'}, action = {'delete'}, input = {'('}},
			}
			for _, v in pairs(vim_surround_ish_recipes) do
				table.insert(recipes, v)
			end

			vim.g['sandwich#recipes'] = recipes 
		end
	}

	--   Casing

	use {
		'arthurxavierx/vim-caser',
		setup = function()
			vim.g.caser_prefix = 'gS'
		end,
	}

	--   Commentary

	-- -- TODO: Is this better than `vim-commentary`?
	use {
		'b3nj5m1n/kommentary',
		config = function()
			require('kommentary.config').configure_language("default", {
				prefer_single_line_comments = true,
				use_consistent_indentation = true,
			})
		end
	}
	-- use 'tpope/vim-commentary'

	--   Text object/smart content manipulation

	use {
		'FooSoft/vim-argwrap',
		config = function()
			vim.cmd [[
			nnoremap <silent> <leader>] :ArgWrap<CR>
			]]
		end,
	}
	use 'peterrincker/vim-argumentative'

	use 'tommcdo/vim-ninja-feet'
	use 'wellle/targets.vim'
	use 'glts/vim-textobj-comment'
	use 'kana/vim-textobj-entire'
	use 'kana/vim-textobj-function'
	use 'kana/vim-textobj-indent'
	use 'kana/vim-textobj-line'
	use 'kana/vim-textobj-user'
	use 'thalesmello/vim-textobj-methodcall'

	--     URLs

	use 'mattn/vim-textobj-url'
	use {
		'tyru/open-browser.vim',
		config = function()
			vim.cmd [[
			map <Leader>u <Plug>(openbrowser-smart-search)
			]]
		end,
	}

	-- CVS integration

	use 'knsh14/vim-github-link'

	-- -- TODO: Investigate!
	-- use {
	-- 	'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
	-- 	config = function()
	-- 		require('gitsigns').setup()
	-- 	end
	-- }
	use {
		'airblade/vim-gitgutter',
		setup = function()
			vim.g.gitgutter_map_keys = false
			if vim.fn.executable('rg') then
				vim.g.gitgutter_grep = 'rg --follow'
			end
		end,
		config = function()
			vim.cmd [[
			nmap [h <Plug>(GitGutterPrevHunk)
			nmap ]h <Plug>(GitGutterNextHunk)
			nmap ghp <Plug>(GitGutterPreviewHunk)
			nmap ghs <Plug>(GitGutterStageHunk)
			nmap ghu <Plug>(GitGutterUndoHunk)
			omap ah <Plug>(GitGutterTextObjectOuterPending)
			omap ih <Plug>(GitGutterTextObjectInnerPending)
			xmap ah <Plug>(GitGutterTextObjectOuterVisual)
			xmap ih <Plug>(GitGutterTextObjectInnerVisual)
			]]
		end,
	}

	-- Time tracking via Wakatime
	use 'wakatime/vim-wakatime'

	-- fix `tmux` focus
	use 'tmux-plugins/vim-tmux-focus-events'

	-- Advanced IDE-like experience

	--   Tags: the poor man's Intellisense database

	vim.opt.tags = '.tags'
	vim.cmd [[
	augroup tags
		au!
		au BufNewFile,BufRead .tags setlocal filetype=tags
	augroup END
	]]
	use {
		'ludovicchabant/vim-gutentags',
		setup = function() 
			if vim.fn.executable('fd') then
				vim.g.gutentags_file_list_command = 'fd --follow --type file'
			elseif vim.fn.executable('rg') then
				vim.g.gutentags_file_list_command = 'rg --follow --files'
			else
				vim.g.gutentags_resolve_symlinks = 1
			end

			vim.g.gutentags_cache_dir = vim.fn.stdpath('cache') .. '/gutentags'
			if not vim.fn.isdirectory(vim.g.gutentags_cache_dir) then
				vim.fn.mkdir(vim.g.gutentags_cache_dir)
			end

			vim.g.gutentags_ctags_tagfile = '.tags'
		end,
	}

	use {
		'majutsushi/tagbar',
		config = function() 
			vim.cmd [[nmap <Leader>t :TagbarToggle<CR>]]
		end,
	}

	--   Snippets

	use {
		'SirVer/ultisnips',
		disable = vim.fn.has('python3') == 0,
		requires = 'honza/vim-snippets',
		setup = function()
			vim.g.UltiSnipsExpandTrigger = '<Tab>'
			vim.g.UltiSnipsJumpForwardTrigger = '<Tab>'
			vim.g.UltiSnipsJumpBackwardTrigger = '<S-Tab>'
		end,
	}
	-- -- TODO: Determine if this is better than Ultisnips
	-- use 'hrsh7th/vim-vsnip'

	--   LSP

	use {
		'neovim/nvim-lspconfig',
		config = function()
			vim.cmd [[
			map <Leader>n :lua vim.lsp.diagnostic.goto_next()<cr>
			map <Leader>N :lua vim.lsp.diagnostic.goto_prev()<cr>
			]]
			-- TODO: Configure highlighting to work nicely
		end,
	}
	use {
		'nvim-lua/lsp_extensions.nvim',
		requires = 'neovim/nvim-lspconfig',
		config = function()
			vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
				vim.lsp.diagnostic.on_publish_diagnostics, {
					virtual_text = true,
					signs = true,
					update_in_insert = true,
				}
			)
		end,
	}

	--   Completion

	vim.opt.completeopt = 'menuone,noinsert,noselect'
	-- vim.opt.shortmess:append({ 'c' })

	use {
		'hrsh7th/nvim-compe',
		after = 'lexima.vim',
		config = function()
			require('compe').setup({
				enabled = true,
				source = {
					buffer = true,
					calc = true,
					-- nvim_lua = true,
					nvim_lsp = true,
					path = true,
					tag = true,
				},
			})
			-- NOTE: Order is important. You can't lazy loading lexima.vim.
			vim.cmd [[
			inoremap <silent><expr> <C-Space> compe#complete()
			inoremap <silent><expr> <CR>      compe#confirm(lexima#expand('<LT>CR>', 'i'))
			inoremap <silent><expr> <C-e>     compe#close('<C-e>')
			inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
			inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
			]]
		end
	}

	--   Auto-formatting

	use {
		'ntpeters/vim-better-whitespace',
		setup = function()
			vim.g.better_whitespace_operator = '_s'
			vim.g.show_spaces_that_precede_tabs = 0
			vim.g.strip_whitespace_confirm = 0
			vim.cmd [[
			hi! link ExtraWhitespace Error
			]]
		end,
	}

	use {
		'Chiel92/vim-autoformat',
		disable = vim.fn.has('python3') == 0,
		config = function()
			vim.cmd [[
			augroup WhitespaceAutoformat
				au!
				au BufWrite * :Autoformat
			augroup END
			]]

			function _G.disable_trailing_whitespace_stripping()
				vim.b.autoformat_remove_trailing_spaces = 0
			end
			function _G.disable_indentation_fixing()
				vim.b.autoformat_autoindent = 0
			end
			function _G.disable_retab()
				vim.b.autoformat_retab = 0
			end
			vim.cmd[[
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
			]]
		end,
	}

	--   Language-specific integration
	
	use 'vitalk/vim-shebang'

	use {
		'rust-lang/rust.vim',
		requires = {
			'nvim-compe',
			'nvim-lspconfig',
			'vim-sandwich',
			'vim-shebang',
		},
		config = function()
			local recipes = vim.g['sandwich#recipes']

			-- TODO: These are broken. :(
			local add_rust_sandwich_binding = function(input, start, end_)
				table.insert(recipes, {
					buns = { start, end_ },
					filetype = { 'rust' },
					input = { input },
					nesting = 1,
					indent = 1
				})
			end
			add_rust_sandwich_binding('A', 'Arc<', '>')
			add_rust_sandwich_binding('B', 'Box<', '>')
			add_rust_sandwich_binding('O', 'Option<', '>')
			add_rust_sandwich_binding('P', 'PhantomData<', '>')
			add_rust_sandwich_binding('R', 'Result<', '>')
			add_rust_sandwich_binding('V', 'Vec<', '>')
			add_rust_sandwich_binding('a', 'Arc::new(', ')')
			add_rust_sandwich_binding('b', 'Box::new(', ')')
			add_rust_sandwich_binding('d', 'dbg!(', ')')
			add_rust_sandwich_binding('o', 'Some(', ')')
			add_rust_sandwich_binding('r', 'Ok(', ')')
			add_rust_sandwich_binding('u', 'unsafe { ', ' }')
			add_rust_sandwich_binding('v', 'vec![', ']')

			vim.g['sandwich#recipes'] = recipes 

			-- TODO
			function _G.configure_rust()
				vim.cmd [[
				nnoremap <LocalLeader>b :Cargo build<CR>
				nnoremap <LocalLeader>B :Cargo build --release<CR>
				nnoremap <LocalLeader>c :Cargo check<CR>
				nnoremap <LocalLeader>d :Cargo doc<CR>
				nnoremap <LocalLeader>D :Cargo doc --open<CR>
				nnoremap <LocalLeader>F :Cargo fmt<CR>
				nnoremap <LocalLeader>f :RustFmt<CR>
				nnoremap <LocalLeader>p :RustPlay<CR>
				nnoremap <LocalLeader>r :Cargo run<CR>
				nnoremap <LocalLeader>R :Cargo run --release<CR>
				nnoremap <LocalLeader>s :Cargo script "%"<CR>
				nnoremap <LocalLeader>t :RustTest<CR>
				nnoremap <LocalLeader>T :Cargo test<CR>
				]]
			end
			vim.cmd [[
			augroup rust
				au!
				au FileType rust call v:lua.configure_rust()
			augroup end
			]]

			-- -- TODO: Not working yet. :(
			-- vim.cmd [[
			-- AddShebangPattern! rust ^#!.*/bin/env\s\+run-cargo-(script|eval)\>
			-- AddShebangPattern! rust ^#!.*/bin/run-cargo-(script|eval)\>
			-- ]]

			require('lspconfig').rust_analyzer.setup({})
		end
	}
end)

