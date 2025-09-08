local function transparent()
	local groups = {
		"Normal",
		"NormalNC",
		"NormalFloat",
		"SignColumn",
		"LineNr",
		"CursorLineNr",
		"EndOfBuffer",
		"MsgArea",
		"WinSeparator",
		"VertSplit",
		"StatusLine",
		"StatusLineNC",
		-- file tree / telescope if you use them
		"NeoTreeNormal",
		"NeoTreeEndOfBuffer",
		"NvimTreeNormal",
		"NvimTreeEndOfBuffer",
		"TelescopeNormal",
		"TelescopeBorder",
	}
	for _, g in ipairs(groups) do
		vim.api.nvim_set_hl(0, g, { bg = "none" })
	end
end

-- Re-apply when changing colorschemes
local function fix_telescope()
	local none = { bg = "none" }
	-- main panes
	vim.api.nvim_set_hl(0, "TelescopeNormal", none)
	vim.api.nvim_set_hl(0, "TelescopePromptNormal", none)
	vim.api.nvim_set_hl(0, "TelescopeResultsNormal", none)
	vim.api.nvim_set_hl(0, "TelescopePreviewNormal", none)
	-- borders
	vim.api.nvim_set_hl(0, "TelescopeBorder", none)
	vim.api.nvim_set_hl(0, "TelescopePromptBorder", none)
	vim.api.nvim_set_hl(0, "TelescopeResultsBorder", none)
	vim.api.nvim_set_hl(0, "TelescopePreviewBorder", none)
	-- titles
	vim.api.nvim_set_hl(0, "TelescopeTitle", { bg = "none", fg = "#e6c384" }) -- Kanagawa yellow
	vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none", fg = "#c4746e" }) -- red accent
	vim.api.nvim_set_hl(0, "TelescopeResultsTitle", none)
	vim.api.nvim_set_hl(0, "TelescopePreviewTitle", none)
	-- general floats
	vim.api.nvim_set_hl(0, "NormalFloat", none)
	vim.api.nvim_set_hl(0, "FloatBorder", none)
end

local function transparent_signs()
	local groups = {
		"SignColumn",
		"SignColumnSB", -- generic sign cols
		"GitSignsAdd",
		"GitSignsChange",
		"GitSignsDelete", -- if using gitsigns
		"DiagnosticSignError",
		"DiagnosticSignWarn",
		"DiagnosticSignInfo",
		"DiagnosticSignHint",
	}
	for _, g in ipairs(groups) do
		local hl = vim.api.nvim_get_hl(0, { name = g })
		if hl then
			-- keep fg as-is, nuke bg
			vim.api.nvim_set_hl(0, g, { fg = hl.fg, bg = "none" })
		else
			vim.api.nvim_set_hl(0, g, { bg = "none" })
		end
	end
end

transparent()
fix_telescope()
transparent_signs()

vim.api.nvim_create_autocmd("ColorScheme", { callback = transparent })
vim.api.nvim_create_autocmd("ColorScheme", { callback = fix_telescope })
vim.api.nvim_create_autocmd("ColorScheme", { callback = transparent_signs })
