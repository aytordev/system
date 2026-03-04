-- Clock display — single item with icon + time label
local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local clock = sbar.add("item", "calendar.time", {
	position = "right",
	update_freq = 1,
	background = { drawing = false },
	icon = {
		string = icons.clock,
		color = colors.blue,
		font = { size = settings.font_icon.size * 2 },
	},
	label = {
		color = colors.white,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Semibold"],
			size = settings.font.size,
		},
		padding_left = 8,
		padding_right = 12,
	},
})

local function ordinal(d)
	if d == 11 or d == 12 or d == 13 then return d .. "th" end
	local last = d % 10
	if last == 1 then return d .. "st"
	elseif last == 2 then return d .. "nd"
	elseif last == 3 then return d .. "rd"
	else return d .. "th" end
end

clock:subscribe({ "routine", "forced", "system_woke" }, function()
	local day = tonumber(os.date("%d"))
	clock:set({ label = { string = ordinal(day) .. " of " .. os.date("%b %H:%M:%S") } })
end)

clock:subscribe("mouse.clicked", function()
	sbar.exec("open -a Calendar")
end)
