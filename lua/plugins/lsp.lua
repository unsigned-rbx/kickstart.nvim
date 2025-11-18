local function rojo_project()
	return vim.fs.root(0, function(name)
		return name:match ".+%.project%.json$"
	end)
end

-- [[ Luau filetype detection ]]
-- Automatically recognise .lua as luau files in a Roblox project

if rojo_project() then
	vim.filetype.add {
		extension = {
			lua = function(path)
				return path:match "%.nvim%.lua$" and "lua" or "luau"
			end,
		},
	}
end

local function get_project_type_defs()
	local root = vim.fs.root(0, { ".git", "wally.toml", "package.json", "roproject.json" }) or vim.loop.cwd()

	local type_dir = root .. "/types"
	if vim.fn.isdirectory(type_dir) == 0 then
		return {} -- no "types" folder in this project
	end

	return vim.fs.find(function(name)
		return name:match "%.d%.luau$" -- only pick .d.luau files
	end, {
		path = type_dir,
		type = "file",
		limit = math.huge,
	})
end

local function get_json_schemas()
	local schemas = require("schemastore").json.schemas()

	-- Add the rojo json schema for rojo project files
	table.insert(schemas, {
		fileMatch = { "*.project.json" },
		url = "https://raw.githubusercontent.com/rojo-rbx/vscode-rojo/master/schemas/project.template.schema.json",
	})

	return schemas
end

return {
	{
		"lopi-py/luau-lsp.nvim",
		config = function()
			vim.lsp.config("luau-lsp", {
				settings = {
					["luau-lsp"] = {
						completion = {
							ignoreGlobs = {
								"**/_Index/**",
								"node_modules/**",
								"**/.pesde/**", -- Add this line
							},
							workspace = {
								maxFiles = 5000,
							},
							imports = {
								requireStyle = "alwaysAbsolute",
								enabled = true,
								ignoreGlobs = {
									"**/_Index/**",
									"node_modules/**",
									"**/.pesde/**", -- Add this line
								},
							},
						},
					},
				},
			})

			-- See https://github.com/lopi-py/luau-lsp.nvim
			require("luau-lsp").setup {
				plugin = {
					enabled = true,
					port = 3667,
				},
				sourcemap = {
					enabled = true,
					autogenerate = true, -- automatic generation when the server is attached
					rojo_project_file = "default.project.json",
					sourcemap_file = "sourcemap.json",
				},
				fflags = {
					enable_new_solver = false, -- enables the flags required for luau's new type solver.
					sync = true, -- sync currently enabled fflags with roblox's published fflags
					override = {},
				},
				types = {
					definition_files = get_project_type_defs(),
				},
				platform = {
					type = "roblox",
					-- type = rojo_project() and "roblox" or "standard",
				},
			}

			vim.lsp.config("*", {
				capabilities = {
					workspace = {
						didChangeWatchedFiles = {
							dynamicRegistration = true,
						},
					},
				},
			})
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},

	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			-- Mason must be loaded before its dependents so we need to set it up here.
			-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
			{ "williamboman/mason.nvim", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"b0o/SchemaStore.nvim",

			-- Useful status updates for LSP.
			{
				"j-hui/fidget.nvim",
				opts = {},
				config = function()
					require("fidget").setup {
						notification = {
							window = {
								winblend = 0, -- 0 = no "frosted glass"
								border = "none", -- optional, removes the box line
							},
						},
					}
				end,
			},

			-- Allows extra capabilities provided by nvim-cmp
			-- "hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					-- Find references for the word under your cursor.
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })

						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
							end,
						})
					end
					vim.lsp.config("jsonls", {
						settings = {
							json = {
								-- Send custom json schemas to jsonls to provide its features when you open a json file
								schemas = get_json_schemas(),
								validate = { enable = true },
							},
						},
					})
					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
						end, "[T]oggle Inlay [H]ints")
					end

					vim.lsp.enable {
						"lua_ls",
						"eslint",
						"jsonls",
						"vtsls",
					}
				end,
			})

			-- Change diagnostic symbols in the sign column (gutter)
			-- if vim.g.have_nerd_font then
			--   local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
			--   local diagnostic_signs = {}
			--   for type, icon in pairs(signs) do
			--     diagnostic_signs[vim.diagnostic.severity[type]] = icon
			--   end
			--   vim.diagnostic.config { signs = { text = diagnostic_signs } }
			-- end

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			-- local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				-- clangd = {},
				-- gopls = {},
				-- pyright = {},
				-- rust_analyzer = {},
				-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine
				-- ts_ls = {},
				--

				lua_ls = {
					-- cmd = { ... },
					-- filetypes = { ... },
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--
			-- To check the current status of installed tools and/or manually install
			-- other tools, you can run
			--    :Mason
			--
			-- You can press `g?` for help in this menu.
			--
			-- `mason` had to be setup earlier: to configure its options see the
			-- `dependencies` table for `nvim-lspconfig` above.
			--
			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"lua-language-server",
				"luau-lsp",
				"stylua",

				"vtsls",
				-- "eslint-lsp",
				"prettierd",
				"json-lsp",
			})
			require("mason-tool-installer").setup { ensure_installed = ensure_installed }

			require("mason-lspconfig").setup {
				automatic_enable = {
					exclude = {
						"luau_lsp",
					},
				},
				-- handlers = {
				-- 	luau_lsp = function() end,
				-- 	function(server_name)
				-- 		local server = servers[server_name] or {}
				-- 		-- This handles overriding only values explicitly passed
				-- 		-- by the server configuration above. Useful when disabling
				-- 		-- certain features of an LSP (for example, turning off formatting for ts_ls)
				-- 		server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
				-- 		require("lspconfig")[server_name].setup(server)
				-- 	end,
				-- },
			}
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "neovim", types = true }, -- Neovim API (vim.*, vim.api.*)
				"lazy.nvim", -- Lazy plugin spec types
				{ path = "${3rd}/luv/library", words = { "vim%.uv", "vim%.loop" } }, -- uv
			},
		},
	},
	-- {
	-- 	"folke/lazydev.nvim",
	-- 	ft = "lua",
	-- 	opts = {
	-- 		library = {
	-- 			-- Load luvit types when the `vim.uv` word is found
	-- 			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	-- 		},
	-- 	},
	-- },

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			-- {
			-- 	"<leader>fb",
			-- 	function()
			-- 		require("conform").format { async = true, lsp_format = "fallback" }
			-- 	end,
			-- 	mode = "",
			-- 	desc = "[F]ormat buffer",
			-- },
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				return {
					timeout_ms = 500,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				-- luau = { "stylua" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},
}
