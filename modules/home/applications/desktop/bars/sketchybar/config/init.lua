#!/usr/bin/env lua

local helpers = require("helpers.init")
local safe_require = helpers.safe_require

print("🔵 Starting sketchybar configuration...")
Sbar = safe_require("sketchybar")
if not Sbar then 
    print("❌ Failed to load sketchybar module")
    return 
end

Sbar.begin_config()
Sbar.hotload(true)

print("🔄 Loading modules...")
if not safe_require("bar") then
    print("⚠️  Could not load bar.lua")
end

if not safe_require("default") then
    print("⚠️  Could not load default.lua")
end

Sbar.end_config()
print("✅ Configuration loaded successfully")

Sbar.event_loop()