-- Clipboard history item
-- Shows a popup with recent clipboard entries.
-- Click an entry to restore it to clipboard.
local colors = require("colors")
local settings = require("settings")
local constants = require("nix_constants")

local poll_interval = 2
local max_entries = 10
if constants.items and constants.items.clipboard then
	poll_interval = constants.items.clipboard.poll_interval or 2
	max_entries = constants.items.clipboard.max_entries or 10
end

-- Clipboard state
local history = {}
local last_content = ""

local clipboard = sbar.add("item", "clipboard", {
	position = "right",
	update_freq = poll_interval,
	icon = {
		string = "􀉄",
		font = {
			family = settings.font.text,
			style = "Regular",
			size = settings.icon_size,
		},
		color = colors.white,
		padding_left = settings.padding.icon_item.icon.padding_left,
		padding_right = settings.padding.icon_item.icon.padding_right,
	},
	label = { drawing = false },
	popup = {
		align = "center",
		background = {
			color = colors.popup.bg,
			border_color = colors.popup.border,
			border_width = 1,
			corner_radius = 6,
		},
	},
})

-- Popup items (created once, updated dynamically)
local popup_items = {}

local function truncate(str, len)
	if not str then
		return ""
	end
	-- Remove newlines for display
	str = str:gsub("\n", " "):gsub("%s+", " ")
	if #str > len then
		return str:sub(1, len) .. "…"
	end
	return str
end

local function rebuild_popup()
	-- Remove old popup items
	for _, item in ipairs(popup_items) do
		sbar.remove(item)
	end
	popup_items = {}

	if #history == 0 then
		local empty = sbar.add("item", "clipboard.empty", {
			position = "popup.clipboard",
			label = {
				string = "No entries",
				font = {
					family = settings.font.text,
					style = "Regular",
					size = 12.0,
				},
				color = colors.grey,
				padding_left = 10,
				padding_right = 10,
			},
			background = {
				color = colors.popup.bg,
				height = 28,
			},
		})
		popup_items[1] = empty
		return
	end

	for i, entry in ipairs(history) do
		local display = truncate(entry, 30)
		local item = sbar.add("item", "clipboard.entry." .. i, {
			position = "popup.clipboard",
			label = {
				string = display,
				font = {
					family = settings.font.text,
					style = "Regular",
					size = 12.0,
				},
				color = i == 1 and colors.accent or colors.white,
				padding_left = 10,
				padding_right = 10,
			},
			icon = {
				string = tostring(i),
				font = { size = 10.0 },
				color = colors.grey,
				padding_left = 8,
				padding_right = 0,
			},
			background = {
				color = colors.popup.bg,
				height = 28,
				corner_radius = 4,
			},
		})

		-- Capture entry value for click handler
		local entry_content = entry
		item:subscribe("mouse.clicked", function()
			clipboard:set({ popup = { drawing = false } })
			-- Restore to clipboard using printf to handle special chars
			sbar.exec("printf '%s' " .. string.format("%q", entry_content) .. " | pbcopy")
		end)

		popup_items[i] = item
	end
end

-- Poll clipboard for changes
clipboard:subscribe("routine", function()
	sbar.exec("pbpaste 2>/dev/null", function(result)
		if result and result ~= "" and result ~= last_content then
			last_content = result

			-- Add to front of history, remove duplicates
			local new_history = { result }
			for _, entry in ipairs(history) do
				if entry ~= result and #new_history < max_entries then
					table.insert(new_history, entry)
				end
			end
			history = new_history
		end
	end)
end)

-- Toggle popup on click
clipboard:subscribe("mouse.clicked", function()
	rebuild_popup()
	clipboard:set({ popup = { drawing = "toggle" } })
end)

-- Close popup when clicking elsewhere
clipboard:subscribe("mouse.exited.global", function()
	clipboard:set({ popup = { drawing = false } })
end)
