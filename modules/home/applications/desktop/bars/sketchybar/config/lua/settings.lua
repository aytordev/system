local M = {}

-- Import bar position and fonts
M.bar_position = require("bar-position")
local default_font = require("theme.default_font")

-- Shared settings across all configurations
M.shared = {
    paddings = 4,
    group_paddings = 4,
    bar_height = 30,
    item_height = 22,
    base_animation = "sin",
    base_animation_duration = 8,
    
    -- Font settings imported from default_font.lua
    font = {
        -- Font families
        text = default_font.text,
        numbers = default_font.numbers,
        icons = default_font.icons,
        
        -- Font sizes
        size = default_font.sizes.normal,  -- Standard size
        sizes = default_font.sizes,        -- All available sizes
        
        -- Style map
        style_map = default_font.style_map,
    },

	icons = default_font.icons,
}

-- Top bar specific settings
M.top = {
    bar_position = "top",
    bar_margin = 8,
    bar_y_offset = 4,
    calendar_position = "right",
    popup_y_offset = 4,
}

-- Bottom bar specific settings
M.bottom = {
    bar_position = "bottom",
    bar_margin = 200,
    bar_y_offset = 2,
    calendar_position = "center",
    popup_y_offset = -4,
}

-- Merge shared settings with position-specific settings
local function merge_settings(position_settings)
    local result = {}
    
    -- First copy shared settings
    for k, v in pairs(M.shared) do
        result[k] = v
    end
    
    -- Then override with position-specific settings
    for k, v in pairs(position_settings) do
        result[k] = v
    end
    
    return result
end

-- Return the appropriate settings based on bar position
return merge_settings(M.bar_position == "top" and M.top or M.bottom)
