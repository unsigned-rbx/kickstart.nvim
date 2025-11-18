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
			require("kanagawa").setup {
				theme = "dragon",
				background = { dark = "dragon" },
			}
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

			local function hi_blink()
				local colors = require("kanagawa.colors").setup { theme = "dragon" }
				local theme = colors.theme
				local palette = colors.palette

				local menu_bg = palette.dragonBlack3
				local menu_border = palette.dragonBlack5
				local menu_sel = palette.dragonBlack4
				local doc_bg = palette.dragonBlack2

				vim.api.nvim_set_hl(0, "BlinkCmpMenu", { fg = theme.ui.fg, bg = menu_bg })
				vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = menu_border, bg = menu_bg })
				vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { fg = theme.ui.fg, bg = menu_sel })
				vim.api.nvim_set_hl(0, "BlinkCmpScrollBarThumb", { bg = menu_border })
				vim.api.nvim_set_hl(0, "BlinkCmpScrollBarGutter", { bg = menu_bg })

				vim.api.nvim_set_hl(0, "BlinkCmpDoc", { fg = theme.ui.fg, bg = doc_bg })
				vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = menu_border, bg = doc_bg })
				vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", { fg = menu_border, bg = doc_bg })
				vim.api.nvim_set_hl(0, "BlinkCmpDocCursorLine", { fg = theme.ui.fg, bg = palette.dragonBlack1 })
				vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelp", { fg = theme.ui.fg, bg = doc_bg })
				vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { fg = menu_border, bg = doc_bg })

				vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = theme.syn.comment })
				vim.api.nvim_set_hl(0, "BlinkCmpLabel", { fg = theme.ui.fg })
				vim.api.nvim_set_hl(0, "BlinkCmpLabelDetail", { fg = theme.syn.comment, bg = menu_bg })
				vim.api.nvim_set_hl(0, "BlinkCmpLabelDescription", { fg = theme.syn.special1 })
				vim.api.nvim_set_hl(0, "BlinkCmpSource", { fg = theme.syn.type })
				vim.api.nvim_set_hl(0, "BlinkCmpKind", { fg = palette.dragonAqua })
			end

			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "kanagawa*",
				callback = function()
					hi_luadoc()
					hi_blink()
				end,
			})

			hi_luadoc()
			hi_blink()
		end,
	},

	{
		"tomstolarczuk/rider.nvim",
		config = function()
			require("rider").setup()
			--vim.cmd.colorscheme "rider"
		end,
	},
}
