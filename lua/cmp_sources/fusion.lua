local cmp = require "cmp"
local curl = require "plenary.curl"

local apiPath = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json" --'https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/api-docs/en-us.json'
--
local source = {}

local classes = {}
local classes_loaded = false
local loading_in_progress = false

local function getMappedApi()
	local res = curl.get(apiPath, {
		accept = "application/json",
		timeout = 5000,
	})

	if res.status == 200 then
		local data = vim.json.decode(res.body)
		print "successfully retrieved data"
		return data
	end
end

local function populateClasses(mappedApi)
	for key, classesList in pairs(mappedApi) do
		if key == "Classes" then
			for _, data in ipairs(classesList) do
				local name = data.Name
				if name then
					local members = {}
					for index, memberData in ipairs(data.Members or {}) do
						if memberData.MemberType == "Property" then
							members[memberData.Name] = {
								ValueType = memberData.ValueType,
							}
						end
					end

					classes[name] = {
						Members = members,
						Superclass = data.Superclass,
					}
				end
			end
		end
	end
end

local function getMembersFromSuperclass(superclassName)
	local members = {}

	local entry = classes[superclassName]
	if not entry then
		return members
	end

	if entry.Members then
		for key, value in pairs(entry.Members) do
			members[key] = value
		end
	end

	if entry.Superclass then
		local temp_members = getMembersFromSuperclass(entry.Superclass)

		for key, value in pairs(temp_members) do
			members[key] = value
		end
	end

	return members
end

local function load_classes_async()
	if classes_loaded or loading_in_progress then
		return
	end

	loading_in_progress = true

	-- Run in background using vim.schedule to not block
	vim.schedule(function()
		local mappedApi = getMappedApi()
		if mappedApi then
			populateClasses(mappedApi)
			for _, data in pairs(classes) do
				if data.Superclass then
					local temp_members = getMembersFromSuperclass(data.Superclass)
					for key, value in pairs(temp_members) do
						data.Members[key] = value
					end
				end
			end
			classes_loaded = true
			print "Fusion API data loaded"
		else
			print "Failed to load Fusion API data"
		end
		loading_in_progress = false
	end)
end

function source:new()
	local o = setmetatable({}, { __index = self })

	-- Start loading in background, but don't wait for it
	load_classes_async()

	return o
end

local function has_scope_new_before_cursor()
	-- Get the current cursor position.
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	-- row is 1-based; fetch exactly one line: the current line (row-1 in 0-based).
	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

	-- Only consider text up to the cursor.
	local text_before_cursor = line:sub(1, col)

	-- Check for `scope:New "`, with optional whitespace:
	--   scope:New " or scope:New '
	local found = text_before_cursor:match "scope:New%s*['\"]"
	return (found ~= nil)
end

