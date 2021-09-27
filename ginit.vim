set mousemodel=extend " Don't use right-click menu
set guioptions-=M " Don't source the menu bar script
set guioptions-=m " Don't show the menu bar, either. ;)
set guioptions-=T " Don't show the toolbar
set guioptions-=e " Don't show GUI tabs
GuiTabline 0
set guioptions-=r " Don't show right-hand scrollbar
set guioptions-=L " Don't show left-hand scrollbar
GuiPopupmenu 0

lua << EOF
local font = nil
if vim.fn.has("macunix") == 1 then
	font = 'Menlo Regular:h14'
elseif vim.fn.has("win32") == 1 then
	font = 'Consolas:h12'
	if vim.fn['fontdetect#hasFontFamily']('Source Code Pro') == 1 then
		font = 'Source Code Pro:h13'
	end
else
	font = 'Inconsolata NF:h11'
end
if font then
	vim.cmd('GuiFont! ' .. font)
else
	vim.cmd('echoe \'Uh oh, no font was specified! Falling back to default.\'')
end
EOF
