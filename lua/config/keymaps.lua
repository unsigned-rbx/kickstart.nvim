local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Ensure cut operations use system clipboard
vim.keymap.set({ "n", "v" }, "d", '"+d', { noremap = true, desc = "Cut to clipboard" })
vim.keymap.set("n", "dd", '"+dd', { noremap = true, desc = "Cut line to clipboard" })
vim.keymap.set("n", "D", '"+D', { noremap = true, desc = "Cut to end of line" })

-- You can also ensure consistent yank behavior
vim.keymap.set({ "n", "v" }, "y", '"+y', { noremap = true, desc = "Yank to clipboard" })
vim.keymap.set("n", "yy", '"+yy', { noremap = true, desc = "Yank line to clipboard" })
vim.keymap.set("n", "Y", '"+Y', { noremap = true, desc = "Yank to end of line" })

-- Ensure cut operations use system clipboard
vim.keymap.set({ "n", "v" }, "d", '"+d', { noremap = true, desc = "Cut to clipboard" })
vim.keymap.set("n", "dd", '"+dd', { noremap = true, desc = "Cut line to clipboard" })
vim.keymap.set("n", "D", '"+D', { noremap = true, desc = "Cut to end of line" })

-- You can also ensure consistent yank behavior
vim.keymap.set({ "n", "v" }, "y", '"+y', { noremap = true, desc = "Yank to clipboard" })
vim.keymap.set("n", "yy", '"+yy', { noremap = true, desc = "Yank line to clipboard" })
vim.keymap.set("n", "Y", '"+Y', { noremap = true, desc = "Yank to end of line" })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- nvim tree
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("v", "<", "<gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", ">", ">gv", { noremap = true, silent = true })

vim.keymap.set({ "n", "v" }, "d", '"+d', { noremap = true })
vim.keymap.set("n", "dd", '"+dd', { noremap = true })

keymap("v", "<S-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<S-k>", ":m '<-2<CR>gv=gv", opts)

-- Telescope diagnostics (shows all diagnostics across workspace)
keymap("n", "<leader>sd", ":Telescope diagnostics<CR>", { desc = "Search all diagnostics" })

keymap("n", "<leader>x", "", {
	noremap = true,
	callback = function()
		for _, client in ipairs(vim.lsp.get_clients()) do
			require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
		end
	end,
})

vim.keymap.set("n", "j", "jzz", { desc = "Down and center" })
vim.keymap.set("n", "k", "kzz", { desc = "Up and center" })

-- Map Escape to clear search highlight
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { noremap = true, silent = true })

keymap("n", "<leader>dw", function()
	-- Save cursor position
	local pos = vim.api.nvim_win_get_cursor(0)

	-- Delete word backward
	vim.cmd "normal! db"

	-- Optional: adjust cursor position if needed
end, { desc = "Delete word and go back" })

-- Restart only the LSP client(s) attached to the current buffer
keymap("n", "<leader>rf", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients { bufnr = bufnr }

	if vim.tbl_isempty(clients) then
		vim.notify("No LSP client attached to this buffer", vim.log.levels.WARN)
		return
	end

	for _, client in pairs(clients) do
		local name = client.name
		vim.lsp.stop_client(client.id, true) -- force stop
		vim.schedule(function()
			vim.cmd("LspStart " .. name)
			vim.notify("Restarted LSP: " .. name, vim.log.levels.INFO)
		end)
	end
end, { desc = "Restart LSP for current buffer" })
