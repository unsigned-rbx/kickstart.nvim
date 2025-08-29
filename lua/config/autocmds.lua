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

-- vim.api.nvim_create_autocmd("LspAttach", {
-- })
--
--

autocmd("LspAttach", {
	group = general,
	callback = function(event)
		-- print("LspAttach triggered for buffer:", event.buf)
		local client = vim.lsp.get_client_by_id(event.data.client_id) -- Use client_id, not client
		if client and vim.api.nvim_buf_is_valid(event.buf) then
			-- print("Client:", client.name)
			local status, ws_diag = pcall(require, "workspace-diagnostics")
			if status and ws_diag.populate_workspace_diagnostics then
				ws_diag.populate_workspace_diagnostics(client, event.buf)
			else
				-- print "Failed to load workspace-diagnostics or function missing"
			end
		else
			-- print "Invalid client or buffer"
		end
	end,
})

-- autocmd("LspAttach", {
-- 	callback = function(event) end,
-- })
