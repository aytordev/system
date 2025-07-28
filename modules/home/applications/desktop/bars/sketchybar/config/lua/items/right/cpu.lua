local icons = require("icons")
local colors = require("colors")
local animations = require("animations")
local settings = require("settings")

-- Configuration
local config = {
    update_interval = 2, -- seconds
    animation = {
        begin = { y_offset = -2 },
        end_state = { y_offset = 0 }
    },
    thresholds = {
        low = 30,
        medium = 60,
        high = 80
    }
}

-- State
local state = {
    cpu = nil,
    popup = nil,
    load = 0,
    cores = {}
}

-- UI Components
local function create_ui_components()
    -- Main CPU item
    state.cpu = Sbar.add("item", "left.cpu", {
        position = "right",
        icon = {
            string = icons.cpu,
            color = colors.theme.c8,
			font = { size = 16.0 },
            background = { 
                color = colors.theme.c3, 
                height = settings.item_height, 
                border_width = 0, 
                corner_radius = 6 
            }
        },
        label = {
            string = "0%",
            font = { size = 12.0 }
        },
        padding_right = settings.group_paddings,
        padding_left = settings.group_paddings,
        background = { shadow = { drawing = false } }
    })
    
    -- Set initial state
    state.cpu:set({
        icon = { color = colors.blue },
        label = { string = "0%" }
    })

    -- Popup for detailed CPU info
    state.popup = Sbar.add("item", "cpu.popup", {
        position = "popup." .. state.cpu.name,
        icon = { drawing = false },
        label = { string = "Loading CPU info..." },
        background = { color = colors.theme.c2, corner_radius = 8 },
        padding_left = 10,
        padding_right = 10
    })
end

-- Helper Functions
local function get_cpu_color(load)
    if load < config.thresholds.low then
        return colors.blue
    elseif load < config.thresholds.medium then
        return colors.yellow
    elseif load < config.thresholds.high then
        return colors.orange
    else
        return colors.red
    end
end

local function update_cpu_display(env)
    local load = tonumber(env.total_load) or 0
    load = math.min(100, math.max(0, load))  -- Clamp between 0 and 100
    
    local color = get_cpu_color(load)
    
    -- Update main CPU display
    state.cpu:set({
        icon = { color = color },
        label = { string = string.format("%d%%", load) }
    })
    
    -- Update popup if visible
    if state.cpu:query().popup.drawing == "on" then
        state.popup:set({
            label = { 
                string = string.format("CPU Usage: %d%%", load)
            }
        })
    end
end

-- Event Handlers
local function on_cpu_update(env)
    update_cpu_display(env)
end

local function on_click()
    animations.base_click_animation(state.cpu)
    Sbar.exec("open -a 'Activity Monitor'")
end

-- Initialize
local function init()
    create_ui_components()
    
    -- Start CPU monitoring
    Sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update " .. config.update_interval)
    
    -- Event subscriptions
    state.cpu:subscribe("cpu_update", on_cpu_update)
    state.cpu:subscribe("mouse.clicked", on_click)
    
    -- Initial update
    Sbar.exec("$CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 0.1")
end

-- Start the module
init()

return state