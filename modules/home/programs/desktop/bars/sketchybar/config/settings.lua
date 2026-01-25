-- Settings module - consumes values from nix_constants.lua
local constants = require("nix_constants")

return {
	font = {
		text = constants.fonts.text,
		numbers = constants.fonts.text,
		size = constants.fonts.size,
		style_map = {
			["Regular"] = "Regular",
			["Semibold"] = "Semibold",
			["Bold"] = "Bold",
			["Heavy"] = "Heavy",
			["Black"] = "Black",
		},
	},
	font_icon = {
		text = constants.fonts.icon,
		numbers = constants.fonts.icon,
		size = constants.fonts.size,
		style_map = {
			["Regular"] = "Regular",
			["Semibold"] = "Semibold",
			["Bold"] = "Bold",
			["Heavy"] = "Heavy",
			["Black"] = "Black",
		},
	},

	-- Icon style from Nix configuration
	icons = constants.settings.icons_style,

	height = 24,
	paddings = 8,
	group_paddings = 5,

	-- Standard sizes for consistency
	icon_size = 15.0,
	label_size = 12.0,
	padding = {
		icon_item = {
			icon = {
				padding_left = 12,
				padding_right = 12,
			},
		},
		icon_label_item = {
			icon = {
				padding_left = 8,
				padding_right = 0,
			},
			label = {
				padding_left = 6,
				padding_right = 8,
			},
		},
	},
}
