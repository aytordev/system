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

-- Resolve the persisted override, falling back to the declarative selection.
function M.init()
	if M.current then
		return
	end

	local persisted = read_persisted()
	if is_known(persisted) then
		M.current = persisted
		log.info("loaded persisted theme: %s", persisted)
	else
		if persisted ~= nil then
			log.warn("ignoring unknown persisted theme: %s", tostring(persisted))
		end
		M.current = is_known(M.active) and M.active or M.list()[1]
		log.info("using declarative theme: %s", M.current)
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

	local f, err = io.open(PERSIST_FILE, "w")
	if not f then
		log.error("cannot persist theme '%s': %s", name, tostring(err))
		return false
	end
	f:write(name)
	f:close()

	M.current = name
	sbar.exec("sketchybar --reload")
	log.info("applied theme: %s", name)
	return true
end

-- Drop the persisted override so the declarative Nix selection wins again.
function M.follow_nix()
	os.remove(PERSIST_FILE)
	M.current = is_known(M.active) and M.active or M.list()[1]
	sbar.exec("sketchybar --reload")
	log.info("following declarative theme: %s", M.current)
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
