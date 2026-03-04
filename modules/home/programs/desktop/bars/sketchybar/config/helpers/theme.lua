-- Runtime theme switching manager
-- Reads all variant palettes from nix_constants.themes and allows
-- switching between them at runtime without a Nix rebuild.
local constants = require("nix_constants")
local log = require("helpers.log").new("theme")

local M = {}

local PERSIST_FILE = os.getenv("HOME") .. "/.config/sketchybar/.theme_variant"

-- All available themes from Nix
M.variants = constants.themes or {}
M.current = nil

-- Read persisted variant or fall back to Nix default
function M.init()
	if M.current then
		return -- Already initialized
	end

	local f = io.open(PERSIST_FILE, "r")
	if f then
		local variant = f:read("*l")
		f:close()
		if variant and M.variants[variant] then
			M.current = variant
			log.info("loaded persisted theme: %s", variant)
			return
		end
	end

	M.current = constants.active_variant or "wave"
	log.info("using default theme: %s", M.current)
end

-- Get current palette (same shape as colors table)
function M.palette()
	if not M.current then
		M.init()
	end
	return M.variants[M.current] or M.variants[constants.active_variant] or constants.colors
end

-- Switch to a different variant and reload
function M.apply(variant_name)
	if not M.variants[variant_name] then
		log.error("unknown theme variant: %s", variant_name)
		return false
	end

	M.current = variant_name

	-- Persist choice
	local f = io.open(PERSIST_FILE, "w")
	if f then
		f:write(variant_name)
		f:close()
	end

	-- Trigger full bar reload to apply new colors
	sbar.exec("sketchybar --reload")
	log.info("applied theme: %s", variant_name)
	return true
end

-- List available variant names (sorted)
function M.list()
	local names = {}
	for k, _ in pairs(M.variants) do
		table.insert(names, k)
	end
	table.sort(names)
	return names
end

return M
