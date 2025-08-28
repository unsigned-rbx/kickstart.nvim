return {

	{
		"vhyrro/luarocks.nvim",
		config = true,
		priority = 1000,
	},
	{ "wakatime/vim-wakatime", lazy = false },
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{
		"nvim-neorg/neorg",
		--build = ":Neorg sync-parsers",
		--lazy = false,
		ft = "norg",
		cmd = "Neorg",
		lazy = true,
		dependencies = { { "nvim-lua/plenary.nvim" }, { "nvim-neorg/neorg-telescope" } },
		config = function()
			require("neorg").setup {
				load = {
					["core.defaults"] = {},
					["core.concealer"] = {},
					["core.summary"] = {},
					["core.integrations.telescope"] = {
						config = {
							insert_file_link = {
								-- Whether to show the title preview in telescope. Affects performance with a large
								-- number of files.
								show_title_preview = true,
							},
						},
					},
					["core.completion"] = {
						config = {
							-- engine = "nvim-cmp",
							engine = "blink",
						},
					},
					["core.integrations.blink"] = {},
				},
			}
		end,
	},
}
