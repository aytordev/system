local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Battery indicator — icon-only by default, label appears on hover or low battery
local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	update_freq = 180,
	background = { drawing = false },
	label = { drawing = false },
})

-- Time remaining popup item
local remaining_time = sbar.add("item", {
	position = "popup." .. battery.name,
	background = { drawing = false },
	icon = {
		string = "Time remaining:",
		align = "left",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = settings.font.size,
		},
		padding_left = 2,
	},
	label = {
		string = "00:00h",
		align = "right",
		padding_right = 4,
	},
})

-- Battery update function
local function battery_update()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon
		local label = "?"
		local found, _, charge = batt_info:find("(%d+)%%")

		if found then
			charge = tonumber(charge)
			label = charge .. "%"
		end

		local color = colors.white
		local charging, _, _ = batt_info:find("AC Power")
		local show_label = false

		if charging then
			icon = icons.battery.charging
		else
			if found and charge > 80 then
				icon = icons.battery._100
			elseif found and charge > 60 then
				icon = icons.battery._75
			elseif found and charge > 40 then
				icon = icons.battery._50
			elseif found and charge > 20 then
				icon = icons.battery._25
				color = colors.orange
				show_label = true
			else
				icon = icons.battery._0
				color = colors.red
				show_label = true
			end
		end

		local lead = ""
		if found and charge < 10 then
			lead = "0"
		end

		battery:set({
			icon = { string = icon, color = color },
			label = { string = lead .. label, color = color, drawing = show_label },
		})
	end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, battery_update)

-- Hover to show percentage
battery:subscribe("mouse.entered", function()
	battery:set({ label = { drawing = true } })
end)

battery:subscribe("mouse.exited", function()
	battery_update()
end)

battery:subscribe("mouse.exited.global", function()
	battery:set({ popup = { drawing = false } })
end)

-- Click handler for popup
battery:subscribe("mouse.clicked", function()
	local drawing = battery:query().popup.drawing
	battery:set({ popup = { drawing = "toggle" } })

	if drawing == "off" then
		sbar.exec("pmset -g batt", function(batt_info)
			local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
			local label = found and remaining .. "h" or "No estimate"
			remaining_time:set({ label = { string = label } })
		end)
	end
end)
