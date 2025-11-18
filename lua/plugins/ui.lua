return {

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- {
	-- 	"akinsho/bufferline.nvim",
	-- 	version = "*",
	-- 	dependencies = "nvim-tree/nvim-web-devicons",
	-- 	config = function()
	-- 		require("bufferline").setup {
	-- 			options = {
	-- 				mode = "buffers", -- set to "tabs" to only show tabpages instead
	-- 				max_name_length = 30, -- Increase from default 18
	-- 				custom_filter = function(buf_number)
	-- 					local buf_name = vim.fn.bufname(buf_number)
	-- 					-- Exclude buffers with "claude" in the name
	-- 					if buf_name:match("claude") then
	-- 						return false
	-- 					end
	-- 					return true
	-- 				end,
	-- 				numbers = "none", -- can be "none" | "ordinal" | "buffer_id" | "both"
	-- 				close_command = "bdelete! %d",
	-- 				right_mouse_command = "bdelete! %d",
	-- 				left_mouse_command = "buffer %d",
	-- 				middle_mouse_command = nil,
	-- 				indicator = {
	-- 					style = "icon",
	-- 					icon = "▎",
	-- 				},
	-- 				buffer_close_icon = "󰅖",
	-- 				modified_icon = "●",
	-- 				close_icon = "",
	-- 				left_trunc_marker = "",
	-- 				right_trunc_marker = "",
	-- 				diagnostics = "nvim_lsp",
	-- 				diagnostics_indicator = function(count, level)
	-- 					local icon = level:match "error" and " " or " "
	-- 					return " " .. icon .. count
	-- 				end,
	-- 				duplicates_across_groups = true, -- Show parent dir for duplicate filenames
	-- 				offsets = {
	-- 					{
	-- 						filetype = "NvimTree",
	-- 						text = "File Explorer",
	-- 						text_align = "center",
	-- 						separator = true,
	-- 					},
	-- 				},
	-- 				separator_style = "thick", -- can be "slant" | "slope" | "thick" | "thin"
	-- 				show_buffer_close_icons = true,
	-- 				show_close_icon = true,
	-- 				show_tab_indicators = true,
	-- 				always_show_bufferline = true,
	-- 			},
	-- 		}
	-- 	end,
	-- },

	{ -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VimEnter", -- Sets the loading event to 'VimEnter'
		opts = {
			-- delay between pressing a key and opening which-key (milliseconds)
			-- this setting is independent of vim.opt.timeoutlen
			delay = 0,
			icons = {
				mappings = vim.g.have_nerd_font,
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					ScrollWheelDown = "<ScrollWheelDown> ",
					ScrollWheelUp = "<ScrollWheelUp> ",
					NL = "<NL> ",
					BS = "<BS> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
					F1 = "<F1>",
					F2 = "<F2>",
					F3 = "<F3>",
					F4 = "<F4>",
					F5 = "<F5>",
					F6 = "<F6>",
					F7 = "<F7>",
					F8 = "<F8>",
					F9 = "<F9>",
					F10 = "<F10>",
					F11 = "<F11>",
					F12 = "<F12>",
				},
			},
			spec = {
				{ "<leader>c", group = "[C]ode", mode = { "n", "x" } },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl", -- Version 3 uses "ibl" as the main entry point
		config = function()
			require("ibl").setup {
				exclude = {
					filetypes = {
						"norg",
					},
				},
				indent = {
					char = "│", -- Character used for the vertical indent line
				},
				scope = {
					enabled = true, -- Enable scope highlighting
					show_start = true, -- Show the start of the current scope
					show_end = false, -- Optionally show the end of the current scope
				},
			}
		end,
	},
	{ -- Collection of various small independent plugins/modules
		"echasnovski/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [Change [I]nside [']quote
			require("mini.ai").setup { n_lines = 500 }

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require "mini.statusline"
			-- set use_icons to true if you have a Nerd Font
			statusline.setup { use_icons = vim.g.have_nerd_font }

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- Override filename section to show path relative to project root
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_filename = function()
				-- Get relative path from current working directory (project root)
				return vim.fn.expand "%:."
			end

			-- ... and there is more!
			--  Check out: https://github.com/echasnovski/mini.nvim
		end,
	},
	-- {
	-- 	"eero-lehtinen/oklch-color-picker.nvim",
	-- 	event = "VeryLazy",
	-- 	version = "*",
	-- 	config = function() require("oklch-color-picker").setup()
	--
	-- 		vim.keymap.set("n", "<leader>v", function()
	-- 			require("oklch-color-picker").pick_under_cursor {
	-- 				fallback_open = {},
	-- 			}
	-- 		end, { noremap = true, silent = true })
	--
	-- 		vim.keymap.set("n", "<leader>c", function()
	-- 			require("oklch-color-picker").open_picker()
	-- 		end, { noremap = true, silent = true })
	-- 	end,
	-- 	keys = {
	-- 		-- One handed keymap recommended, you will be using the mouse
	-- 		-- {
	-- 		--   "<leader>v",
	-- 		--   function()
	-- 		--     require("oklch-color-picker").pick_under_cursor()
	-- 		--   end,
	-- 		--   desc = "Color pick under cursor",
	-- 		-- },
	-- 		-- {
	-- 		--   "<leader>c",
	-- 		--   function()
	-- 		--     require("oklch-color-picker").open_picker()
	-- 		--   end,
	-- 		--   desc = "Color pick under cursor",
	-- 	},
	-- 	---@type oklch.Opts
	-- 	opts = {
	-- 		silent = true,
	-- 	},
	-- },
}
