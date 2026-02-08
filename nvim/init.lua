local vim = vim

-- disable netrw (we use oil.nvim)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd("filetype plugin indent on")

vim.o.termguicolors = true
vim.o.background = "light"

vim.o.number = true
vim.o.showmatch = true
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.mouse = "a"

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.swapfile = false
vim.o.completeopt = "menuone,noinsert,noselect"

vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath("data") .. "/undo"

vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.autoindent = true
vim.o.wrap = true
vim.o.breakindent = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable built-in gr mappings to avoid timeout delay on custom gr keymaps
vim.keymap.del("n", "grn")
vim.keymap.del("n", "gra")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "gri")
vim.keymap.del("x", "gra")

-- Redo with U
vim.keymap.set("n", "U", "<Cmd>redo<CR>", { noremap = true, silent = true })

-- Fast saving/quitting
vim.keymap.set("n", "<Leader>w", ":write!<CR>")
vim.keymap.set("n", "<Leader>q", ":q!<CR>", { silent = true })

-- Quickfix navigation (avoiding <C-m> which is equivalent to <CR>)
vim.keymap.set("n", "<C-n>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-p>", "<cmd>cprev<CR>zz")

-- Remove search highlight
vim.keymap.set("n", "<Leader><space>", ":nohlsearch<CR>")

-- Move through softwrapped lines
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

-- Don't jump forward on * search
local function stay_star()
	local sview = vim.fn.winsaveview()
	local args = string.format("keepjumps keeppatterns execute %q", "sil normal! *")
	vim.api.nvim_command(args)
	vim.fn.winrestview(sview)
end
vim.keymap.set("n", "*", stay_star, { noremap = true, silent = true })

-- Don't replace clipboard when pasting over visual selection
vim.keymap.set("x", "p", '"_dP')

-- Keep visual selection when indenting/outdenting with grouped undo
do
	local indent_count = 0

	local function indent_with_undo_group(direction)
		if indent_count > 0 then
			pcall(vim.cmd.undojoin)
		end
		vim.cmd("normal! " .. direction)
		vim.cmd("normal! gv")
		indent_count = indent_count + 1

		vim.defer_fn(function()
			if vim.fn.mode() == "n" then
				indent_count = 0
			end
		end, 0)
	end

	vim.keymap.set("v", ">", function()
		indent_with_undo_group(">")
	end)
	vim.keymap.set("v", "<", function()
		indent_with_undo_group("<")
	end)
end

-- Yanking a line should act like D and C
vim.keymap.set("n", "Y", "y$")

-- Terminal: close with leader-q
vim.keymap.set("t", "<leader>q", "<C-\\><C-n>:q<cr>")

-- Open links in browser (cross-platform, requires Neovim 0.10+)
vim.keymap.set("n", "gx", function()
	vim.ui.open(vim.fn.expand("<cfile>"))
end)

-- Git keymaps
vim.keymap.set("n", "<leader>gd", "<CMD>Gvdiffsplit<CR>", { desc = "Show git diff" })
vim.keymap.set("n", "<leader>gb", "<CMD>Git blame<CR>")
vim.keymap.set("n", "<leader>go", "<CMD>GBrowse<CR>")
vim.keymap.set("x", "<leader>go", ":<C-u> GBrowse<CR>")

-- Gitsigns keymaps
vim.keymap.set("n", "<leader>gs", "<CMD>Gitsigns<CR>", { desc = "Open Gitsigns menu" })
vim.keymap.set("n", "]g", "<CMD>Gitsigns next_hunk<CR>", { desc = "Go to next change" })
vim.keymap.set("n", "[g", "<CMD>Gitsigns prev_hunk<CR>", { desc = "Go to previous change" })

-- Error diagnostic navigation
vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)

-- Auto-resize buffers on terminal resize
vim.api.nvim_command("autocmd VimResized * wincmd =")

-- Help windows open in vertical split to the right
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("help_window_right", {}),
	pattern = { "*.txt" },
	callback = function()
		if vim.o.filetype == "help" then
			vim.cmd.wincmd("L")
		end
	end,
})

-- Sync terminal CWD
local exitgroup = vim.api.nvim_create_augroup("setDir", { clear = true })
vim.api.nvim_create_autocmd("DirChanged", {
	group = exitgroup,
	pattern = { "*" },
	command = [[call chansend(v:stderr, printf("\033]7;file://%s\033\\", v:event.cwd))]],
})
vim.api.nvim_create_autocmd("VimLeave", {
	group = exitgroup,
	pattern = { "*" },
	command = [[call chansend(v:stderr, "\033]7;\033\\")]],
})

