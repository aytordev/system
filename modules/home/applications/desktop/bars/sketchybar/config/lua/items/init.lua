local settings = require("settings")
local helpers = require("helpers.init")

local safe_require = helpers.safe_require

print("🔄 Loading left items...")
if not safe_require("items.left") then
    print("⚠️  Could not load left items")
end

print("🔄 Loading right items...")
if not safe_require("items.right") then
    print("⚠️  Could not load right items")
end

