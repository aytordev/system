--- aerospace module for sending commands to the AeroSpace window manager server
-- @module Aerospace
-- @copyright 2025
-- @license MIT

local socket = require("posix.sys.socket")
local unistd = require("posix.unistd")
local fcntl = require("posix.fcntl")
local poll = require("posix.poll")
local cjson = require("cjson")
local log = require("helpers.log").new("aerospace")

-- FD_CLOEXEC explanation:
-- When a process spawns a child (via fork+exec), the child inherits all open
-- file descriptors (FDs) from the parent by default. This includes sockets.
--
-- Problem: If the parent has an open socket to AeroSpace (e.g., FD 5), and then
-- spawns cpu_load/network_load via sbar.exec(), those children also get FD 5.
-- Multiple processes sharing one socket connection causes corruption:
-- - Parent sends a request, but child accidentally reads the response
-- - Socket stream gets out of sync, parent blocks forever waiting for data
--
-- Solution: Set FD_CLOEXEC flag on the socket. This tells the OS to
-- automatically close this FD in child processes after exec().
-- The parent keeps the socket, children don't inherit it.
local function set_cloexec(fd)
	local flags = fcntl.fcntl(fd, fcntl.F_GETFD)
	if flags then
		fcntl.fcntl(fd, fcntl.F_SETFD, flags | fcntl.FD_CLOEXEC)
		log.debug("set FD_CLOEXEC on fd=%d", fd)
	else
		log.warn("failed to get FD flags for fd=%d", fd)
	end
end

-- Try to load simdjson (optional, faster JSON parser)
local simdjson_ok, simdjson = pcall(require, "simdjson")
local use_simd = simdjson_ok

local DEFAULT = {
	SOCK_FMT = "/tmp/bobko.aerospace-%s.sock",
	MAX_BUF = 2048,
	EXT_BUF = 4096,
	TIMEOUT_MS = 5000, -- 5 second timeout for socket operations
	PROTO_VERSION = 1, -- AeroSpace socket protocol version (UInt32 LE handshake)
}

-- Timeout explanation:
-- Without a timeout, read() blocks forever if no data arrives. This can happen if:
-- - AeroSpace is unresponsive or crashed
-- - The socket connection is in a bad state
-- - A previous bug caused socket corruption
--
-- Solution: Use poll() to check if data is available before reading.
-- poll() returns immediately if data is ready, or after timeout_ms if not.
-- This prevents the entire sketchybar lua event loop from freezing.
local function wait_for_data(fd, timeout_ms)
	-- poll() returns: >0 if data ready, 0 if timeout, -1 if error
	local result = poll.rpoll(fd, timeout_ms)
	return result and result > 0
end
local ERR = {
	SOCKET = "socket error",
	NOT_INIT = "socket not connected",
	JSON = "failed to decode JSON",
}

local AF_UNIX, SOCK_STREAM = socket.AF_UNIX, socket.SOCK_STREAM
local write, read, close = unistd.write, unistd.read, unistd.close
local encode = cjson.encode
local pack = string.pack
local unpack = string.unpack

-- Write the whole buffer, handling partial writes on the Unix socket.
local function write_all(fd, data)
	local total = 1
	local len = #data
	while total <= len do
		local written = write(fd, data:sub(total))
		if not written or written <= 0 then
			error("socket write failed")
		end
		total = total + written
	end
end

-- Read exactly n bytes, blocking (with a timeout) until they arrive.
local function read_exact(fd, n)
	local chunks = {}
	local remaining = n
	while remaining > 0 do
		if not wait_for_data(fd, DEFAULT.TIMEOUT_MS) then
			error("timeout waiting for socket data")
		end
		local chunk = read(fd, remaining)
		if not chunk or #chunk == 0 then
			error("socket closed while reading")
		end
		table.insert(chunks, chunk)
		remaining = remaining - #chunk
	end
	return table.concat(chunks)
end

-- Read a little-endian UInt32 (AeroSpace frames every message this way).
local function read_u32(fd)
	return (unpack("<I4", read_exact(fd, 4)))
end

local function decode(str)
	if use_simd then
		local ok, val = pcall(simdjson.parse, str)
		if ok then
			return val
		end
		use_simd = false
	end
	local ok, val = pcall(cjson.decode, str)
	if not ok then
		error(ERR.JSON .. ": " .. tostring(val))
	end
	return val
end

local function connect(path)
	log.info("connecting to socket: %s", path)
	local fd, err = socket.socket(AF_UNIX, SOCK_STREAM, 0)
	if not fd then
		log.error("socket creation failed: %s", tostring(err))
		error(ERR.SOCKET .. ": " .. tostring(err))
	end

	-- Prevent child processes from inheriting this socket (see FD_CLOEXEC explanation above)
	set_cloexec(fd)

	if socket.connect(fd, { family = AF_UNIX, path = path }) ~= 0 then
		log.error("socket connect failed: %s", path)
		close(fd)
		error("cannot connect to " .. path)
	end

	-- Protocol handshake: AeroSpace exchanges a little-endian UInt32 protocol
	-- version before any request. Without it the server replies with its version
	-- and closes, which surfaced as "empty response" errors.
	local ok, handshake_err = pcall(function()
		write_all(fd, pack("<I4", DEFAULT.PROTO_VERSION))
		local server_version = read_u32(fd)
		if server_version ~= DEFAULT.PROTO_VERSION then
			error(
				string.format(
					"unsupported AeroSpace socket protocol version %d (expected %d)",
					server_version,
					DEFAULT.PROTO_VERSION
				)
			)
		end
	end)
	if not ok then
		close(fd)
		error("AeroSpace handshake failed: " .. tostring(handshake_err))
	end

	log.info("connected successfully, fd=%d (protocol v%d)", fd, DEFAULT.PROTO_VERSION)
	return fd
