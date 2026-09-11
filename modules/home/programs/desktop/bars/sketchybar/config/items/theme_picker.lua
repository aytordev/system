-- Theme picker popup
-- Click to open a popup listing every registered family/variant plus a
-- "Follow Nix" reset. Selecting one applies it immediately via
-- sketchybar --reload; the choice is persisted until reset.
local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local theme = require("helpers.theme")

local icon_picker = sbar.add("item", "theme_picker", {
	position = "right",
	background = { drawing = false },
	icon = {
		string = icons.theme,
		color = colors.pink,
		font = { size = settings.font_icon.size * 2 },
	},
	label = { drawing = false },
	popup = { align = "right" },
})

-- Item ids cannot contain "/" or "."
local function item_name(key)
	return "theme_picker." .. key:gsub("[^%w]", "_")
end

local function add_entry(key, label, is_active, is_follow)
	local item_color = colors.accent
	if not is_follow and theme.themes[key] and theme.themes[key].accent then
		item_color = theme.themes[key].accent
	end

	local display = is_active and ("✓ " .. label) or ("  " .. label)
	local item = sbar.add("item", item_name(key), {
		position = "popup.theme_picker",
		label = {
			string = display,
			font = {
				family = settings.font.text,
				style = is_active and "Bold" or "Regular",
				size = 13.0,
			},
			color = is_active and colors.accent or colors.white,
		},
		icon = {
			string = "●",
			color = item_color,
			font = { size = 10.0 },
		},
	})

	item:subscribe("mouse.clicked", function()
		icon_picker:set({ popup = { drawing = false } })
		if is_follow then
			theme.follow_nix()
		else
			theme.apply(key)
		end
	end)

	item:subscribe("mouse.entered", function()
		item:set({ background = { drawing = true, color = 0x33ffffff } })
	end)

	item:subscribe("mouse.exited", function()
		item:set({ background = { drawing = false } })
	end)
end

local following = theme.is_following_nix()
add_entry("follow-nix", "Follow Nix", following, true)

for _, name in ipairs(theme.list()) do
	add_entry(name, name, (not following and name == theme.current), false)
end

-- Toggle popup on click
icon_picker:subscribe("mouse.clicked", function()
	icon_picker:set({
		popup = { drawing = "toggle" },
	})
end)

-- Close popup when clicking elsewhere
icon_picker:subscribe("mouse.exited.global", function()
	icon_picker:set({ popup = { drawing = false } })
end)
