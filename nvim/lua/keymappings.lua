vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Map U to redo
vim.api.nvim_set_keymap("n", "U", "<c-r>", { noremap = true, silent = true })

-- Open long diagnostics in float
vim.api.nvim_set_keymap(
	"n",
	"<leader>dd",
	"<cmd>lua vim.diagnostic.open_float()<CR>",
	{ noremap = true, silent = true }
)
