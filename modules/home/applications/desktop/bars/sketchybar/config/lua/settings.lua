local bar_position = require("bar-position")
local default_font = require("theme.default_font")

local top_bar_settings = {
	bar_position = "top",
	bar_margin = 8,
  bar_y_offset = 4,

	paddings = 4,
	group_paddings = 4,
	bar_height = 30,
	item_height = 22,

	base_animation = "sin",
	base_animation_duration = 8,

	calendar_position = "right",

  popup_y_offset = 4,

	font = {
		text = default_font.text, -- Used for text
		numbers = default_font.numbers, -- Used for numbers
		size = 14.0,
		style_map = default_font.style_map,
	},

	icons = default_font.icons,
}

local bottom_bar_settings = {
	bar_position = "bottom",
	bar_margin = 200,
  bar_y_offset = 2,

	paddings = 4,
	group_paddings = 4,
	bar_height = 30,
	item_height = 22,

	base_animation = "sin",
	base_animation_duration = 8,

	calendar_position = "center",

  popup_y_offset = -4,

	font = {
		text = default_font.text, -- Used for text
		numbers = default_font.numbers, -- Used for numbers
		size = 14.0,
		style_map = default_font.style_map,
	},

	icons = default_font.icons,
}

return bar_position == "top" and top_bar_settings or bottom_bar_settings
