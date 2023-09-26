return {
	"nvim-treesitter/nvim-treesitter",
	-- Install lua treesitter grammar for neorg
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = { "python", "go", "lua", "javascript", "typescript", "html", "tsx", "norg" },
			sync_install = false,
			highlight = {
				enable = true,
				disable = function(lang, bufnr) -- Disable in large C++ buffers
					return vim.api.nvim_buf_line_count(bufnr) > 50000
				end,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = ",", -- maps in normal mode to init the node/scope selection with space
					node_incremental = ",", -- increment to the upper named parent
					node_decremental = "<bs>", -- decrement to the previous node
					scope_incremental = "<tab>", -- increment to the upper scope (as defined in locals.scm)
				},
			},
		})

		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
		-- vim.opt.foldenable = false
	end,
}
