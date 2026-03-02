-- App menu bar items with curtain effect
-- Shares the left side of the bar with workspaces.
-- When menus expand, workspaces fade out (and vice versa).
local settings = require("settings")
local colors = require("colors")

-- Menu state
local menu_visible = false

-- Register custom events for curtain coordination
sbar.add("event", "fade_out_spaces")
sbar.add("event", "fade_in_spaces")

-- Apple menu trigger (always visible)
local menu_trigger = sbar.add("item", "menu_trigger", {
	position = "left",
	drawing = true,
	updates = true,
	icon = {
		string = "􀣺",
		font = {
			family = settings.font.text,
			style = "Regular",
			size = 16.0,
		},
		color = colors.white,
		padding_left = 8,
		padding_right = 8,
	},
	label = { drawing = false },
	background = {
		color = colors.bg1,
		drawing = true,
		corner_radius = 6,
	},
})

-- Maximum number of menu items to display
local max_items = 15
local menu_items = {}

-- Create inline menu items (hidden by default)
for i = 1, max_items do
	local menu = sbar.add("item", "menu." .. i, {
		position = "left",
		drawing = false,
		width = 0,
		icon = { drawing = false },
		label = {
			font = {
				family = settings.font.text,
				style = settings.font.style_map["Semibold"],
				size = 13.0,
			},
			color = colors.white,
			padding_left = settings.paddings,
			padding_right = settings.paddings,
		},
		click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s " .. i,
	})
	menu_items[i] = menu
end

-- Menu watcher for front app changes
local menu_watcher = sbar.add("item", {
	drawing = false,
	updates = false,
})

-- Update menu contents from current app
local function update_menus()
	sbar.exec("$CONFIG_DIR/helpers/menus/bin/menus -l", function(menus)
		for i = 1, max_items do
			menu_items[i]:set({ drawing = false, width = 0 })
		end

		local id = 1
		for menu in string.gmatch(menus, "[^\r\n]+") do
			if id <= max_items then
				menu_items[id]:set({
					label = { string = menu },
					drawing = menu_visible,
					width = menu_visible and "dynamic" or 0,
				})
			else
				break
			end
			id = id + 1
		end
	end)
end

-- Show menus with curtain effect
local function show_menus()
	menu_visible = true
	menu_watcher:set({ updates = true })

	-- Fade out workspaces
	sbar.trigger("fade_out_spaces")

	-- Update menu content
	update_menus()

	-- Animate menu items in
	sbar.animate("tanh", 30, function()
		for i = 1, max_items do
			local query = menu_items[i]:query()
			if query and query.label and query.label.string ~= "" then
				menu_items[i]:set({
					drawing = true,
					width = "dynamic",
					label = { drawing = true },
				})
			end
		end
	end)

	-- Highlight trigger
	menu_trigger:set({
		icon = { color = colors.accent },
	})
end

-- Hide menus with curtain effect
local function hide_menus()
	menu_visible = false

	-- Animate menu items out
	sbar.animate("tanh", 30, function()
		for i = 1, max_items do
			menu_items[i]:set({ width = 0 })
		end
	end)

	-- After animation, hide items and fade workspaces back in
	-- Small delay to let the collapse animation finish
	sbar.exec("sleep 0.3", function()
		for i = 1, max_items do
			menu_items[i]:set({ drawing = false })
		end
		menu_watcher:set({ updates = false })

		-- Fade workspaces back in
		sbar.trigger("fade_in_spaces")
	end)

	-- Reset trigger color
	menu_trigger:set({
		icon = { color = colors.white },
	})
end

-- Toggle on click
menu_trigger:subscribe("mouse.clicked", function(env)
	if env.BUTTON == "left" then
		if menu_visible then
			hide_menus()
		else
			show_menus()
		end
	elseif env.BUTTON == "right" then
		-- Right-click opens Apple menu
		sbar.exec("$CONFIG_DIR/helpers/menus/bin/menus -s 'Apple' &")
	end
end)

-- Auto-collapse when mouse leaves bar area
menu_trigger:subscribe("mouse.exited.global", function()
	if menu_visible then
		hide_menus()
	end
end)

-- Update menu contents when frontmost app changes
menu_watcher:subscribe("front_app_switched", function()
	if menu_visible then
		update_menus()
	end
end)

-- Initial menu content load
update_menus()
