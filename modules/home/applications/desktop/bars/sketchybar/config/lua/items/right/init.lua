local settings = require("settings")
local colors = require("colors")

require("items.right.calendar")

local battery = require("items.right.battery")
local volume = require("items.right.volume")
local wifi = require("items.right.wifi")

Sbar.add("bracket", "left.bracket.battery.volume.wifi", {
	battery.name,
	volume.name,
	wifi.name,
}, {
	background = { color = colors.theme.c2 },
})


