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
}
