return {
	"nvim-neorg/neorg",
	build = ":Neorg sync-parsers",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		-- "nvim-treesitter/nvim-treesitter-textobjects",
		"hrsh7th/nvim-cmp",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("neorg").setup({
			load = {
				["core.keybinds"] = {
					config = {
						default_keybinds = true,
						neorg_leader = "<leader><leader>",

						hook = function(keybinds)
							keybinds.map(
								"norg",
								"n",
								"<leader>l",
								"<cmd>Neorg keybind norg core.looking-glass.magnify-code-block<cr>"
							)
						end,
					},
				},
				["core.defaults"] = {}, -- Loads default behaviour
				["core.concealer"] = {}, -- Adds pretty icons to your documents
				["core.dirman"] = { -- Manages Neorg workspaces
					config = {
						workspaces = {
							notes = "~/notes",
						},
					},
				},
				-- ["core.ui.calendar"] = {},
				-- ["core.tempus"] = {}, -- At the very least, allows me to trigger insert-date
				["core.esupports.indent"] = {
					config = {
						format_on_escape = true,
					},
				},
				["core.looking-glass"] = {},
				["core.integrations.nvim-cmp"] = {},
				["core.completion"] = {
					config = {
						engine = "nvim-cmp",
						name = "[Neorg]",
					},
				},
			},
		})
	end,
}