end

local function stdout(raw)
	-- Handle empty or whitespace-only responses
	if not raw or raw == "" or raw:match("^%s*$") then
		return ""
	end

	if use_simd then
		local ok, doc = pcall(simdjson.open, raw)
		if ok then
			local stdout_ok, stdout_val = pcall(function()
				return doc:atPointer("/stdout")
			end)
			if stdout_ok then
				return stdout_val or ""
			end
		end
		use_simd = false
	end
	-- Fallback: parse JSON manually to extract stdout field
	local ok, json = pcall(cjson.decode, raw)
	if not ok then
		-- JSON parse failed, return empty string instead of crashing
		return ""
	end
	return json.stdout or ""
end

local Aerospace = {}
Aerospace.__index = Aerospace

function Aerospace.new(path)
	if not path then
		local username = io.popen("id -un"):read("*l")
		path = DEFAULT.SOCK_FMT:format(username)
	end

	return setmetatable({ sockPath = path, fd = connect(path) }, Aerospace)
end

function Aerospace:close()
	if self.fd then
		log.info("closing socket fd=%d", self.fd)
		close(self.fd)
		self.fd = nil
	end
end

Aerospace.__gc = Aerospace.close

function Aerospace:reconnect()
	log.warn("reconnecting to aerospace socket")
	self:close()
	self.fd = connect(self.sockPath)
end

function Aerospace:is_initialized()
	return self.fd ~= nil
end

local PAYLOAD_TMPL = '{"args":%s,"stdin":"","windowId":null,"workspace":null}'
function Aerospace:_query(args, want_json, _big)
	if not self:is_initialized() then
		log.error("query attempted but socket not initialized")
		error(ERR.NOT_INIT)
	end

	local cmd_name = args[1] or "unknown"
	local start_time = os.clock()
	local payload = PAYLOAD_TMPL:format(encode(args))
	local raw = ""

	log.debug("query start: %s (fd=%d)", cmd_name, self.fd)
	-- Request/response are framed as UInt32 little-endian length + JSON body.
	local ok, query_err = pcall(function()
		write_all(self.fd, pack("<I4", #payload) .. payload)
		local length = read_u32(self.fd)
		raw = length == 0 and "" or read_exact(self.fd, length)
	end)
	local elapsed_ms = (os.clock() - start_time) * 1000

	if not ok then
		log.error("query failed: %s: %s", cmd_name, tostring(query_err))
		-- The persistent socket may be in a bad state; reconnect for next time.
		pcall(function()
			self:reconnect()
		end)
		return want_json and {} or ""
	end

	log.socket("query_complete", self.fd, #raw, elapsed_ms)
	if elapsed_ms > 500 then
		log.warn("SLOW QUERY: %s took %.2fms, %d bytes", cmd_name, elapsed_ms, #raw)
	end

	if raw == "" or raw:match("^%s*$") then
		log.warn("empty response for: %s", cmd_name)
		return want_json and {} or ""
	end

	local out = stdout(raw)
	return want_json and decode(out) or out
end

local function passthrough(self, argtbl, json, big, cb)
	local res = self:_query(argtbl, json, big)
	return cb and cb(res) or res
end

function Aerospace:list_apps(cb)
	return passthrough(self, { "list-apps", "--json" }, true, nil, cb)
end

function Aerospace:query_workspaces(cb)
	return passthrough(self, {
		"list-workspaces",
		"--all",
		"--format",
		"%{workspace-is-focused}%{workspace-is-visible}%{workspace}%{monitor-appkit-nsscreen-screens-id}%{monitor-name}",
		"--json",
	}, true, true, cb)
end

function Aerospace:list_current(cb)
	return passthrough(self, { "list-workspaces", "--focused" }, false, nil, cb)
end

function Aerospace:list_windows(space, cb)
	return passthrough(self, { "list-windows", "--workspace", space, "--json" }, false, nil, cb)
end

function Aerospace:focused_window(cb)
	return passthrough(self, { "list-windows", "--focused", "--json" }, false, nil, cb)
end

function Aerospace:workspace(ws)
	return self:_query({ "workspace", ws }, false)
end

function Aerospace:list_all_windows(cb)
	return passthrough(self, {
		"list-windows",
		"--all",
		"--json",
		"--format",
		"%{window-id}%{app-name}%{window-title}%{workspace}",
	}, true, true, cb)
end

function Aerospace:list_modes(current_only, cb)
	local args = current_only and { "list-modes", "--current" } or { "list-modes" }
	return passthrough(self, args, false, nil, cb)
end

function Aerospace:list_monitors(cb)
	return passthrough(self, { "list-monitors" }, false, nil, cb)
end

return Aerospace
