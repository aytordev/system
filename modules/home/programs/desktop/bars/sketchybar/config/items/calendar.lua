-- Stacked date/time display
-- Time on top, date on bottom (two-line layout).
local colors = require("colors")
local settings = require("settings")

local base_size = settings.font.size

-- Time (top line, stacked)
local cal_time = sbar.add("item", "calendar.time", {
	position = "right",
	width = 0,
	padding_left = 0,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = base_size * 0.85,
		},
		padding_left = settings.paddings,
		padding_right = 0,
		align = "right",
	},
	y_offset = 6,
})

-- Date (bottom line, provides width)
local cal_date = sbar.add("item", "calendar.date", {
	position = "right",
	padding_left = 0,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = base_size * 0.70,
		},
		color = colors.accent_bright,
		padding_left = settings.paddings,
		padding_right = 0,
		align = "right",
	},
	y_offset = -6,
	background = { drawing = false },
	update_freq = 30,
})

local function update_calendar()
	cal_time:set({ label = { string = os.date("%H:%M") } })
	cal_date:set({ label = { string = string.upper(os.date("%a %b %d")) } })
end

cal_date:subscribe({ "forced", "routine", "system_woke" }, update_calendar)

local function on_click()
	sbar.exec("open -a Calendar")
end

cal_time:subscribe("mouse.clicked", on_click)
cal_date:subscribe("mouse.clicked", on_click)

update_calendar()
