vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.o.wrap = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = false
vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"

vim.opt.cursorline = true

vim.opt.tabstop = 4 -- Number of spaces a <Tab> in the file counts for
vim.opt.shiftwidth = 4 -- Number of spaces to use for autoindenting
vim.opt.expandtab = false -- Use spaces instead of tabs

vim.opt.termguicolors = true
vim.opt.laststatus = 3 -- global statusline
vim.opt.fillchars:append { -- cleaner separators
	vert = "│",
	fold = " ",
	eob = " ",
	diff = "╱",
}
vim.opt.pumblend = 10
vim.opt.winblend = 10

-- Rounded borders for LSP popups/diagnostics
local border = "rounded"
vim.diagnostic.config { float = { border = border } }
vim.o.winborder = "rounded"

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 999
vim.opt.virtualedit = "onemore"

--  Remove this option if you want your OS clipboard to remain independent.
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Make sure you have ripgrep installed.
-- Add the following function to your `~/.config/nvim/init.lua`:
-- remote auto comment
vim.opt.formatoptions:remove "r"
vim.opt.formatoptions:remove "o"

vim.diagnostic.config {
	virtual_text = { severity_sort = true },
}

-- Tags like @param, @return
vim.api.nvim_set_hl(0, "@attribute.luadoc", { fg = "#DCA561", bold = true }) -- autumn yellow

-- Parameter names
vim.api.nvim_set_hl(0, "@field.luadoc", { fg = "#7E9CD8", italic = true }) -- dragon blue

-- Types (Player, boolean, number, etc.)
vim.api.nvim_set_hl(0, "@type.luadoc", { fg = "#98BB6C", bold = true }) -- spring green

-- Plain text description
vim.api.nvim_set_hl(0, "@comment.luadoc", { fg = "#DCD7BA" }) -- fuji white

-- Strings inside docs
vim.api.nvim_set_hl(0, "@string.luadoc", { fg = "#6A9589" }) -- crystal blue
