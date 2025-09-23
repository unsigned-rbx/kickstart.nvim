-- install with lazy.nvim
return {
	{

		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require "harpoon"

			-- REQUIRED: setup
			harpoon:setup()

			local function toggle_telescope(harpoon_files)
				local conf = require("telescope.config").values
				local pickers = require "telescope.pickers"
				local finders = require "telescope.finders"
				local actions = require "telescope.actions"
				local action_state = require "telescope.actions.state"

				pickers
					.new({}, {
						prompt_title = "Harpoon",
						finder = finders.new_table {
							results = harpoon_files.items,
							entry_maker = function(entry)
								return {
									value = entry.value,
									display = vim.fn.fnamemodify(entry.value, ":t"),
									ordinal = entry.value,
								}
							end,
						},
						sorter = conf.generic_sorter {},
						attach_mappings = function(prompt_bufnr, map)
							actions.select_default:replace(function()
								actions.close(prompt_bufnr)
								local selection = action_state.get_selected_entry()
								if selection and selection.value then
									vim.cmd("edit " .. vim.fn.fnameescape(selection.value))
								end
							end)
							return true
						end,
					})
					:find()
			end

			-- keymaps
			local keymap = vim.keymap.set

			-- add current file
			keymap("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Harpoon add file" })

			-- toggle quick menu
			keymap("n", "<leader>h", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon menu" })

			vim.keymap.set("n", "<leader>hc", function()
				harpoon:list():clear()
			end, { desc = "Clear Harpoon list" })

			-- direct navigation (first 4 slots)
			keymap("n", "<leader>1", function()
				harpoon:list():select(1)
			end)
			keymap("n", "<leader>2", function()
				harpoon:list():select(2)
			end)
			keymap("n", "<leader>3", function()
				harpoon:list():select(3)
			end)
			keymap("n", "<leader>4", function()
				harpoon:list():select(4)
			end)

			vim.keymap.set("n", "<leader>fh", function()
				toggle_telescope(harpoon:list())
			end, { desc = "[F]ind [H]arpoon file" })
		end,
	},
}
