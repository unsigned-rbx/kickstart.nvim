return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" }, -- Lazy load for better startup time
	opts = {
		signs = {
			add = { text = "┃" }, -- Double line
			change = { text = "┃" },
			delete = { text = "┃" },
			topdelete = { text = "┃" },
			changedelete = { text = "┃" },
		},
		signs_staged_enable = false, -- Disable staged signs if you don't use git add -p workflow
		current_line_blame = true, -- Don't show blame by default (toggle with keymap)
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
			delay = 300,
		},
		preview_config = {
			-- Options passed to nvim_open_win
			border = "rounded",
			style = "minimal",
			relative = "cursor",
			row = 0,
			col = 1,
		},
		on_attach = function(bufnr)
			local gitsigns = require "gitsigns"

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map("n", "]h", function() -- Changed from ]c to ]h for consistency
				if vim.wo.diff then
					vim.cmd.normal { "]c", bang = true }
				else
					gitsigns.nav_hunk "next"
				end
			end, { desc = "Next git hunk" })

			map("n", "[h", function() -- Changed from [c to [h for consistency
				if vim.wo.diff then
					vim.cmd.normal { "[c", bang = true }
				else
					gitsigns.nav_hunk "prev"
				end
			end, { desc = "Previous git hunk" })

			-- Actions in visual mode
			map("v", "<leader>hs", function()
				gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
			end, { desc = "Stage hunk" })

			map("v", "<leader>hr", function()
				gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
			end, { desc = "Reset hunk" })

			-- Actions in normal mode
			map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage hunk" })
			map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })
			map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage entire buffer" })
			map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
			map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset entire buffer" })
			map("n", "<leader>hp", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })
			map("n", "<leader>hP", gitsigns.preview_hunk, { desc = "Preview hunk in popup" })
			map("n", "<leader>hb", function()
				gitsigns.blame_line { full = true }
			end, { desc = "Blame current line" })
			map("n", "<leader>hB", gitsigns.toggle_current_line_blame, { desc = "Toggle line blame" })
			map("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff against index" })
			map("n", "<leader>hD", function()
				gitsigns.diffthis "~"
			end, { desc = "Diff against last commit" })

			-- Text object for hunks
			map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })

			-- Additional useful mappings
			map("n", "<leader>hq", function()
				gitsigns.setqflist "all"
			end, { desc = "Add all hunks to quickfix" })

			map("n", "<leader>hl", function()
				gitsigns.setloclist()
			end, { desc = "Add buffer hunks to location list" })
		end,
	},
}
