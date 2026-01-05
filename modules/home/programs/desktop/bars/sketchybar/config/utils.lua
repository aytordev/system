-- Common utilities for sketchybar configuration
-- Provides shared animations, helpers, and constants to reduce code duplication

local M = {}

-- Animation constants
M.ANIMATION = {
  DURATION = 8,
  EASING = "tanh",
  OFFSETS = {
    PRESSED = -4,
    NORMAL = 0,
  },
  SHADOWS = {
    PRESSED = 0,
    NORMAL = 4,
  },
  PADDINGS = {
    PRESSED_LEFT = 8,
    PRESSED_RIGHT = 0,
    NORMAL_LEFT = 4,
    NORMAL_RIGHT = 4,
  },
}

-- Common click animation for items
-- Creates a press-down effect with shadow changes
function M.animate_click(item, custom_config)
  local config = custom_config or {}
  
  sbar.animate(M.ANIMATION.EASING, M.ANIMATION.DURATION, function()
    -- Press down state
    item:set({
      background = {
        shadow = {
          distance = config.pressed_shadow or M.ANIMATION.SHADOWS.PRESSED,
        },
      },
      y_offset = config.pressed_offset or M.ANIMATION.OFFSETS.PRESSED,
      padding_left = config.pressed_padding_left or M.ANIMATION.PADDINGS.PRESSED_LEFT,
      padding_right = config.pressed_padding_right or M.ANIMATION.PADDINGS.PRESSED_RIGHT,
    })
    
    -- Return to normal state
    item:set({
      background = {
        shadow = {
          distance = config.normal_shadow or M.ANIMATION.SHADOWS.NORMAL,
        },
      },
      y_offset = config.normal_offset or M.ANIMATION.OFFSETS.NORMAL,
      padding_left = config.normal_padding_left or M.ANIMATION.PADDINGS.NORMAL_LEFT,
      padding_right = config.normal_padding_right or M.ANIMATION.PADDINGS.NORMAL_RIGHT,
    })
  end)
end

-- Create a standard click handler with animation
function M.create_click_handler(item, custom_config)
  return function()
    M.animate_click(item, custom_config)
  end
end

-- Helper to get nested table values safely
function M.get_nested(table, ...)
  local keys = {...}
  local current = table
  
  for _, key in ipairs(keys) do
    if type(current) ~= "table" or current[key] == nil then
      return nil
    end
    current = current[key]
  end
  
  return current
end

-- Helper to merge tables (shallow merge)
function M.merge_tables(default, override)
  local result = {}
  
  for k, v in pairs(default) do
    result[k] = v
  end
  
  if override then
    for k, v in pairs(override) do
      result[k] = v
    end
  end
  
  return result
end

-- Common item configuration presets
M.PRESETS = {
  -- Standard item with text
  text_item = function(config)
    local defaults = {
      icon = { drawing = false },
      label = {
        padding_left = 8,
        padding_right = 8,
      },
      background = { drawing = true },
      padding_left = 4,
      padding_right = 4,
    }
    return M.merge_tables(defaults, config)
  end,
  
  -- Standard item with icon
  icon_item = function(config)
    local defaults = {
      icon = {
        padding_left = 8,
        padding_right = 4,
      },
      label = {
        padding_left = 4,
        padding_right = 8,
      },
      background = { drawing = true },
      padding_left = 4,
      padding_right = 4,
    }
    return M.merge_tables(defaults, config)
  end,
}

-- Common popup configuration
function M.create_popup_config(align, y_offset, horizontal)
  return {
    align = align or "center",
    y_offset = y_offset or 2,
    horizontal = horizontal ~= nil and horizontal or false,  -- Default to vertical layout
  }
end

-- Utility to conditionally set item visibility
function M.set_visibility(item, condition)
  item:set({ drawing = condition })
end

-- Helper for battery percentage to icon mapping
function M.battery_icon_for_percentage(percentage, icons, charging)
  if charging then
    return icons.charging
  end
  
  if percentage > 80 then
    return icons._100
  elseif percentage > 60 then
    return icons._75
  elseif percentage > 40 then
    return icons._50
  elseif percentage > 20 then
    return icons._25
  else
    return icons._0
  end
end

-- Helper for volume percentage to icon mapping
function M.volume_icon_for_percentage(percentage, icons)
  if percentage > 60 then
    return icons._100
  elseif percentage > 30 then
    return icons._66
  elseif percentage > 10 then
    return icons._33
  elseif percentage > 0 then
    return icons._10
  else
    return icons._0
  end
end

-- Common subscription events
M.EVENTS = {
  MOUSE_CLICK = "mouse.clicked",
  MOUSE_SCROLL = "mouse.scrolled",
  ROUTINE = "routine",
  SYSTEM_WOKE = "system_woke",
  FORCED = "forced",
  FRONT_APP_SWITCHED = "front_app_switched",
  SPACE_CHANGE = "space_change",
}

return M