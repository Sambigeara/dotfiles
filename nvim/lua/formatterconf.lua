-- https://github.com/mhartington/formatter.nvim#configure
-- Utilities for creating configurations
-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
local util = require("formatter.util")

require("formatter").setup({
	filetype = {
		lua = { require("formatter.filetypes.lua").stylua },

		typescriptreact = { require("formatter.filetypes.typescript").prettier },
		typescript = { require("formatter.filetypes.typescript").prettier },
		javascriptreact = { require("formatter.filetypes.typescript").prettier },
		javascript = { require("formatter.filetypes.typescript").prettier },
		-- yaml = { require("formatter.filetypes.yaml").yamlfmt },
		css = { require("formatter.filetypes.css").prettier },
		fish = { require("formatter.filetypes.fish").fishindent },
		python = { require("formatter.filetypes.python").black },
		go = { require("formatter.filetypes.go").goimports },
		--sql = { require("formatter.filetypes.sql").pgformat },

		-- Use the special "*" filetype for defining formatter configurations on
		-- any filetype
		["*"] = {
			-- "formatter.filetypes.any" defines default configurations for any
			-- filetype
			require("formatter.filetypes.any").remove_trailing_whitespace,
		},
	},
})

-- Handle `.norg`
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.norg",
	nested = false,
	once = false,
	callback = function()
		local save_cursor = vim.fn.getcurpos()

		-- -- ignore text within code blocks
		-- -- (the issue seen previously might just be because of lack of treesitter support for the given language?)
		-- local inside_code_block = false
		-- local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		--
		-- for i, line in ipairs(lines) do
		-- 	if string.match(line, "@code") then
		-- 		inside_code_block = true
		-- 	elseif string.match(line, "@end") then
		-- 		inside_code_block = false
		-- 	end
		--
		-- 	if not inside_code_block then
		-- 		vim.api.nvim_win_set_cursor(0, { i, 0 })
		-- 		vim.cmd("normal! ==")
		-- 	end
		-- end

		vim.cmd("normal! gg=G")
		vim.fn.setpos(".", save_cursor)
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	command = "FormatWrite",
	group = vim.api.nvim_create_augroup("FormatAutogroup", { clear = true }),
})
