-- Ripped straight from
-- <https://github.com/nushell/integrations/blob/6d2e8250cfb80dc83d9a75a785a31402917315f9/nvim/init.lua>.

vim.opt.shell = "nu"
-- NOTE: Windows specifies `/s /c`, so we can't use the *nixy `-c` default for `shellcmdflag`.
vim.opt.shellcmdflag = "--stdin --no-newline --commands"
vim.opt.shellpipe = '| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record'
vim.opt.shellquote = ""
vim.opt.shellredir = "out+err> %s"
vim.opt.shelltemp = false
vim.opt.shellxescape = ""
vim.opt.shellxquote = ""

return {}
