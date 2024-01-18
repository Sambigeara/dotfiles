-- lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"neovim/nvim-lspconfig", -- Collection of configurations for built-in LSP client
		config = function()
			require("lsp")
			require("completion")
		end,
	},
	"hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
	"hrsh7th/cmp-nvim-lsp-signature-help", -- Suggest function parameters when typing!!!
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/nvim-cmp", -- Autocompletion plugin
	"saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
	"L3MON4D3/LuaSnip", -- Snippets plugin

	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- calling `setup` is optional for customization
			require("fzf-lua").setup({})

			vim.keymap.set("n", "<F3>", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
			-- vim.keymap.set("n", "<F5>", "<cmd>lua require('fzf-lua').buffers()<CR>", { silent = true })
			-- https://github.com/ibhagwan/fzf-lua/issues/814
			vim.keymap.set(
				"n",
				"<F5>",
				'<cmd>lua require(\'fzf-lua\').buffers({fzf_opts={["--delimiter"]="\' \'",["--with-nth"]="-1.."}})<CR>',
				{ silent = true }
			)
			vim.keymap.set("n", "<F6>", "<cmd>lua require('fzf-lua').lines()<CR>", { silent = true })
		end,
	},

	"christoomey/vim-tmux-navigator",

	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
				view = {
					width = 35,
				},
			})
			vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")
		end,
	},

	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
	"airblade/vim-gitgutter",
	{
		"numToStr/Comment.nvim",
		opts = {
			-- add any options here
		},
		lazy = false,
	},
	"tpope/vim-surround",
	"reedes/vim-pencil",
	{
		"ggandor/leap.nvim",
		config = function()
			require("leap").add_default_mappings()
		end,
	},

	{
		"NLKNguyen/papercolor-theme",
		-- config = function()
		-- 	require("colorconf")
		-- end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		-- config = function()
		-- 	require("colorconf")
		-- end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		-- config = function()
		-- 	require("colorconf")
		-- end,
		priority = 1000,
	},

	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	{
		"mhartington/formatter.nvim",
		config = function()
			require("formatterconf")
		end,
	},
	{ "mattn/vim-goimports" },
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup(require("lualineconf"))
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- WARNING: `markdown-preview` affects nvim startup time horrendously
	-- {
	-- 	"iamcco/markdown-preview.nvim",
	-- 	config = function()
	-- 		vim.fn["mkdp#util#install"]()
	-- 	end,
	-- },

	-- Show tab lines
	-- {
	-- 	"lukas-reineke/indent-blankline.nvim",
	-- 	main = "ibl",
	-- 	opts = {},
	-- 	config = function()
	-- 		require("ibl").setup()
	-- 	end,
	-- },

	require("treesitter"),
	require("neorgconf"),
})

require("colorconf")
