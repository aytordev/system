local colors = require("colors")
local icons = require("icons")
local animations = require("animations")
local settings = require("settings")

-- Constants
local POPUP_WIDTH = 200
local SLIDER_WIDTH = 60
local SLIDER_PADDING = -5

-- Configuration
local config = {
    animation = {
        begin = { width = 0, slider = { width = 0 } },
        end_state = { width = SLIDER_WIDTH, slider = { width = 50 } }
    },
    slider = {
        height = 10,
        corner_radius = 6,
        bg_color = colors.theme.c4,
        highlight_color = colors.theme.c9
    }
}

-- State
local state = {
    volume_icon = nil,
    volume_slider = nil,
    current_audio_device = "None"
}

-- UI Components
local function create_ui_components()
    local components = {}
    
    -- Volume slider
    components.volume_slider = Sbar.add("slider", "volume.slider", 0, {
        width = 0,
        position = "right",
        slider = {
            highlight_color = config.slider.highlight_color,
            background = {
                height = config.slider.height,
                corner_radius = config.slider.corner_radius,
                color = config.slider.bg_color,
            },
            knob = { drawing = false },
        },
        padding_left = SLIDER_PADDING,
        padding_right = SLIDER_PADDING,
        click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
        background = { shadow = { drawing = false } }
    })

    -- Volume icon
    components.volume_icon = Sbar.add("item", "left.volume", {
        position = "right",
        icon = {
            drawing = true,
            color = colors.theme.c9,
            padding_left = 0,
            padding_right = 0,
        },
        label = { drawing = false },
        padding_left = 0,
        padding_right = 0,
        background = { shadow = { drawing = false } }
    })

    -- Popup placeholder
    Sbar.add("item", {
        position = "popup." .. components.volume_icon.name,
        drawing = false,
    })

    return components
end

-- Volume Functions
local function update_volume_icon(volume)
    local icon = icons.volume._0
    if volume > 60 then
        icon = icons.volume._100
    elseif volume > 30 then
        icon = icons.volume._66
    elseif volume > 10 then
        icon = icons.volume._33
    elseif volume > 0 then
        icon = icons.volume._10
    end
    return icon
end

local function update_volume_display(env)
    local volume = tonumber(env.INFO)
    local icon = update_volume_icon(volume)
    
    state.volume_icon:set({ icon = icon })
    state.volume_slider:set({ slider = { percentage = volume } })
end

local function cleanup_audio_devices()
    local drawing = state.volume_icon:query().popup.drawing == "on"
    if not drawing then return end
    
    state.volume_icon:set({ popup = { drawing = false } })
    Sbar.remove("/volume.device%..*/")
end

-- Event Handlers
local function on_volume_change(env)
    update_volume_display(env)
end

local function on_audio_device_select(env)
    if env.BUTTON ~= "left" then
        Sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
        return
    end

    local should_show = state.volume_icon:query().popup.drawing == "off"
    if should_show then
        state.volume_icon:set({ popup = { drawing = true } })
        Sbar.exec("SwitchAudioSource -t output -c", function(result)
            state.current_audio_device = result:gsub("[\r\n]", "")
            Sbar.exec("SwitchAudioSource -a -t output", function(available)
                local counter = 0
                for device in available:gmatch("[^\r\n]+") do
                    local is_current = device == state.current_audio_device
                    Sbar.add("item", "volume.device." .. counter, {
                        position = "popup." .. state.volume_icon.name,
                        width = POPUP_WIDTH,
                        align = "left",
                        label = {
                            string = device,
                            color = is_current and colors.theme.c9 or colors.theme.fg,
                        },
                        background = { drawing = false },
                        click_script = string.format(
                            'SwitchAudioSource -s "%s" && sketchybar --set /volume.device%%.*/ label.color=%s --set $NAME label.color=%s',
                            device, colors.theme.fg, colors.theme.c9
                        ),
                    })
                    counter = counter + 1
                end
            end)
        end)
    else
        cleanup_audio_devices()
    end
end

local function on_slider_click(env)
    local slider_width = state.volume_slider:query().slider.width
    local begin_set, end_set = config.animation.begin, config.animation.end_state
    
    if tonumber(slider_width) > 0 then
        begin_set, end_set = end_set, begin_set
    end
    
    animations.custom_animation(
        state.volume_slider,
        settings.base_animation,
        20, -- animation duration
        begin_set,
        end_set
    )
    
    on_audio_device_select(env)
end

-- Initialize
local function init()
    -- Create UI components
    local components = create_ui_components()
    for k, v in pairs(components) do
        state[k] = v
    end

    -- Set up event subscriptions
    state.volume_icon:subscribe("volume_change", on_volume_change)
    state.volume_icon:subscribe("mouse.clicked", on_slider_click)
end

-- Initialize the module
init()

return state.volume_icon