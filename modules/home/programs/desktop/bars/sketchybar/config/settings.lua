-- Settings module - consumes values from nix_constants.lua
local constants = require("nix_constants") -- luacheck: ignore 211

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

	-- Standard sizes for consistency
	icon_size = 15.0,
	label_size = 12.0,
}
