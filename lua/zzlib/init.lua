-- lua/zzlib/init.lua
-- fast gzip decompressor using system zlib via LuaJIT FFI
-- API: zzlib.gunzip(str) -> decompressed string

local M = {}

-- Try to load zlib from common names on macOS/Linux/Windows
local function load_zlib(ffi)
	local tried = {}
	for _, name in ipairs { "z", "zlib", "zlib1", "libz" } do
		local ok, lib = pcall(ffi.load, name)
		if ok then
			return lib
		end
		tried[#tried + 1] = name
	end
	error("zzlib: failed to load system zlib (tried: " .. table.concat(tried, ", ") .. ")")
end

local function ensure_ffi()
	local ok, ffi = pcall(require, "ffi")
	if not ok then
		error "zzlib: LuaJIT FFI required"
	end
	return ffi
end

-- one-time FFI setup
local ffi, C = (function()
	local ffi = ensure_ffi()
	ffi.cdef [[
    typedef struct {
      const unsigned char *next_in;
      unsigned int avail_in;
      unsigned long total_in;

      unsigned char *next_out;
      unsigned int avail_out;
      unsigned long total_out;

      const char *msg;
      void *state;

      void *zalloc;
      void *zfree;
      void *opaque;

      int data_type;
      unsigned long adler;
      unsigned long reserved;
    } z_stream;

    const char * zlibVersion(void);
    int inflateInit2_(z_stream *strm, int windowBits, const char *version, int stream_size);
    int inflate(z_stream *strm, int flush);
    int inflateEnd(z_stream *strm);
  ]]
	local z = load_zlib(ffi)
	return ffi, z
end)()

-- zlib constants
local Z_OK = 0
local Z_STREAM_END = 1
local Z_NEED_DICT = 2
local Z_BUF_ERROR = -5

-- windowBits:
-- 15+32 = auto-detect zlib or gzip header, accept both (robust)
-- 15+16 = gzip only
local WINDOWBITS_AUTO = 15 + 32

---@param data string  -- gzip (or zlib) compressed bytes
---@return string      -- decompressed text/binary
function M.gunzip(data)
	assert(type(data) == "string", "zzlib.gunzip: data must be a string")

	local zs = ffi.new "z_stream[1]"
	zs[0].zalloc, zs[0].zfree, zs[0].opaque = nil, nil, nil
	zs[0].next_in = ffi.cast("const unsigned char *", data)
	zs[0].avail_in = #data

	local ver = C.zlibVersion()
	local rc = C.inflateInit2_(zs, WINDOWBITS_AUTO, ver, ffi.sizeof "z_stream")
	if rc ~= Z_OK then
		error(("zzlib: inflateInit2_ failed (%d)"):format(rc))
	end

	local chunks = {}
	local CHUNK = 262144 -- 256 KiB
	while true do
		local outbuf = ffi.new("unsigned char[?]", CHUNK)
		zs[0].next_out = outbuf
		zs[0].avail_out = CHUNK

		rc = C.inflate(zs, 0) -- Z_NO_FLUSH
		local produced = CHUNK - zs[0].avail_out
		if produced > 0 then
			chunks[#chunks + 1] = ffi.string(outbuf, produced)
		end

		if rc == Z_STREAM_END then
			break
		elseif rc == Z_OK or rc == Z_NEED_DICT or rc == Z_BUF_ERROR then
			-- Z_OK: continue
			-- Z_BUF_ERROR can occur if outbuf filled exactly; loop continues
			if zs[0].avail_in == 0 and produced == 0 then
				-- no progress; treat as error
				C.inflateEnd(zs)
				error "zzlib: inflate made no progress (corrupt or truncated stream)"
			end
		else
			local msg = zs[0].msg ~= nil and ffi.string(zs[0].msg) or ("code " .. rc)
			C.inflateEnd(zs)
			error("zzlib: inflate failed: " .. msg)
		end
	end

	C.inflateEnd(zs)
	return table.concat(chunks)
end

return M