local function get_current_instance()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	-- Neovim lines are 0-indexed internally, but row from get_cursor is 1-based.
	-- We'll fetch all lines from line 0 up to (but not including) `row`.
	local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)

	local scope_stack = {}

	-- Loop through each line up to the current line
	for lineno, line in ipairs(lines) do
		-- Check if the line has something like: scope:New "Frame"
		local found_instance = line:match "scope:New%s*['\"]([^'\"]+)['\"]"
		if found_instance then
			-- We found a new scope. Push it onto our stack with brace_count=0.
			table.insert(scope_stack, {
				instance = found_instance,
				brace_count = 0,
				line_opened = lineno, -- track which line we opened on
			})
		end

		-- If we have any active scope, update its brace count for this line
		if #scope_stack > 0 then
			local top = scope_stack[#scope_stack]

			-- Count how many '{' and '}' are in this line
			local opens = select(2, line:gsub("{", ""))
			local closes = select(2, line:gsub("}", ""))
			top.brace_count = top.brace_count + opens - closes

			-- Check if this `scope:New "X"` was opened and closed on the same line
			if lineno == top.line_opened and opens > 0 and closes > 0 then
				-- We suspect a one-line scope: e.g., scope:New "Frame" { ... } all on line `lineno`.
				local open_brace_pos = line:find "{"
				local close_brace_pos = line:find("}", open_brace_pos + 1)
				if open_brace_pos and close_brace_pos then
					-- If the cursor is on this same line (lineno == row),
					-- check if col is between the braces.
					if lineno == row then
						-- Remember: `col` is 1-based column index in Neovim.
						-- `string.find` returns 1-based indices as well.
						if col - 1 > open_brace_pos and col - 1 < close_brace_pos then
							-- Cursor is between { and }, so let's pretend the scope is "still open"
							top.brace_count = 1
						else
							-- Cursor is not between the braces; effectively we closed it
							top.brace_count = 0
						end
					else
						-- If the cursor isn't even on this line, then we assume it's closed
						top.brace_count = 0
					end
				end
			end

			-- If the brace_count goes to zero (or negative), pop the scope
			if top.brace_count <= 0 then
				table.remove(scope_stack)
			end
		end
	end

	-- After processing all lines up to the current line:
	-- If there's still an open scope, return its instance name
	if #scope_stack > 0 then
		return scope_stack[#scope_stack].instance
	end

	return nil
end

local mappedAutocomplete = {
	CFrame = "CFrame.new(${1})",
	Color3 = "Color3.new(${1})",
	ColorSequence = "ColorSequence.new(${1})",
	ColorSequenceKeypoint = "ColorSequenceKeypoint.new(${1})",
	NumberRange = "NumberRange.new(${1})",
	NumberSequence = "NumberSequence.new(${1})",
	NumberSequenceKeypoint = "NumberSequenceKeypoint.new(${1})",
	PhysicalProperties = "PhysicalProperties.new(${1})",
	Ray = "Ray.new(${1})",
	Rect = "Rect.new(${1})",
	Region3 = "Region3.new(${1})",
	Region3int16 = "Region3int16.new(${1})",
	UDim = "UDim.new(${1})",
	UDim2 = "UDim2.fromScale(${1})",
	Vector2 = "Vector2.new(${1})",
	Vector2int16 = "Vector2int16.new(${1})",
	Vector3 = "Vector3.new(${1})",
	Vector3int16 = "Vector3int16.new(${1})",
	float = "",
	BrickColor = "BrickColor.random()${1}",
	bool = "true${1}",
}

function source:complete(request, callback)
	-- If classes aren't loaded yet, trigger loading and return empty results
	if not classes_loaded then
		load_classes_async()
		callback {}
		return
	end

	if has_scope_new_before_cursor() then
		local items = {}
		for key, data in pairs(classes) do
			local memberString = ""
			for propertyName, _ in pairs(data.Members) do
				memberString = memberString .. propertyName .. ", "
			end
			table.insert(items, {
				label = key,
				kind = cmp.lsp.CompletionItemKind.Property,
				documentation = "Fusion property for Frame: " .. key .. " members: " .. memberString,
			})
		end
		callback(items)
		return
	end

	local instanceName = get_current_instance()
	if instanceName then
		local data = classes[instanceName]
		if data then
			local items = {}
			for propertyName, memberData in pairs(data.Members) do
				local typeName = memberData.ValueType.Name
				local mappedAutoCompletion = mappedAutocomplete[typeName] or typeName
				table.insert(items, {
					label = propertyName,
					kind = cmp.lsp.CompletionItemKind.Property,
					insertText = propertyName .. " = " .. mappedAutoCompletion,
					insertTextFormat = cmp.lsp.InsertTextFormat.Snippet,
					documentation = memberData.ValueType.Name .. " :: " .. memberData.ValueType.Category,
				})
			end
			callback(items)
		end
	else
		callback {}
	end
end

-- Optional: display name for debugging
function source:get_debug_name()
	return "fusion_source"
end

return source
