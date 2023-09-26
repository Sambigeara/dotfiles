return {
	options = {
		-- theme = "tokyonight",
		theme = require("colorconf"),
	},
	sections = {
		-- lualine_a is the first section from the left, b = second, etc
		lualine_a = { "mode" },
		-- use lualine_b defaults
		lualine_c = {
			{
				"filename",
				path = 1,
			},
		},
	},
}
