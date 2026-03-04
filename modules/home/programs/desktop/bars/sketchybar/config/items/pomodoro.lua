-- Pomodoro timer item
-- Left-click: popup with duration presets + custom option.
-- Right-click: start default timer / stop if running.
-- Shows countdown in label when running.
local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local constants = require("nix_constants")

local popup_width = 100

local default_duration = 25
if constants.items and constants.items.pomodoro then
	default_duration = constants.items.pomodoro.default_duration or 25
end

-- Timer state
local remaining_seconds = 0
local is_running = false

local pomodoro = sbar.add("item", "pomodoro", {
	position = "right",
	update_freq = 0, -- Updated manually when running
	background = { drawing = false },
	icon = {
		string = icons.timer,
		color = colors.white,
		font = { size = settings.font_icon.size * 2 },
	},
	label = {
		drawing = false,
	},
	popup = {
		align = "center",
		height = 30,
		background = {
			color = colors.popup.bg,
			border_color = colors.popup.border,
			border_width = 1,
			corner_radius = 9,
		},
	},
})

local function format_time(seconds)
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", mins, secs)
end

local function stop_timer()
	is_running = false
	remaining_seconds = 0
	pomodoro:set({
		update_freq = 0,
		icon = { color = colors.white },
		label = { drawing = false },
	})
end

local function start_timer(minutes)
	remaining_seconds = minutes * 60
	is_running = true
	pomodoro:set({
		popup = { drawing = false },
		update_freq = 1,
		icon = { color = colors.green },
		label = {
			drawing = true,
			string = format_time(remaining_seconds),
			color = colors.green,
		},
	})
end

-- Timer tick
pomodoro:subscribe("routine", function()
	if not is_running then
		return
	end

	remaining_seconds = remaining_seconds - 1

	if remaining_seconds <= 0 then
		-- Timer complete
		stop_timer()
		pomodoro:set({ icon = { color = colors.red } })
		-- Play completion sound
		sbar.exec("afplay /System/Library/Sounds/Glass.aiff &")
		-- Flash icon back to normal after a few seconds
		sbar.animate("sin", 30, function()
			pomodoro:set({ icon = { color = colors.white } })
		end)
		return
	end

	-- Update display
	local color = colors.green
	if remaining_seconds <= 60 then
		color = colors.orange
	elseif remaining_seconds <= 300 then
		color = colors.yellow
	end

	pomodoro:set({
		label = {
			string = format_time(remaining_seconds),
			color = color,
		},
		icon = { color = color },
	})
end)

-- Popup with duration presets
local presets = { 5, 10, 25, 45 }
for _, minutes in ipairs(presets) do
	local item = sbar.add("item", "pomodoro.preset." .. minutes, {
		position = "popup.pomodoro",
		label = {
			string = minutes .. " min",
			width = popup_width,
			align = "center",
			font = {
				family = settings.font.text,
				style = settings.font.style_map["Regular"],
				size = settings.font.size,
			},
			color = colors.white,
		},
		icon = {
			string = icons.timer,
			color = minutes == default_duration and colors.accent or colors.grey,
		},
	})

	item:subscribe("mouse.clicked", function()
		start_timer(minutes)
	end)

	item:subscribe("mouse.entered", function()
		item:set({ background = { drawing = true, color = 0x33ffffff } })
	end)

	item:subscribe("mouse.exited", function()
		item:set({ background = { drawing = false } })
	end)
end

-- Custom duration option
local custom_item = sbar.add("item", "pomodoro.custom", {
	position = "popup.pomodoro",
	label = {
		string = "Custom...",
		width = popup_width,
		align = "center",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = settings.font.size,
		},
		color = colors.grey,
	},
	icon = {
		string = icons.gear,
		color = colors.grey,
	},
})

custom_item:subscribe("mouse.entered", function()
	custom_item:set({ background = { drawing = true, color = 0x33ffffff } })
end)

custom_item:subscribe("mouse.exited", function()
	custom_item:set({ background = { drawing = false } })
end)

custom_item:subscribe("mouse.clicked", function()
	pomodoro:set({ popup = { drawing = false } })
	sbar.exec(
		'osascript -e \'display dialog "Enter duration in minutes:" default answer "'
			.. default_duration
			.. '" buttons {"Cancel", "Start"} default button "Start"\' -e \'text returned of result\'',
		function(result)
			local minutes = tonumber(result)
			if minutes and minutes > 0 then
				start_timer(minutes)
			end
		end
	)
end)

-- Left-click: toggle popup, Right-click: start/stop
pomodoro:subscribe("mouse.clicked", function(env)
	if env.BUTTON == "right" then
		if is_running then
			stop_timer()
			sbar.exec("afplay /System/Library/Sounds/Funk.aiff &")
		else
			start_timer(default_duration)
			sbar.exec("afplay /System/Library/Sounds/Tink.aiff &")
		end
	else
		pomodoro:set({ popup = { drawing = "toggle" } })
	end
end)

pomodoro:subscribe("mouse.exited.global", function()
	pomodoro:set({ popup = { drawing = false } })
end)
