local settings = require("settings")
local helpers = require("helpers.init")

local safe_require = helpers.safe_require

print("🔄 Loading calendar...")
if not safe_require("items.right.calendar") then
    print("⚠️  Could not load calendar.lua")
end


