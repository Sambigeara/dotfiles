local lspconfig = require("lspconfig")
local util = require("lspconfig/util")

local servers = {
	gopls = {
		-- cmd = { "gopls", "serve" },
		-- filetypes = { "go", "gomod" },
		-- root_dir = util.root_pattern("go.work", "go.mod", ".git"),
		settings = {
			gopls = {
				staticcheck = true,
				gofumpt = true,
				buildFlags = { "-tags=tests,integration,e2e,toolsx" },
				env = { GOFLAGS = "-tags=tests,integration,e2e,toolsx" },
			},
		},
	},
	lua_ls = {
		on_init = function(client)
			local path = client.workspace_folders[1].name
			if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
				client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
					Lua = {
						runtime = {
							-- Tell the language server which version of Lua you're using
							-- (most likely LuaJIT in the case of Neovim)
							version = "LuaJIT",
						},
						-- Make the server aware of Neovim runtime files
						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME,
								-- "${3rd}/luv/library"
								-- "${3rd}/busted/library",
							},
							-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
							-- library = vim.api.nvim_get_runtime_file("", true)
						},
						diagnostics = { "vim" },
					},
				})

				client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
			end
			return true
		end,
	},
	-- eslint = {
	-- 	on_attach = function(client, bufnr)
	-- 		vim.api.nvim_create_autocmd("BufWritePre", {
	-- 			buffer = bufnr,
	-- 			command = "EslintFixAll",
	-- 		})
	-- 	end,
	-- },
	tsserver = {},
	clangd = {
		filetypes = { "c", "cpp", "cc", "mpp", "ixx" },
	},
	pyright = {},
	-- pylsp = {},
	rust_analyzer = {},
	cssls = {},
	bufls = {},
	yamlls = {},
	efm = {
		root_dir = require("lspconfig").util.root_pattern({ ".git/", "." }),
		settings = {
			rootMarkers = { ".git/" },
			languages = {
				sh = {
					{
						lintCommand = "shellcheck -f gcc -x",
						lintSource = "shellcheck",
					},
				},
			},
		},
		filetypes = {
			"sh",
		},
		single_file_support = false, -- This is the important line for supporting older version of EFM
	},
}

-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

for server, config in pairs(servers) do
	config.capabilities = capabilities
	lspconfig[server].setup(config)
end

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		--vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
		-- vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	end,
})
