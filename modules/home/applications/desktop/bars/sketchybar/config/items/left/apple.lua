local colors = require("colors").sections
local icons = require("icons")
local utils = require("utils")

local apple = sbar.add("item", utils.PRESETS.icon_item({
  icon = {
    font = { size = 16 },
    string = icons.apple,
    padding_right = 15,
    padding_left = 15,
    color = colors.apple,
  },
  label = { drawing = false },
  click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
}))

apple:subscribe(utils.EVENTS.MOUSE_CLICK, utils.create_click_handler(apple))