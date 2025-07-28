local settings = require("settings")

require("items.left.logo")

Sbar.add("item", "logo.padding.left", {
	position = "left",
	width = settings.group_paddings,
	icon = { drawing = false },
	label = { drawing = false },
	background = { drawing = false },
})

require("items.left.aerospace")

Sbar.add("item", "space.padding.left", {
	position = "left",
	width = settings.group_paddings,
	icon = { drawing = false },
	label = { drawing = false },
	background = { drawing = false },
})

-- require("items.left.apps")



