-- subtle popup transparency (optional)
vim.o.pumblend = 12

-- optional: tidy up cmp highlight links (works with most themes)
vim.api.nvim_set_hl(0, "CmpBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "CmpPmenu", { link = "NormalFloat" })
vim.api.nvim_set_hl(0, "CmpSel", { link = "PmenuSel" })
vim.api.nvim_set_hl(0, "CmpDoc", { link = "NormalFloat" })
vim.api.nvim_set_hl(0, "CmpDocBorder", { link = "FloatBorder" })
return {
	-- {
	-- 	"Saghen/blink.cmp",
	-- 	version = "*",
	-- 	dependencies = {
	-- 		{
	-- 			"nvim-lua/plenary.nvim",
	-- 			"L3MON4D3/LuaSnip",
	-- 			build = (function()
	-- 				-- Build Step is needed for regex support in snippets.
	-- 				-- This step is not supported in many windows environments.
	-- 				-- Remove the below condition to re-enable on windows.
	-- 				if vim.fn.has "win32" == 1 or vim.fn.executable "make" == 0 then
	-- 					return
	-- 				end
	-- 				return "make install_jsregexp"
	-- 			end)(),
	-- 			dependencies = {
	-- 				-- `friendly-snippets` contains a variety of premade snippets.
	-- 				--    See the README about individual language/framework/plugin snippets:
	-- 				--    https://github.com/rafamadriz/friendly-snippets
	-- 				{
	-- 					"rafamadriz/friendly-snippets",
	-- 					config = function() end,
	-- 				},
	-- 			},
	-- 			config = function()
	-- 				require("luasnip").filetype_extend("luau", { "lua" })
	-- 				require("luasnip.loaders.from_vscode").lazy_load()
	-- 				-- require("luasnip.loaders.from_vscode").lazy_load {
	-- 				--   paths = { "~/.config/nvim/lua/snippets/" },
	-- 				-- }
	-- 			end,
	-- 		},
	-- 		"onsails/lspkind.nvim", -- for icons
	-- 		-- "saadparwaiz1/cmp_luasnip",
	-- 	},
	-- 	config = function()
	--
	-- 		-- local cmp = require "cmp"
	-- 		-- local fusion_source = require "cmp_sources.fusion"
	-- 		-- cmp.register_source("fusion", fusion_source:new()),
	-- 	end,
	-- 	opts = {
	-- 		snippets = { preset = "luasnip" },
	-- 		keymap = {
	-- 			-- 'default' (recommended) for mappings similar to built-in completions
	-- 			--   <c-y> to accept ([y]es) the completion.
	-- 			--    This will auto-import if your LSP supports it.
	-- 			--    This will expand snippets if the LSP sent a snippet.
	-- 			--
	-- 			-- For an understanding of why the 'default' preset is recommended,
	-- 			-- you will need to read `:help ins-completion`
	-- 			--
	-- 			-- For more information about presets,
	-- 			-- see https://cmp.saghen.dev/configuration/keymap.html#presets
	-- 			preset = "default",
	-- 			["<CR>"] = { "select_and_accept", "fallback" }, -- enter accepts
	-- 			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
	-- 			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
	-- 		},
	-- 		sources = {
	-- 			default = { "lsp", "path", "snippets", "buffer", "lazydev", "fusion" },
	-- 			providers = {
	-- 				lazydev = {
	-- 					module = "lazydev.integrations.blink",
	-- 					fallbacks = { "lsp" },
	-- 				},
	-- 				fusion = {
	-- 					name = "Fusion",
	-- 					module = "cmp_sources.fusion_blink",
	-- 					-- lower priority so it never blocks others
	-- 					score_offset = -1,
	-- 				},
	-- 			},
	-- 		},
	-- 		cmdline = {
	-- 			enabled = false,
	-- 		},
	-- 	},
	-- },
	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source

			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has "win32" == 1 or vim.fn.executable "make" == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					{
						"rafamadriz/friendly-snippets",
						config = function() end,
					},
				},
				config = function()
					-- require("luasnip").filetype_extend("luau", { "lua" })
					require("luasnip.loaders.from_vscode").lazy_load()
					-- require("luasnip.loaders.from_vscode").lazy_load {
					--   paths = { "~/.config/nvim/lua/snippets/" },
					-- }
				end,
			},
			"onsails/lspkind.nvim", -- for icons
			"saadparwaiz1/cmp_luasnip",

			-- Adds other completion capabilities.
			--  nvim-cmp does not ship with all sources by default. They are split
			--  into multiple repos for maintenance purposes.
			"hrsh7th/cmp-nvim-lsp",

			-- Snippet loader, by default it will load snippets in `NVIM_CONFIG/snippets/*.json`
			-- See https://github.com/garymjr/nvim-snippets
			{ "garymjr/nvim-snippets", opts = {} },

			"hrsh7th/cmp-path",
		},
		config = function()
			-- See `:help cmp`
			local cmp = require "cmp"
			local fusion_source = require "cmp_sources.fusion"
			cmp.register_source("fusion", fusion_source:new())
			local luasnip = require "luasnip"
			luasnip.filetype_extend("luau", { "lua" })

			local lspkind = require "lspkind"
			luasnip.config.setup {}

			cmp.setup {
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				window = {
					completion = cmp.config.window.bordered {
						border = "rounded",
						winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:CmpSel,Search:None",
						col_offset = -1,
						side_padding = 1,
					},
					documentation = cmp.config.window.bordered {
						border = "rounded",
						winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder",
					},
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				-- icons + clean columns (kind | abbr | menu)
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, item)
						item = lspkind.cmp_format {
							mode = "symbol_text",
							maxwidth = 40,
							ellipsis_char = "…",
							preset = "default",
						}(entry, item)

						-- short source tags
						local menu = {
							nvim_lsp = "LSP",
							luasnip = "Snip",
							snippets = "Snip",
							path = "Path",
							buffer = "Buf",
							neorg = "Neorg",
							fusion = "Fusion",
							lazydev = "Lazy",
						}
						item.menu = menu[entry.source.name] or entry.source.name
						return item
					end,
				},

				sorting = {
					priority_weight = 2,
					comparators = {
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.score,
						cmp.config.compare.recently_used,
						cmp.config.compare.locality,
						cmp.config.compare.kind,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
				-- formatting = {
				-- 	format = lspkind.cmp_format {
				-- 		mode = "symbol_text", -- show symbol + text
				-- 		maxwidth = 30, -- prevent the popup from showing more than provided characters
				-- 		-- The preset defines default icons and settings, but you can also add your own icons.
				-- 		preset = "default",
				-- 	},
				-- },
				-- For an understanding of why these mappings were
				-- chosen, you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				mapping = cmp.mapping.preset.insert {
					-- Select the [n]ext item
					["<C-n>"] = cmp.mapping.select_next_item(),
					-- Select the [p]revious item
					["<C-p>"] = cmp.mapping.select_prev_item(),

					-- Scroll the documentation window [b]ack / [f]orward
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Accept ([y]es) the completion.
					--  This will auto-import if your LSP supports it.
					--  This will expand snippets if the LSP sent a snippet.
					["<C-y>"] = cmp.mapping.confirm { select = true },

					-- If you prefer more traditional completion keymaps,
					-- you can uncomment the following lines
					["<CR>"] = cmp.mapping.confirm { select = true },
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),

					-- Manually trigger a completion from nvim-cmp.
					--  Generally you don't need this, because nvim-cmp will display
					--  completions whenever it has completion options available.
					["<C-Space>"] = cmp.mapping.complete {},

					-- Think of <c-l> as moving to the right of your snippet expansion.
					--  So if you have a snippet that's like:
					--  function $name($args)
					--    $body
					--  end
					--
					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),

					-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
					--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
				},
				sources = {
					{
						name = "lazydev",
						-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
						group_index = 0,
					},
					{ name = "luasnip", priority = 1000 },
					{ name = "snippets", priority = 980 },
					{ name = "neorg", priority = 970 },
					{ name = "fusion", priority = 950 },
					{ name = "nvim_lsp", priority = 900 },
					{ name = "path", priority = 800 },
				},
			}
		end,
	},
}
