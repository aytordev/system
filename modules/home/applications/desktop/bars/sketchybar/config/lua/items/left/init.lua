local settings = require("settings")
local helpers = require("helpers.init")

local safe_require = helpers.safe_require

print("🔄 Loading logo...")
if not safe_require("items.left.logo") then
    print("⚠️  Could not load logo.lua")
end

Sbar.add("item", "logo.padding.left", {
	position = "left",
	width = settings.group_paddings,
	icon = { drawing = false },
	label = { drawing = false },
	background = { drawing = false },
})

print("🔄 Loading aerospace...")
if not safe_require("items.left.aerospace") then
    print("⚠️  Could not load aerospace.lua")
end

Sbar.add("item", "space.padding.left", {
	position = "left",
	width = settings.group_paddings,
	icon = { drawing = false },
	label = { drawing = false },
	background = { drawing = false },
})




