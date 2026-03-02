-- Bar configuration - consumes values from nix_constants.lua
local colors = require("colors")
local constants = require("nix_constants")

-- Equivalent to the --bar domain
sbar.bar({
	height = constants.bar.height,
	color = colors.bar.bg,
	border_color = colors.bar.border,
	border_width = constants.bar.border_width,
	corner_radius = constants.bar.corner_radius,
	shadow = constants.bar.shadow,
	sticky = constants.bar.sticky,
	padding_right = constants.bar.padding_right,
	padding_left = constants.bar.padding_left,
	blur_radius = constants.bar.blur_radius,
	topmost = constants.bar.topmost,
})
