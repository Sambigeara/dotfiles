vim.opt.tabstop = 4 -- tab width is 4 spaces
vim.opt.shiftwidth = 4 -- indent also with 4 spaces
vim.opt.expandtab = true -- expand tabs to spaces
vim.opt.smarttab = true -- auto tab to appropriate location

vim.opt.clipboard = "unnamed"

-- vim.opt.t_Co = 256
-- vim.opt.termguicolors = true
vim.opt.background = "light"

vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("$HOME/.vim/undo")
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000
vim.opt.nu = true

-- When editing a file, always jump to the last known cursor position.
-- Don't do it when the position is invalid or when inside an event handler
-- (happens when dropping a file on gvim).
-- Also don't do it when the mark is in the first line, that is the default
-- position when opening a file.
vim.cmd([[
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
]])

-- TODO make this more lua native??
vim.api.nvim_exec(
	[[
  augroup MyAutoCmdGroup
    autocmd!
    autocmd Filetype javascript setlocal tabstop=2 shiftwidth=2 softtabstop=2
    autocmd Filetype typescript setlocal tabstop=2 shiftwidth=2 softtabstop=2
    autocmd Filetype typescriptreact setlocal tabstop=2 shiftwidth=2 softtabstop=2
    autocmd Filetype html setlocal tabstop=2 shiftwidth=2 softtabstop=2
    autocmd Filetype css setlocal tabstop=2 shiftwidth=2 softtabstop=2
    autocmd BufRead,BufNewFile *.vue set filetype=vue
    autocmd Filetype vue setlocal tabstop=2 shiftwidth=2 softtabstop=2
    autocmd BufRead,BufNewFile *yaml.gotmpl set filetype=yaml
    autocmd BufRead,BufNewFile *.proto set filetype=proto
    autocmd Filetype proto setlocal tabstop=2 shiftwidth=2 softtabstop=2
  augroup END
]],
	false
)

-- close quickfix menu after selecting choice
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qf" },
	command = [[nnoremap <buffer> <CR> <CR>:cclose<CR>]],
})
