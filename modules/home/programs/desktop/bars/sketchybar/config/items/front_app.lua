-- Frontmost application display
-- Shows the current app icon and name on the left side.
local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local front_app = sbar.add("item", "front_app", {
	position = "left",
	icon = {
		font = "sketchybar-app-font:Regular:16.0",
		color = colors.white,
		padding_left = 8,
		padding_right = 4,
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Semibold"],
			size = 13.0,
		},
		color = colors.white,
		padding_right = 8,
	},
	background = { drawing = false },
})

front_app:subscribe("front_app_switched", function(env)
	local app_name = env.INFO
	local app_icon = app_icons[app_name] or app_icons["Default"]
	front_app:set({
		icon = { string = app_icon },
		label = { string = app_name },
	})
end)

-- Curtain effect support: fade out when menus expand
front_app:subscribe("fade_out_spaces", function()
	sbar.animate("tanh", 30, function()
		front_app:set({
			width = 0,
			icon = { color = colors.transparent },
			label = { color = colors.transparent },
		})
	end)
end)

front_app:subscribe("fade_in_spaces", function()
	-- Instant reset to zero state
	front_app:set({
		width = 0,
		icon = { color = colors.transparent },
		label = { color = colors.transparent },
	})
	-- Then animate expansion
	sbar.animate("tanh", 30, function()
		front_app:set({
			width = "dynamic",
			icon = { color = colors.white },
			label = { color = colors.white },
		})
	end)
end)
