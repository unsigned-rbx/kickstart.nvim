-- cmp_sources/fusion_blink.lua
-- Blink-native source for Roblox Fusion-style completion

local curl_ok, curl = pcall(require, "plenary.curl")
local source = {}

local API_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json"

-- state
local classes = {}
local api_loaded = false

-- lazy require to avoid loading-order issues
local function kinds()
	local ok, types = pcall(require, "blink.cmp.types")
	if not ok then
		return nil
	end
	return types.CompletionItemKind
end

local function notify(msg, level)
	vim.schedule(function()
		vim.notify("[fusion_blink] " .. msg, level or vim.log.levels.WARN)
	end)
end

-- fetch & parse
local function fetch_api()
	if not curl_ok then
		return nil
	end
	local ok, res = pcall(curl.get, API_URL, { accept = "application/json", timeout = 5000 })
	if not ok or not res or res.status ~= 200 or not res.body then
		return nil
	end
	local ok2, decoded = pcall(vim.json.decode, res.body)
	if not ok2 then
		return nil
	end
	return decoded
end

local function populate_classes(map)
	if not map or not map.Classes then
		return
	end
	for _, data in ipairs(map.Classes) do
		local name = data.Name
		if name then
			local members = {}
			for _, m in ipairs(data.Members or {}) do
				if m.MemberType == "Property" and m.Name then
					members[m.Name] = { ValueType = m.ValueType }
				end
			end
			classes[name] = { Members = members, Superclass = data.Superclass }
		end
	end
end

local function inherit_members(super, acc)
	local sup = classes[super]
	if not sup then
		return
	end
	for k, v in pairs(sup.Members or {}) do
		acc[k] = acc[k] or v
	end
	if sup.Superclass then
		inherit_members(sup.Superclass, acc)
	end
end

local function ensure_api_loaded()
	if api_loaded then
		return true
	end
	local map = fetch_api()
	if not map then
		notify("Could not fetch Roblox API dump; source will stay empty.", vim.log.levels.INFO)
		api_loaded = true
		return true
	end
	populate_classes(map)
	for _, data in pairs(classes) do
		if data.Superclass then
			inherit_members(data.Superclass, data.Members)
		end
	end
	api_loaded = true
	return true
end

-- cursor helpers
local function has_scope_new_before_cursor()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = (vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or "")
	return line:sub(1, col):match "scope:New%s*['\"]" ~= nil
end

local function get_current_instance()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)
	local stack = {}
	for lineno, line in ipairs(lines) do
		local inst = line:match "scope:New%s*['\"]([^'\"]+)['\"]"
		if inst then
			table.insert(stack, { instance = inst, brace = 0, opened = lineno })
		end
		if #stack > 0 then
			local top = stack[#stack]
			local opens = select(2, line:gsub("{", ""))
			local closes = select(2, line:gsub("}", ""))
			top.brace = top.brace + opens - closes
			if lineno == top.opened and opens > 0 and closes > 0 then
				local ob = line:find "{"
				local cb = ob and line:find("}", ob + 1) or nil
				if ob and cb then
					if lineno == row and (col - 1) > ob and (col - 1) < cb then
						top.brace = 1
					else
						top.brace = 0
					end
				end
			end
			if top.brace <= 0 then
				table.remove(stack)
			end
		end
	end
	return (#stack > 0) and stack[#stack].instance or nil
end

-- snippet mapping
local mapped = {
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

-- blink API
function source.new(opts)
	local self = setmetatable({}, { __index = source })
	self.opts = opts or {}
	return self
end

function source:enabled()
	local ft = vim.bo.filetype
	return ft == "lua" or ft == "luau"
end

function source:get_trigger_characters()
	return { ".", ":", "{", "=", '"', "'" }
end

function source:get_completions(ctx, cb)
	local ok = pcall(ensure_api_loaded)
	if not ok then
		return cb { items = {} }
	end

	local K = kinds()
	if not K then
		return cb { items = {} }
	end

	local items = {}

	if has_scope_new_before_cursor() then
		for class, data in pairs(classes) do
			local names = {}
			for prop, _ in pairs(data.Members) do
				table.insert(names, prop)
			end
			table.insert(items, {
				label = class,
				kind = K.Class,
				documentation = { kind = "plaintext", value = "Members: " .. table.concat(names, ", ") },
				sortText = "a" .. class,
			})
		end
		return cb { items = items }
	end

	local inst = get_current_instance()
	local entry = inst and classes[inst] or nil
	if not entry then
		return cb { items = {} }
	end

	for prop, m in pairs(entry.Members or {}) do
		local vt = m.ValueType or {}
		local tname = vt.Name or "any"
		local snippet = mapped[tname] or tname
		table.insert(items, {
			label = prop,
			kind = K.Property,
			insertText = ("%s = %s"):format(prop, snippet),
			insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
			documentation = { kind = "plaintext", value = ("%s :: %s"):format(tname, vt.Category or "") },
			sortText = "a" .. prop,
		})
	end

	cb { items = items }
end

return source
