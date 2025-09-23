return {
	{
		"nvim-neorg/neorg",
		lazy = false,
		version = "*",
		config = function()
			require("neorg").setup {
				load = {
					["core.defaults"] = {},
					["core.concealer"] = {},
					["core.dirman"] = {
						config = {
							workspaces = {
								notes = "~/notes",
							},
							default_workspace = "notes",
						},
					},
					["core.integrations.treesitter"] = { -- TreeSitter integration
						config = {
							configure_parsers = true, -- Neorg will manage the norg parser
							install_parsers = true, -- Automatically install norg parser if missing
						},
					},
					["core.integrations.telescope"] = {}, -- Telescope integration
					["core.autocommands"] = {},
				},
			}
		end,
	},
}
