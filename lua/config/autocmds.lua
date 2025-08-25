local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local general = augroup("General", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#FF6363", bg = "#4B252C", bold = true })
		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#FA973A", bg = "#403733", bold = true })
		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#5B38E8", bg = "#281478", bold = true })
		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#25E64B", bg = "#147828", bold = true })
	end,
})
