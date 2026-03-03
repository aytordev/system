local colors = require("colors")
local settings = require("settings")

local brew = sbar.add("item", "widgets.brew", {
	position = "right",
	update_freq = 3600,
	icon = {
		string = "󰏖",
		padding_right = settings.paddings * 0.5,
	},
	label = {
		string = "?",
		padding_right = 0,
	},
	popup = {
		align = "center",
		height = 30,
	},
})

-- Cache for outdated packages (must be declared before update_brew)
local cached_packages = {}

local function is_package_line(line)
	-- Filter out error messages and non-package lines
	if not line or line == "" or line:match("^%s*$") then
		return false
	end
	if
		line:match("^Error:")
		or line:match("^Please report")
		or line:match("^/opt/homebrew")
		or line:match("Troubleshooting")
		or line:match("undefined method")
		or line:match("%.rb:")
	then
		return false
	end
	return true
end

local function update_brew()
	local brew_cmd = '/bin/zsh -c "brew outdated -q"'

	-- print("[BREW OUTDATED] Running command: " .. brew_cmd)

	sbar.exec(brew_cmd, function(outdated_output)
		-- print("[BREW OUTDATED] Cmd Output: " .. outdated_output)

		-- Clear and rebuild cache
		cached_packages = {}

		-- Count and cache valid package lines
		local count = 0
		for line in outdated_output:gmatch("[^\r\n]+") do
			-- print("[BREW OUTDATED] Line: " .. line)
			if is_package_line(line) then
				count = count + 1
				table.insert(cached_packages, line)
				-- print("[BREW OUTDATED] Valid package: " .. line)
				end
		end

		-- print("[BREW OUTDATED] Final count: " .. count .. ", cached: " .. #cached_packages)

		local color = colors.green
		if count >= 4 then
			color = colors.red
		elseif count > 0 then
			color = colors.yellow
		end

		brew:set({
			label = {
				string = count,
				color = color,
			},
			icon = { color = color },
		})
	end)
end

brew:subscribe({ "routine", "forced" }, update_brew)

-- Run initial update on load
update_brew()

local popup_items = {}

local function clear_popup()
	for _, item in ipairs(popup_items) do
		sbar.remove(item.name)
	end
	popup_items = {}
end

local function populate_popup()
	clear_popup()

	-- print("[BREW POPUP] Using cached packages: " .. #cached_packages .. " packages")

	if #cached_packages == 0 then
		local no_updates = sbar.add("item", {
			position = "popup." .. brew.name,
			label = {
				string = "No outdated packages",
				font = {
					family = settings.font.text,
					style = settings.font.style_map["Regular"],
					size = settings.font.size,
				},
				padding_left = 8,
				padding_right = 8,
			},
			icon = { drawing = false },
		})
		table.insert(popup_items, no_updates)
	else
		for _, package in ipairs(cached_packages) do
			-- print("[BREW POPUP] Adding cached package: " .. package)

			local pkg_item = sbar.add("item", {
				position = "popup." .. brew.name,
				label = {
					string = package,
					font = {
						family = settings.font.text,
						style = settings.font.style_map["Regular"],
						size = 10.0,
					},
					padding_left = 8,
					padding_right = 8,
				},
				icon = {
					string = "•",
					padding_left = 8,
					padding_right = 4,
				},
			})
			table.insert(popup_items, pkg_item)
		end
	end
end

-- Click to toggle popup
brew:subscribe("mouse.clicked", function()
	local query = brew:query()
	local should_draw = query and query.popup and query.popup.drawing == "off" or true

	if should_draw then
		populate_popup()
	end

	sbar.exec("sketchybar --set widgets.brew popup.drawing=toggle")
end)

brew:subscribe("mouse.exited.global", function()
	brew:set({ popup = { drawing = false } })
end)

-- Bracket grouping is handled by the unified right.bracket in init.lua
