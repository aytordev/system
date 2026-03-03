-- Theme variant picker popup
-- Click to open a popup listing available theme variants.
-- Selecting a variant applies it immediately via sketchybar --reload.
local colors = require("colors")
local settings = require("settings")
local theme = require("helpers.theme")

local icon_picker = sbar.add("item", "theme_picker", {
	position = "right",
	icon = {
		string = "􀎑",
		font = {
			family = settings.font.text,
			style = "Regular",
			size = settings.icon_size,
		},
		color = colors.accent,
		padding_left = settings.padding.icon_item.icon.padding_left,
		padding_right = settings.padding.icon_item.icon.padding_right,
	},
	label = { drawing = false },
	popup = { align = "right" },
})

-- Build popup entries from available themes
local variant_names = theme.list()

for _, name in ipairs(variant_names) do
	local is_active = (name == theme.current)
	local display = is_active and ("✓ " .. name) or ("  " .. name)

	local variant_colors = theme.variants[name]
	local item_color = variant_colors and variant_colors.accent or colors.accent

	local item = sbar.add("item", "theme_picker.variant." .. name, {
		position = "popup.theme_picker",
		label = {
			string = display,
			font = {
				family = settings.font.text,
				style = is_active and "Bold" or "Regular",
				size = 13.0,
			},
			color = is_active and colors.accent or colors.white,
			padding_left = 10,
			padding_right = 10,
		},
		icon = {
			string = "●",
			color = item_color,
			padding_left = 8,
			padding_right = 0,
			font = { size = 10.0 },
		},
	})

	item:subscribe("mouse.clicked", function()
		icon_picker:set({ popup = { drawing = false } })
		theme.apply(name)
	end)

	item:subscribe("mouse.entered", function()
		item:set({ background = { drawing = true, color = 0x33ffffff } })
	end)

	item:subscribe("mouse.exited", function()
		item:set({ background = { drawing = false } })
	end)
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
