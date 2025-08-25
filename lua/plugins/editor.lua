return {
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup {
				view = {
					signcolumn = "yes",
					float = {
						enable = true,
						quit_on_focus_loss = true,
						open_win_config = function()
							local columns, lines = vim.o.columns, vim.o.lines
							local w = math.floor(columns * 0.28)
							local h = math.floor(lines * 0.90)
							return {
								relative = "editor",
								border = "rounded",
								width = w,
								height = h,
								row = math.floor((lines - h) / 2),
								col = math.floor((columns - w) / 2),
							}
						end,
					},
				},

				renderer = {
					group_empty = true,
					highlight_git = true,
					highlight_opened_files = "name",
					indent_markers = { enable = true, inline_arrows = true },
					icons = {
						show = { file = true, folder = true, folder_arrow = true, git = true, modified = true },
						glyphs = {
							folder = { arrow_closed = "", arrow_open = "" },
							git = {
								unstaged = "",
								staged = "S",
								unmerged = "",
								renamed = "➜",
								untracked = "U",
								deleted = "",
								ignored = "◌",
							},
						},
					},
				},

				diagnostics = {
					enable = true,
					show_on_dirs = true,
					icons = { hint = "󰌵", info = "", warning = "", error = "" },
				},

				modified = { enable = true, show_on_dirs = true },

				git = { enable = true, ignore = false },

				filters = { dotfiles = false, git_ignored = true, custom = { "^.git$", "node_modules", ".cache" } },

				actions = {
					open_file = { quit_on_open = true, resize_window = true }, -- auto-close tree when opening a file
				},
				-- update_focused_file = {
				-- 	enable = true, -- Automatically focus the opened file
				-- 	update_cwd = true, -- Optionally update the working directory
				-- },
				-- sort = {
				-- 	sorter = "case_sensitive",
				-- },
				-- view = {
				-- 	adaptive_size = true, -- Adjust the width of the tree dynamically
				-- 	--width = 40
				-- },
				-- renderer = {
				-- 	group_empty = true,
				-- },
				-- git = {
				-- 	enable = true,
				-- 	ignore = false,
				-- },
				-- filters = {
				-- 	dotfiles = true,
				-- },
				-- on_attach = function(bufnr)
				-- 	local api = require "nvim-tree.api"
				-- 	-- keep all the built-in mappings
				-- 	api.config.mappings.default_on_attach(bufnr)
				--
				-- 	-- your extra map: close tree with ESC
				-- 	vim.keymap.set("n", "<Esc>", api.tree.close, {
				-- 		buffer = bufnr,
				-- 		noremap = true,
				-- 		silent = true,
				-- 		desc = "Close tree",
				-- 	})
				--
			}

			vim.keymap.set(
				"n",
				"<leader>f",
				"<cmd>NvimTreeFindFile<CR>",
				{ silent = true, noremap = true, desc = "Reveal current file" }
			)
		end,
	},
	{ -- Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable "make" == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup {
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			}

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require "telescope.builtin"
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			-- Slightly advanced example of overriding default behavior and theme
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
					winblend = 10,
					previewer = false,
				})
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep {
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				}
			end, { desc = "[S]earch [/] in Open Files" })

			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files { cwd = vim.fn.stdpath "config" }
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- Autopair support
	{
		"windwp/nvim-autopairs",
		opts = {},
	},
	{
		"NMAC427/guess-indent.nvim",
		opts = {},
	},
	{
		"gbprod/cutlass.nvim",
		opts = {
			-- your configuration comes here
			-- or don't set opts to use the default settings
			-- refer to the configuration section below
		},
	},
	{
		"folke/trouble.nvim",
		branch = "main", -- v3
		event = "LspAttach",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			auto_close = true, -- close when no diagnostics
			use_diagnostic_signs = true, -- use your theme’s DiagnosticSign* icons
			modes = {
				diagnostics = { preview = { type = "float", border = "rounded" } },
			},
		},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Location list" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list" },
			{
				"]x",
				function()
					require("trouble").next { mode = "diagnostics", skip_groups = true, jump = true }
				end,
				desc = "Next diagnostic (Trouble)",
			},
			{
				"[x",
				function()
					require("trouble").prev { mode = "diagnostics", skip_groups = true, jump = true }
				end,
				desc = "Prev diagnostic (Trouble)",
			},
		},
	},
	{
		"chikko80/error-lens.nvim",
		-- event = "VeryLazy",
		dependencies = { "nvim-telescope/telescope.nvim" },
		opts = {
			auto_adjust = {
				enable = false,
				-- fallback_bg_color = "#281478", -- mandatory if enable true (e.g. #281478)
				-- step = 7, -- inc: colors should be brighter/darker
				-- total = 30, -- steps of blender
			},
			prefix = 4, -- distance code <-> diagnostic message
			-- default colors
			-- colors = {
			-- 	error_fg = "#FF6363", -- diagnostic font color
			-- 	error_bg = "#4B252C", -- diagnostic line color
			-- 	warn_fg = "#FA973A",
			-- 	warn_bg = "#403733",
			-- 	info_fg = "#5B38E8",
			-- 	info_bg = "#281478",
			-- 	hint_fg = "#25E64B",
			-- 	hint_bg = "#147828",
			-- },
		},
		config = function()
			local test = 3
		end,
	},
	{
		"artemave/workspace-diagnostics.nvim",
	},
	{
		"3rd/image.nvim",
		config = function()
			require("image").setup {
				kitty_method = "normal",
				backend = "kitty", -- kitty, ueberzug, or iterm2
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = true,
						only_render_image_at_cursor = false,
						filetypes = { "markdown", "vimwiki" },
					},
					neorg = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = true,
						only_render_image_at_cursor = false,
						filetypes = { "norg" },
					},
				},
				max_width = nil,
				max_height = nil,
				max_width_window_percentage = nil,
				max_height_window_percentage = 50,
				window_overlap_clear_enabled = false,
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
			}
		end,
	},
}
