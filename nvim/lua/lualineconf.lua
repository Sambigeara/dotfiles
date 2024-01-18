return {
	options = {
		-- theme = "tokyonight",
		theme = require("colorconf"),
	},
	sections = {
		-- lualine_a is the first section from the left, b = second, etc
		lualine_a = { "mode" },
		lualine_b = {
			{
				"filename",
				path = 1,
			},
		},
		lualine_c = {},
	},
}
