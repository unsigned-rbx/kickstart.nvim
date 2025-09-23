return {
	{
		"felipeagc/fleet-theme-nvim",
		config = function() end,
	},
	{ -- You can easily change to a different colorscheme.
		-- Change the name of the colorscheme plugin below, and then
		-- change the command in the config to whatever the name of that colorscheme is.
		--
		-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
		"folke/tokyonight.nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		init = function()
			-- Load the colorscheme here.
			-- Like many other themes, this one has different styles, and you could load
			-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
			-- vim.cmd.colorscheme "tokyonight-night"

			-- You can configure highlights by doing something like:
			vim.cmd.hi "Comment gui=none"
		end,
	},
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{
		"killitar/obscure.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"AlexvZyl/nordic.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1100,
		opts = {},
		config = function()
			vim.cmd.colorscheme "kanagawa-dragon"

			local function hi_luadoc()
				local yellow = "#DCA561" -- autumn yellow
				local blue = "#7E9CD8" -- dragon blue
				local green = "#98BB6C" -- spring green
				local white = "#DCD7BA" -- fuji white

				-- tags like @param, @return
				vim.api.nvim_set_hl(0, "@attribute.luadoc", { fg = yellow, bold = true })
				vim.api.nvim_set_hl(0, "@tag.luadoc", { fg = yellow, bold = true })

				-- parameter names
				vim.api.nvim_set_hl(0, "@field.luadoc", { fg = blue, italic = true })

				-- type names (if you add them: @param player Player)
				vim.api.nvim_set_hl(0, "@type.luadoc", { fg = green, bold = true })

				-- descriptions
				vim.api.nvim_set_hl(0, "@comment.luadoc", { fg = white })
			end

			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "kanagawa*",
				callback = hi_luadoc,
			})

			hi_luadoc()
		end,
	},
}
