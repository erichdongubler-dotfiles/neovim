vim.o.shell = "nu"
-- NOTE: Windows specifies `/s /c`, so we can't use the *nixy `-c` default for `shellcmdflag`.
vim.o.shellcmdflag = "-c"
vim.o.shellpipe = "o+e>|"
vim.o.shellredir = "o+e>"
vim.o.shellquote = ""
vim.o.shellxquote = ""

return {}
