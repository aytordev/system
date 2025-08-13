local icons = require("icons")
local colors = require("colors").sections.widgets.battery
local utils = require("utils")

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  icon = {},
  label = { drawing = false },
  background = { drawing = false },
  padding_left = 8,
  padding_right = 4,
  update_freq = 180,
  popup = utils.create_popup_config("center", 4),
})

local remaining_time = sbar.add("item", {
  position = "popup." .. battery.name,
  icon = {
    string = "Time remaining:",
    width = 100,
    align = "left",
  },
  label = {
    string = "??:??h",
    width = 100,
    align = "right",
  },
  background = { drawing = false },
})

-- Helper function to get battery color based on percentage and charging status
local function get_battery_color(percentage, charging)
  if charging then
    return colors.high
  end
  
  if percentage > 30 then
    return colors.high
  elseif percentage > 20 then
    return colors.mid
  else
    return colors.low
  end
end

-- Update battery icon and color based on current status
local function update_battery_display()
  sbar.exec("pmset -g batt", function(batt_info)
    local found, _, charge = batt_info:find("(%d+)%%")
    local percentage = found and tonumber(charge) or 0
    local charging = batt_info:find("AC Power") ~= nil
    
    local icon = utils.battery_icon_for_percentage(percentage, icons.battery, charging)
    local color = get_battery_color(percentage, charging)
    
    battery:set({
      icon = {
        string = icon,
        color = color,
      },
    })
  end)
end

-- Handle battery popup toggle and time remaining display
local function handle_battery_click()
  local drawing = battery:query().popup.drawing
  battery:set({ popup = { drawing = "toggle" } })
  
  if drawing == "off" then
    sbar.exec("pmset -g batt", function(batt_info)
      local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
      local label = found and remaining .. "h" or "No estimate"
      remaining_time:set({ label = label })
    end)
  end
end

-- Subscribe to power events for battery updates
battery:subscribe({ utils.EVENTS.ROUTINE, "power_source_change", utils.EVENTS.SYSTEM_WOKE }, update_battery_display)

-- Handle mouse clicks for popup
battery:subscribe(utils.EVENTS.MOUSE_CLICK, handle_battery_click)