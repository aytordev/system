-- Bar configuration - consumes values from nix_constants.lua
local constants = require("nix_constants")

-- Equivalent to the --bar domain
sbar.bar({
	height = constants.bar.height,
	blur_radius = constants.bar.blur_radius,
	color = constants.bar.color,
	sticky = constants.bar.sticky,
	corner_radius = constants.bar.corner_radius,
	border_width = constants.bar.border_width,
	shadow = constants.bar.shadow,
	padding_right = constants.bar.padding_right,
	padding_left = constants.bar.padding_left,
	topmost = constants.bar.topmost,
	y_offset = constants.bar.y_offset,
})