-- Prevent autochdir
vim.api.nvim_create_autocmd("VimEnter", {
	command = [[set noautochdir]],
})

-- Quickfix: always at the bottom, wrap text, close on selection
local qfgroup = vim.api.nvim_create_augroup("changeQuickfix", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	group = qfgroup,
	command = "wincmd J",
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	group = qfgroup,
	command = "setlocal wrap",
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { buffer = true, silent = true })
	end,
})

----------------
--- plugins ---
----------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require("lazy").setup({
	{
		"NMAC427/guess-indent.nvim",
		event = "BufReadPost",
		opts = {},
	},

	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme catppuccin]])
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		config = function()
			require("lualine").setup({
				options = { theme = "auto" },
				sections = {
					lualine_b = {
						{
							"filename",
							file_status = true,
							path = 1,
						},
					},
					lualine_c = {},
					lualine_x = {},
					lualine_y = {},
					lualine_z = { "location" },
				},
				inactive_sections = {},
			})
		end,
	},

	{
		"tpope/vim-fugitive",
		cmd = { "Git", "Gvdiffsplit" },
	},
	{
		"tpope/vim-rhubarb",
		dependencies = { "tpope/vim-fugitive" },
		cmd = { "GBrowse" },
	},

	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPost",
		opts = {
			signs = {
				add = { text = "+", show_count = false },
				change = { text = "~", show_count = false },
				delete = { text = "_", show_count = false },
				topdelete = { text = "‾", show_count = false },
				changedelete = { text = "~", show_count = false },
				untracked = { text = "┆", show_count = false },
			},
		},
	},

	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		lazy = false,
		config = function()
			require("oil").setup({
				skip_confirm_for_simple_edits = true,
			})
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		keys = {
			{
				"<F3>",
				function()
					require("telescope.builtin").find_files({ hidden = true })
				end,
				desc = "Find files",
			},
			{
				"<F4>",
				function()
					require("telescope").extensions.frecency.frecency({ workspace = "CWD" })
				end,
				desc = "Frecency files",
			},
			{
				"<F5>",
				function()
					require("telescope.builtin").buffers({ sort_mru = true, ignore_current_buffer = true })
				end,
				desc = "MRU buffers",
			},
			{
				"<F7>",
				function()
					require("telescope.builtin").live_grep({ default_text = "TODO\\(saml\\)" })
				end,
				desc = "Live grep TODO(saml)",
			},
			{
				"<leader>k",
				function()
					require("telescope.builtin").keymaps()
				end,
				desc = "Search keymaps",
			},
			{
				"<leader>d",
				function()
					require("telescope.builtin").diagnostics({ bufnr = 0 })
				end,
				desc = "Buffer diagnostics",
			},
			{
				"<leader>D",
				function()
					require("telescope.builtin").diagnostics()
				end,
				desc = "Search diagnostics",
			},
			{
				"<leader>/",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live grep",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
			{ "nvim-telescope/telescope-frecency.nvim", version = "*" },
		},
		config = function()
			require("telescope").setup({
				defaults = vim.tbl_extend("force", require("telescope.themes").get_ivy(), {
					file_ignore_patterns = { "npm", "frontend/node_modules/" },
				}),
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_ivy(),
					},
					frecency = {
						auto_validate = false,
						matcher = "fuzzy",
						ignore_patterns = { "*/.DS_Store", "*/node_modules" },
						path_display = { "filename_first" },
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			pcall(require("telescope").load_extension, "frecency")
		end,
	},

	{
		"ethanholz/nvim-lastplace",
		event = "BufReadPost",
		config = function()
			require("nvim-lastplace").setup({
				lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
				lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
				lastplace_open_folds = true,
			})
		end,
	},

	{
		"numToStr/Comment.nvim",
		keys = {
			{ "<leader>c", mode = { "n", "v" } },
			{ "<leader>b", mode = { "n", "v" } },
		},
		config = function()
			require("Comment").setup({
				opleader = {
					line = "<leader>c",
					block = "<leader>b",
				},
				toggler = {
					line = "<leader>c",
				},
			})
		end,
	},

	{
		"christoomey/vim-tmux-navigator",
		event = "VeryLazy",
	},

	{
		"tpope/vim-surround",
		event = "BufReadPost",
	},

	{
		"ggandor/leap.nvim",
		keys = { "s", "S" },
		config = function()
			require("leap").add_default_mappings()
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPost",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.cmp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("<leader>r", vim.lsp.buf.rename, "Rename")
					map("<leader>a", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
					map("gr", require("telescope.builtin").lsp_references, "Goto References")
					map("gi", require("telescope.builtin").lsp_implementations, "Goto Implementation")
					map("gd", vim.lsp.buf.definition, "Goto Definition")
					map("gD", vim.lsp.buf.declaration, "Goto Declaration")
					map("gy", vim.lsp.buf.type_definition, "Goto Type")
					map("<leader>s", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
					map("<leader>S", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")
					-- enabling this causes a delay with `gr`
					-- map("grt", require("telescope.builtin").lsp_type_definitions, "Goto Type Definition")

					---@param client vim.lsp.Client
					---@param method vim.lsp.protocol.Method
					---@param bufnr? integer
					---@return boolean
					local function client_supports_method(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if
						client
						and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
					then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "Toggle Inlay Hints")
					end
				end,
			})

			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						return diagnostic.message
					end,
				},
			})

			local capabilities = require("blink.cmp").get_lsp_capabilities()

			local servers = {
				clangd = {},
				gopls = {
					settings = {
						gopls = {
							["build.buildFlags"] = { "-tags=tests,integration,e2e,toolsx,oxi,tinygo.wasm" },
							usePlaceholders = true,
							gofumpt = true,
							analyses = {
								nilness = true,
								unusedparams = true,
								unusedwrite = true,
								useany = true,
							},
							codelenses = {
								gc_details = false,
								generate = true,
								regenerate_cgo = true,
								run_govulncheck = true,
								test = true,
								tidy = true,
								upgrade_dependency = true,
								vendor = true,
							},
							experimentalPostfixCompletions = true,
							completeUnimported = true,
							staticcheck = true,
							directoryFilters = { "-.git", "-node_modules" },
							semanticTokens = true,
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
				},
				pyright = {},
				buf = {},
				rust_analyzer = {},
				ts_ls = {},
				html = {},
				zls = {},
				yamlls = {},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							diagnostics = {
								globals = { "vim" },
								disable = { "missing-fields" },
							},
						},
					},
				},
			}

			-- Handle workspace/configuration requests from gopls
			local orig_handler = vim.lsp.handlers["workspace/configuration"]
			vim.lsp.handlers["workspace/configuration"] = function(err, result, ctx, config)
				if ctx.client_id then
					local client = vim.lsp.get_client_by_id(ctx.client_id)
					if client and client.name == "gopls" then
						local settings = {}
						for _, item in ipairs(result.items) do
							if item.section == "gopls" then
								table.insert(settings, servers.gopls.settings.gopls or vim.NIL)
							else
								table.insert(settings, vim.NIL)
							end
						end
						return settings
					end
				end
				if orig_handler then
					return orig_handler(err, result, ctx, config)
				end
				return {}
			end

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, { "stylua" })
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				ensure_installed = {},
				automatic_installation = false,
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	-- Autoformat
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				local high_timeout = { go = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				elseif high_timeout[vim.bo[bufnr].filetype] then
					return { timeout_ms = 5000, lsp_format = "fallback" }
				else
					return { timeout_ms = 500, lsp_format = "fallback" }
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "goimports", "gofmt" },
				python = { "isort", "black" },
				protobuf = { "buf" },
				html = { "html_beautify" },
				yaml = { "yamlfmt" },
			},
		},
	},

	-- Autocompletion
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		version = "1.*",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				opts = {},
			},
			"folke/lazydev.nvim",
		},
		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
			keymap = {
				preset = "enter",
				["<S-tab>"] = { "select_prev", "fallback" },
				["<tab>"] = { "select_next", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = { auto_show = true },
			},
			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = {
					lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
			signature = { enabled = true },
		},
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"bash",
					"c",
					"diff",
					"go",
					"gomod",
					"html",
					"lua",
					"luadoc",
					"markdown",
					"markdown_inline",
					"python",
					"query",
					"rust",
					"vim",
					"vimdoc",
					"yaml",
					"zig",
				},
				auto_install = false,
				indent = { enable = true, disable = { "ruby" } },
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "ruby" },
					disable = function(lang, buf)
						local max_filesize = 100 * 1024
						local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<M-o>",
						node_incremental = "<M-o>",
						node_decremental = "<M-i>",
						scope_incremental = "<tab>",
					},
				},
				textobjects = {
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
						},
					},
				},
			})
		end,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
			})
		end,
	},
})
