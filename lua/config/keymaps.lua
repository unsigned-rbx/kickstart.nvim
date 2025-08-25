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

keymap("n", "<S-j>", ":m .+1<CR>==", opts)
keymap("n", "<S-k>", ":m .-2<CR>==", opts)
keymap("v", "<S-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<S-k>", ":m '<-2<CR>gv=gv", opts)
