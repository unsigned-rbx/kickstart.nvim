require "config.options"
require "config.keymaps"
require "config.autocmds"

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("Lazy").setup("plugins", {
	ui = {
		backdrop = 60,
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- vim.api.nvim_set_hl(0, "ErrorLensError", { fg = "#FF6363", bg = "#4B252C", bold = true })
-- vim.api.nvim_set_hl(0, "ErrorLensWarn", { fg = "#FA973A", bg = "#403733", bold = true })
-- vim.api.nvim_set_hl(0, "ErrorLensInfo", { fg = "#5B38E8", bg = "#281478", bold = true })
-- vim.api.nvim_set_hl(0, "ErrorLensHint", { fg = "#25E64B", bg = "#147828", bold = true })
