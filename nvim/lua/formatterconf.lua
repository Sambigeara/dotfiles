-- https://github.com/mhartington/formatter.nvim#configure
-- Utilities for creating configurations
-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup({
	filetype = {
		lua = { require("formatter.filetypes.lua").stylua },

		typescriptreact = { require("formatter.filetypes.typescript").prettier },
		typescript = { require("formatter.filetypes.typescript").prettier },
		javascriptreact = { require("formatter.filetypes.typescript").prettier },
		javascript = { require("formatter.filetypes.typescript").prettier },
		yaml = { require("formatter.filetypes.yaml").prettier },
		css = { require("formatter.filetypes.css").prettier },
		fish = { require("formatter.filetypes.fish").fishindent },
		python = { require("formatter.filetypes.python").black },
		--sql = { require("formatter.filetypes.sql").pgformat },
		--go = { require("formatter.filetypes.go").goimports },

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
		-- vim.cmd("normal! gg=G")
		local save_cursor = vim.fn.getcurpos()
		vim.cmd("normal! gg=G")
		vim.fn.setpos(".", save_cursor)
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	command = "FormatWrite",
	group = vim.api.nvim_create_augroup("FormatAutogroup", { clear = true }),
})