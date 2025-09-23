local telescope = require "telescope"
local actions = require "telescope.actions"
local themes = require "telescope.themes"

-- subtle popup transparency
vim.o.pumblend = 12

-- nicer highlights (works with most colorschemes)
vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "NormalFloat" })
vim.api.nvim_set_hl(0, "TelescopeSelection", { link = "PmenuSel" })

local nerd = vim.g.have_nerd_font
local prompt_icon = nerd and "   " or "> "
local caret_icon = nerd and " " or "> "
local entry_prefix = "  "

local function dim_gitignored()
	-- file name + icon for ignored entries
	vim.api.nvim_set_hl(0, "NvimTreeGitIgnored", { link = "Comment" })
	vim.api.nvim_set_hl(0, "NvimTreeGitIgnoredIcon", { link = "Comment" })
end
dim_gitignored()
vim.api.nvim_create_autocmd("ColorScheme", { callback = dim_gitignored })

local function filename_first_maker(opts)
	local make_entry = require "telescope.make_entry"
	local gen = make_entry.gen_from_file(opts or {})
	return function(path)
		local e = gen(path)
		if not e then
			return nil
		end
		local tail = e.path:match "[^/\\]+$" or e.path
		e.ordinal = (tail .. " " .. e.path):lower() -- basename has highest weight
		e.display = tail .. " — " .. e.path -- nice display (optional)
		return e
	end
end

-- filename-biased sorter (bonus if prompt matches the basename)
local sorters = require "telescope.sorters"
local base = sorters.get_fzy_sorter() -- fast & good enough

