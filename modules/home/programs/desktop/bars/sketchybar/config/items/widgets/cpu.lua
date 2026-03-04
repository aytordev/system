local icons = require("icons")
local colors = require("colors")
local settings = require("settings")


-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")

local cpu = sbar.add("item", "widgets.cpu", {
	position = "left",
	background = { drawing = false },
	icon = {
		string = icons.cpu,
		font = { size = settings.font_icon.size * 2 },
	},
	label = {
		string = "??%",
	},
})

cpu:subscribe("cpu_update", function(env)
	-- Also available: env.user_load, env.sys_load
	local load = tonumber(env.total_load)

	local color = colors.blue
	if load > 30 then
		if load < 60 then
			color = colors.yellow
		elseif load < 80 then
			color = colors.orange
		else
			color = colors.red
		end
	end

	cpu:set({
		label = {
			string = load .. "%",
			color = color,
		},
		icon = { color = color },
	})
end)

cpu:subscribe("mouse.clicked", function()
	sbar.exec("open -a 'Activity Monitor'")
end)

-- Bracket grouping is handled by the unified resources.bracket in init.lua
