local settings = require("settings")
local helpers = require("helpers.init")

local safe_require = helpers.safe_require

print("🔄 Loading logo...")
if not safe_require("items.left.logo") then
    print("⚠️  Could not load logo.lua")
end


