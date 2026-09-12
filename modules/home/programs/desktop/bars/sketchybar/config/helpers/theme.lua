-- Runtime theme switching manager (sketchybar only)
-- Reads every family/variant palette from nix_constants.themes and allows
-- switching at runtime without a Nix rebuild. Other applications re-read their
-- theme on restart; only sketchybar hot-reloads through this module.
local constants = require("nix_constants")
local log = require("helpers.log").new("theme")

local M = {}

local PERSIST_FILE = os.getenv("HOME") .. "/.config/sketchybar/.theme_variant"

-- All available themes from Nix, keyed "<family>/<variant>".
M.themes = constants.themes or {}
-- Declarative selection from Nix.
M.active = constants.active_theme or ""
-- Effective selection (persisted override or declarative).
M.current = nil

local function is_known(name)
	return name ~= nil and M.themes[name] ~= nil
end

local function read_persisted()
	local f = io.open(PERSIST_FILE, "r")
	if not f then
		return nil
	end
	local name = f:read("*l")
	f:close()
	return name
end

-- Persist the override. Returns false (and reports) on any I/O failure so the
-- caller never turns a failed write into a successful switch.
local function write_persisted(name)
	local f, open_err = io.open(PERSIST_FILE, "w")
	if not f then
		log.error("cannot open theme override for writing: %s", tostring(open_err))
		return false
	end

	local written, write_err = f:write(name)
	if not written then
		f:close()
		log.error("cannot write theme override '%s': %s", name, tostring(write_err))
		return false
	end

	local closed, close_err = f:close()
	if not closed then
		log.error("cannot close theme override after writing '%s': %s", name, tostring(close_err))
		return false
	end

	return true
end

-- Drop the persisted override. An already-absent file is the desired end
-- state, so only a file that still exists after a failed remove is an error.
local function clear_persisted()
	local removed, remove_err = os.remove(PERSIST_FILE)
	if removed then
		return true
	end

	local f = io.open(PERSIST_FILE, "r")
	if f then
		f:close()
		log.error("cannot remove theme override: %s", tostring(remove_err))
		return false
	end

	return true
end

-- Resolve the persisted override, falling back to the declarative selection.
function M.init()
	if M.current then
		return
	end

	local persisted = read_persisted()
	if is_known(persisted) then
		M.current = persisted
		log.info("loaded persisted theme: %s", tostring(persisted))
	else
		if persisted ~= nil then
			log.warn("ignoring unknown persisted theme: %s", tostring(persisted))
		end
		M.current = is_known(M.active) and M.active or M.list()[1]
		log.info("using declarative theme: %s", tostring(M.current))
	end
end

-- Get current palette (same shape as colors table)
function M.palette()
	if not M.current then
		M.init()
	end
	return M.themes[M.current] or M.themes[M.active] or constants.colors
end

-- Switch to a different theme and reload. Returns false if the name is unknown
-- or the choice could not be persisted, so callers never report a false success.
function M.apply(name)
	if not is_known(name) then
		log.error("unknown theme: %s", tostring(name))
		return false
	end

	if not write_persisted(name) then
		return false
	end

	M.current = name
	sbar.exec("sketchybar --reload")
	log.info("applied theme: %s", name)
	return true
end

-- Drop the persisted override so the declarative Nix selection wins again.
function M.follow_nix()
	if not clear_persisted() then
		return false
	end

	M.current = is_known(M.active) and M.active or M.list()[1]
	sbar.exec("sketchybar --reload")
	log.info("following declarative theme: %s", tostring(M.current))
	return true
end

-- Whether the declarative selection is currently in effect.
function M.is_following_nix()
	return not is_known(read_persisted())
end

-- List available theme names (sorted)
function M.list()
	local names = {}
	for k, _ in pairs(M.themes) do
		table.insert(names, k)
	end
	table.sort(names)
	return names
end

return M
