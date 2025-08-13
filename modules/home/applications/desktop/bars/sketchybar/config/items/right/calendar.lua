local icons = require("icons")
local colors = require("colors").sections.calendar
local settings = require("settings")
local utils = require("utils")

local cal = sbar.add("item", utils.PRESETS.icon_item({
  icon = {
    padding_left = 8,
    padding_right = 4,
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
    },
  },
  label = {
    color = colors.label,
    align = "left",
    padding_right = 8,
  },
  padding_left = 10,
  position = "right",
  update_freq = 30,
  click_script = "open -a 'Calendar'",
}))

-- Click animation with custom padding for calendar
local click_config = {
  pressed_padding_left = 14,
  normal_padding_left = 10,
}

cal:subscribe(utils.EVENTS.MOUSE_CLICK, function()
  utils.animate_click(cal, click_config)
end)

-- Update time display
cal:subscribe({ utils.EVENTS.FORCED, utils.EVENTS.ROUTINE, utils.EVENTS.SYSTEM_WOKE }, function()
  cal:set({ icon = os.date("%H:%M"), label = icons.calendar })
end)