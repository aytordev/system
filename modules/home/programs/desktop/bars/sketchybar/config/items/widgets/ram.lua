local colors = require("colors")


local ram = sbar.add("item", "widgets.ram", {
	position = "left",
	update_freq = 2,
	icon = {
		string = "􀫦",
	},
	label = {
		string = "??%",
	},
})

ram:subscribe({ "routine", "forced" }, function()
	sbar.exec("memory_pressure", function(output)
		-- Parse memory pressure output to calculate RAM usage
		local pages_free = output:match("Pages free:%s+(%d+)")
		local pages_active = output:match("Pages active:%s+(%d+)")
		local pages_inactive = output:match("Pages inactive:%s+(%d+)")
		local pages_speculative = output:match("Pages speculative:%s+(%d+)")
		local pages_wired = output:match("Pages wired down:%s+(%d+)")
		local pages_occupied = output:match("Pages occupied by compressor:%s+(%d+)")

		if pages_free and pages_active and pages_inactive and pages_wired then
			pages_free = tonumber(pages_free)
			pages_active = tonumber(pages_active)
			pages_inactive = tonumber(pages_inactive)
			pages_speculative = tonumber(pages_speculative or 0)
			pages_wired = tonumber(pages_wired)
			pages_occupied = tonumber(pages_occupied or 0)

			local total_pages = pages_free
				+ pages_active
				+ pages_inactive
				+ pages_speculative
				+ pages_wired
				+ pages_occupied
			local used_pages = pages_active + pages_wired + pages_occupied
			local usage_percent = math.floor((used_pages / total_pages) * 100)

			local color = colors.blue
			if usage_percent > 60 then
				color = colors.yellow
			end
			if usage_percent > 80 then
				color = colors.orange
			end
			if usage_percent > 90 then
				color = colors.red
			end

			ram:set({
				label = {
					string = usage_percent .. "%",
					color = color,
				},
				icon = { color = color },
			})
		end
	end)
end)

ram:subscribe("mouse.clicked", function()
	sbar.exec("open -a 'Activity Monitor'")
end)

-- Bracket grouping is handled by the unified resources.bracket in init.lua
