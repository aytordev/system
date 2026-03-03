local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
-- background.drawing defaults to false — brackets provide group backgrounds
sbar.default({
	background = {
		drawing = false,
		color = colors.bg1,
		border_color = colors.bg2,
		border_width = 1,
		corner_radius = 15,
		height = 25,
		image = {
			corner_radius = 15,
			border_color = colors.grey,
			border_width = 1,
		},
	},
	icon = {
		font = {
			family = settings.font_icon.text,
			style = settings.font_icon.style_map["Bold"],
			size = settings.font_icon.size,
		},
		color = colors.accent,
		highlight_color = colors.bg1,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
		y_offset = 1,
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Semibold"],
			size = settings.font.size,
		},
		color = colors.accent,
		padding_right = settings.paddings,
	},
	popup = {
		align = "center",
		background = {
			border_width = 1,
			border_color = colors.popup.border,
			corner_radius = 15,
			color = colors.popup.bg,
			shadow = { drawing = true },
		},
		blur_radius = 50,
		y_offset = 5,
	},
	padding_left = 4,
	padding_right = 4,
	scroll_texts = true,
	updates = "on",
})
