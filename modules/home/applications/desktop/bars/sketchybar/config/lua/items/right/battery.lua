local icons = require("icons")
local colors = require("colors")
local animations = require("animations")
local settings = require("settings")

-- Constants
local POPUP_WIDTH = 200
local HALF_WIDTH = POPUP_WIDTH / 2
local UPDATE_FREQUENCY = 180 -- seconds

-- Configuration
local config = {
    animation = {
        begin = { y_offset = -2 },
        end_state = { y_offset = 0 }
    },
    battery = {
        low_threshold = 20,
        medium_threshold = 40,
        high_threshold = 80,
        critical_color = colors.red,
        warning_color = colors.orange,
        normal_color = colors.green
    }
}

-- State
local state = {
    battery = nil,
    percentage = nil,
    time_remaining = nil,
    is_charging = false
}

-- UI Components
local function create_ui_components()
    local components = {}
    
    -- Main battery item
    components.battery = Sbar.add("item", "left.battery", {
        position = "right",
        icon = {
            font = {
                size = 16.0,
            },
        },
        label = { drawing = false },
        update_freq = UPDATE_FREQUENCY,
        popup = { align = "center" },
        padding_left = settings.group_paddings,
        padding_right = settings.group_paddings,
        background = { shadow = { drawing = false } }
    })

    -- Battery percentage item
    components.percentage = Sbar.add("item", {
        position = "popup." .. components.battery.name,
        icon = {
            width = HALF_WIDTH,
            string = "Battery:",
            align = "left",
        },
        label = {
            width = HALF_WIDTH,
            string = "??%",
            align = "right",
        },
        background = { drawing = false },
    })

    -- Remaining time item
    components.time_remaining = Sbar.add("item", {
        position = "popup." .. components.battery.name,
        icon = {
            width = HALF_WIDTH,
            string = "Time remaining:",
            align = "left",
        },
        label = {
            width = HALF_WIDTH,
            string = "??:??h",
            align = "right",
        },
        background = { drawing = false },
    })

    return components
end

-- Battery Functions
local function update_battery_icon(charge, is_charging)
    local icon = icons.battery._0
    local color = config.battery.critical_color
    
    if is_charging then
        icon = icons.battery.charging
        color = config.battery.normal_color
    elseif charge > config.battery.high_threshold then
        icon = icons.battery._100
        color = config.battery.normal_color
    elseif charge > config.battery.medium_threshold then
        icon = icons.battery._75
        color = config.battery.normal_color
    elseif charge > config.battery.low_threshold then
        icon = icons.battery._50
        color = config.battery.normal_color
    elseif charge > 0 then
        icon = icons.battery._25
        color = config.battery.warning_color
    end
    
    return icon, color
end

local function parse_battery_info(output)
    -- Check if there's no battery (different macOS versions report this differently)
    if output:find("No battery") or output:find("Battery Not Present") or not output:match("%d+%%") then
        return {
            has_battery = false,
            charge = 0,
            is_charging = false,
            time_remaining = "N/A"
        }
    end
    
    local charge = 0
    local is_charging = false
    local time_remaining = "No estimate"
    
    -- Extract charge percentage
    local charge_match = output:match("(%d+)%%")
    if charge_match then
        charge = tonumber(charge_match)
    end
    
    -- Check if charging
    is_charging = output:find("AC Power") ~= nil
    
    -- Extract time remaining if available
    local time_match = output:match("(%d+:%d+) remaining")
    if time_match then
        time_remaining = time_match .. "h"
    end
    
    return {
        has_battery = true,
        charge = charge,
        is_charging = is_charging,
        time_remaining = time_remaining
    }
end

local function update_battery_display()
    Sbar.exec("pmset -g batt", function(output)
        local info = parse_battery_info(output)
        
        -- Update state
        state.is_charging = info.is_charging
        
        if info.has_battery then
            -- Update battery icon and color for systems with battery
            local icon, color = update_battery_icon(info.charge, info.is_charging)
            
            -- Update UI
            state.battery:set({
                icon = {
                    string = icon,
                    color = color
                }
            })
            
            -- Update percentage with leading zero if needed
            local charge_text = string.format("%d%%", info.charge)
            local display_charge = info.charge < 10 and "0" .. charge_text or charge_text
            state.percentage:set({ 
                label = { string = display_charge } 
            })
        else
            -- For systems without battery, show a power plug icon and infinity symbol
            state.battery:set({
                icon = {
                    string = icons.battery.charging, -- Show power plug icon
                    color = colors.theme.fg
                }
            })
            
            -- Show infinity symbol in the percentage and time remaining
            state.percentage:set({ 
                label = { string = "∞" } 
            })
        end
        
        -- Update time remaining in popup if visible
        if state.battery:query().popup.drawing == "on" then
            state.time_remaining:set({ 
                label = { 
                    string = info.has_battery and info.time_remaining or "∞"
                } 
            })
        end
    end)
end

-- Event Handlers
local function on_battery_update()
    update_battery_display()
end

local function on_click()
    local begin_set = config.animation.begin
    local end_set = config.animation.end_state
    
    animations.custom_animation(
        state.battery,
        settings.base_animation,
        settings.base_animation_duration,
        begin_set,
        end_set
    )
    
    local is_visible = state.battery:query().popup.drawing == "on"
    state.battery:set({ popup = { drawing = not is_visible } })
    
    -- Force update when showing popup
    if not is_visible then
        update_battery_display()
    end
end

-- Initialize
local function init()
    -- Create UI components
    local components = create_ui_components()
    for k, v in pairs(components) do
        state[k] = v
    end

    -- Set up event subscriptions
    state.battery:subscribe({ "routine", "power_source_change", "system_woke" }, on_battery_update)
    state.battery:subscribe("mouse.clicked", on_click)
    state.battery:subscribe("mouse.exited.global", function()
        state.battery:set({ popup = { drawing = false } })
    end)

    -- Initial update
    on_battery_update()
end

-- Initialize the module
init()

return state.battery