local filename_bias_sorter = sorters.Sorter:new {
	scoring_function = function(_, prompt, _, entry)
		local s = base:scoring_function(prompt, entry.ordinal, entry)
		if not s or s < 0 then
			return s
		end
		local tail = (entry.path or entry.ordinal):match("[^/\\]+$"):lower()
		local p = (prompt or ""):lower()

		-- strong bonus when basename matches
		if tail:find("^" .. vim.pesc(p)) then
			s = s - 1500 -- prefix match
		elseif tail:find(p, 1, true) then
			s = s - 900 -- substring match
		end
		return s
	end,
	highlighter = function(_, prompt, display)
		return base:highlighter(prompt, display)
	end,
}

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
					side = "left", -- docked on the left
					width = 35, -- pick a width you like
					signcolumn = "yes",
					-- remove the `float = { ... }` block
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

				filters = {
					dotfiles = true, -- Hide dotfiles by default
					git_clean = false, -- Hide clean git files
					no_buffer = false, -- Hide files not in buffer list
					git_ignored = true, -- Hide git ignored files (default: true)
					custom = { -- Custom patterns to always hide
						"node_modules",
						".cache",
						"__pycache__",
						"*.pyc",
						".DS_Store",
					},
					exclude = { -- Exceptions to the custom filters
						".gitignore",
						".env.example",
					},
				},
				live_filter = {
					prefix = "[FILTER]: ", -- Text shown before filter
					always_show_folders = true, -- Keep folders visible even when filtered
				},

				actions = {
					open_file = { quit_on_open = false, resize_window = true }, -- auto-close tree when opening a file
				},

				on_attach = function(bufnr)
					local api = require "nvim-tree.api"

					-- Default mappings
					api.config.mappings.default_on_attach(bufnr)

					vim.wo.winfixwidth = true
					-- Custom mapping to close with Escape
					vim.keymap.set("n", "<Esc>", api.tree.close, { buffer = bufnr, noremap = true, silent = true })
				end,

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
			local ignore_globs = {
				"**/_Index/**",
				"node_modules/**",
				".git/**",
				".svn/**",
				".hg/**",
				"dist/**",
				"build/**",
				".next/**",
				".nuxt/**",
				"target/**",
				"__pycache__/**",
				"*.egg-info/**",
				".vscode/**",
				".idea/**",
				"*.swp",
				"*.swo",
				"*~",
				".DS_Store",
				"Thumbs.db",
				"*.log",
				"tmp/**",
				"temp/**",
			}

			local telescope = require "telescope"
			local actions = require "telescope.actions"
			local themes = require "telescope.themes"
			local builtin = require "telescope.builtin"
			local make_entry = require "telescope.make_entry"
			local entry_display = require "telescope.pickers.entry_display"
			local utils = require "telescope.utils"
			local sorters = require "telescope.sorters"

			local prompt_icon = "🔍 "
			local caret_icon = "❯ "
			local entry_prefix = "  "

			telescope.setup {
				defaults = {
					temp__scrolling_limit = 10000,

					vimgrep_arguments = (function()
						local v = require("telescope.config").values.vimgrep_arguments
						local args = vim.deepcopy(v)
						table.insert(args, "--hidden")
						for _, g in ipairs(ignore_globs) do
							table.insert(args, "--glob")
							table.insert(args, "!" .. g)
						end
						return args
					end)(),

					file_ignore_patterns = {
						"/_Index/",
						"/node_modules/",
						"/.git/",
						"/dist/",
						"/build/",
						"/.next/",
						"/.nuxt/",
						"/target/",
						"/__pycache__/",
						"/%.egg%-info/",
						"/%.vscode/",
						"/%.idea/",
						"%.swp$",
						"%.swo$",
						"%.log$",
						"/tmp/",
						"/temp/",
						"%.DS_Store$",
						"Thumbs%.db$",
					},

					prompt_prefix = prompt_icon,
					selection_caret = caret_icon,
					entry_prefix = entry_prefix,
					results_title = false,
					dynamic_preview_title = true,
					sorting_strategy = "ascending",
					layout_strategy = "flex",
					layout_config = {
						prompt_position = "top",
						width = 0.95,
						height = 0.90,
						horizontal = { preview_width = 0.55 },
						vertical = { preview_height = 0.45 },
					},
					winblend = 8,
					path_display = { filename_first = { reverse_directories = false } },
					color_devicons = true,

					mappings = {
						i = {
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<C-u>"] = false,
							["<C-d>"] = false,
						},
					},
				},

				pickers = {
					find_files = {
						previewer = true,
						hidden = true,
						follow = true,
						sorting_strategy = "ascending",
						layout_strategy = "flex",
						layout_config = {
							prompt_position = "top",
							width = 0.95,
							height = 0.90,
							horizontal = { preview_width = 0.55 },
							vertical = { preview_height = 0.45 },
						},
						path_display = { filename_first = { reverse_directories = false } },
						entry_maker = filename_first_maker(),
						sorter = filename_bias_sorter,
					},
					buffers = themes.get_dropdown {
						previewer = false,
						initial_mode = "normal",
						sort_lastused = true,
						ignore_current_buffer = true,
						mappings = {
							n = { ["dd"] = actions.delete_buffer },
							i = { ["<C-x>"] = actions.delete_buffer },
						},
					},
					oldfiles = themes.get_dropdown { previewer = false },
					live_grep = {
						layout_strategy = "horizontal",
						layout_config = {
							prompt_position = "top",
							width = 0.98,
							height = 0.95,
							preview_width = 0.30,
						},
						path_display = { filename_first = { reverse_directories = false } },
						results_title = false,
						prompt_title = "Live Grep",
						additional_args = function()
							local a = { "--hidden" }
							for _, g in ipairs(ignore_globs) do
								table.insert(a, "--glob")
								table.insert(a, "!" .. g)
							end
							return a
						end,
					},
					diagnostics = themes.get_ivy {},
				},

				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true, -- 🔑 ensures filename priority
						case_mode = "smart_case",
					},
					["ui-select"] = themes.get_dropdown(),
				},
			}

			pcall(telescope.load_extension, "fzf")
			pcall(telescope.load_extension, "ui-select")

			-- highlight for commented results
			vim.api.nvim_set_hl(0, "TelescopeResultsCommented", { link = "Comment" })

			-- Wrap vimgrep entry maker and tag commented lines
			local function comment_entry_maker(opts)
				local gen = make_entry.gen_from_vimgrep(opts or {})
				local displayer = entry_display.create {
					separator = " ",
					items = { { width = 0.45 }, { width = 8 }, { remaining = true } },
				}

				return function(line)
					local e = gen(line)
					if not e then
						return nil
					end

					local ext = (e.filename:match "%.([%w_]+)$" or ""):lower()
					local commented = false
					if ext == "lua" or ext == "luau" then
						local cmt = e.text:find "%-%-"
						if cmt and (e.col or 1) > cmt then
							commented = true
						end
					end
					e._commented = commented

					local fname = utils.transform_path(opts, e.filename)
					e.display = function(entry)
						return displayer {
							{
								fname,
								commented and "TelescopeResultsCommented" or "TelescopeResultsFileName",
							},
							{ string.format("%d:%d", entry.lnum or 0, entry.col or 0), "TelescopeResultsLineNr" },
							{
								entry.text,
								commented and "TelescopeResultsCommented" or "TelescopeResultsNormal",
							},
						}
					end

					return e
				end
			end

			-- Sorter that pushes commented hits to the bottom
			local base = sorters.get_fzy_sorter()
			local demote_comments = sorters.Sorter:new {
				scoring_function = function(_, prompt, line, entry)
					local s = base:scoring_function(prompt, line, entry)
					if not s or s < 0 then
						return s
					end
					if entry._commented then
						return s + 1e9
					end
					return s
				end,
				highlighter = function(_, prompt, display)
					return base:highlighter(prompt, display)
				end,
			}

			-- Keymaps
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", function()
				builtin.live_grep {
					sorting_strategy = "ascending",
					entry_maker = comment_entry_maker {
						path_display = { filename_first = { reverse_directories = false } },
					},
					sorter = demote_comments,
					additional_args = function()
						return { "--hidden" }
					end,
				}
			end, { desc = "[S]earch by [G]rep (mark commented hits)" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

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
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
		},
		config = function()
			-- Close LazyGit floating window with <Esc>
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "lazygit",
				callback = function()
					-- terminal mode <Esc>
					vim.keymap.set("t", "<Esc>", [[<C-\><C-n><cmd>q<CR>]], {
						buffer = true,
						noremap = true,
						silent = true,
						desc = "Close LazyGit with <Esc>",
					})

					-- (optional) normal mode <Esc>, in case you hit <C-\><C-n> first
					vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", {
						buffer = true,
						noremap = true,
						silent = true,
						desc = "Exit LazyGit with <Esc>",
					})
				end,
			})
		end,
	},
}
