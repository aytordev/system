local icons = require("icons")
local colors = require("colors")
local animations = require("animations")
local settings = require("settings")

-- Constants
local POPUP_WIDTH = 250
local HALF_WIDTH = POPUP_WIDTH / 2
local DEFAULT_IP = "???.???.???.???"
local UPDATE_DELAY = 2 -- seconds

-- Configuration
local config = {
    wifi_interface = "en0",
    wifi_service = "Wi-Fi",
    animation = {
        begin = { y_offset = -2 },
        end_state = { y_offset = 0 }
    }
}

-- State
local state = {
    wifi = nil,
    ip = nil,
    mask = nil,
    router = nil,
    is_vpn_connected = false
}

-- UI Components
local function create_ui_components()
    local components = {}
    
    -- Main WiFi item
    components.wifi = Sbar.add("item", "left.wifi", {
        position = "right",
        icon = { color = colors.theme.c8 },
        label = { drawing = false },
        padding_right = 0,
        padding_left = 0,
        background = { shadow = { drawing = false } }
    })

    -- Helper function to create popup items
    local function create_popup_item(name, icon_text)
        return Sbar.add("item", {
            position = "popup." .. components.wifi.name,
            icon = {
                align = "left",
                string = icon_text,
                width = HALF_WIDTH,
            },
            label = {
                string = DEFAULT_IP,
                width = HALF_WIDTH,
                align = "right",
            },
            background = { drawing = false }
        })
    end

    components.ip = create_popup_item("ip", "IP:")
    components.mask = create_popup_item("mask", "Subnet mask:")
    components.router = create_popup_item("router", "Router:")

    return components
end

-- Network Functions
local function get_wifi_info(callback)
    Sbar.exec([[
        networksetup -getinfo "]] .. config.wifi_service .. [["
    ]], callback)
end

local function parse_wifi_info(output)
    local info = { ip = DEFAULT_IP, mask = DEFAULT_IP, router = DEFAULT_IP }
    
    for line in output:gmatch("[^\r\n]+") do
        local ip_match = line:match("^IP address: (.+)$")
        local mask_match = line:match("^Subnet mask: (.+)$")
        local router_match = line:match("^Router: (.+)$")
        
        if ip_match then info.ip = ip_match end
        if mask_match then info.mask = mask_match end
        if router_match then info.router = router_match end
    end
    
    return info
end

-- Update Functions
local function update_wifi_status()
    Sbar.exec([[ipconfig getsummary ]] .. config.wifi_interface .. 
              [[ | awk -F ' SSID : '  '/ SSID : / {print $2}']], 
    function(wifi_name)
        local connected = wifi_name ~= "" and wifi_name ~= nil
        state.wifi:set({
            icon = {
                string = connected and icons.wifi.connected or icons.wifi.disconnected,
            }
        })
    end)
end

local function update_vpn_status()
    Sbar.exec([[scutil --nwi | grep -m1 'utun' | awk '{ print $1 }']], function(vpn)
        state.is_vpn_connected = vpn ~= "" and vpn ~= nil
        if state.is_vpn_connected then
            state.wifi:set({
                icon = {
                    string = icons.wifi.vpn,
                    color = colors.green
                }
            })
        end
    end)
end

local function update_network_info()
    get_wifi_info(function(output)
        local info = parse_wifi_info(output)
        state.ip:set({ label = info.ip })
        state.mask:set({ label = info.mask })
        state.router:set({ label = info.router })
    end)
end

-- Event Handlers
local function on_wifi_change()
    update_wifi_status()
    update_vpn_status()
end

local function on_click(env)
    if env.BUTTON == "right" then
        os.execute("open 'x-apple.systempreferences:com.apple.preference.network'")
        return
    end
    
    animations.custom_animation(
        state.wifi, 
        settings.base_animation, 
        settings.base_animation_duration, 
        config.animation.begin, 
        config.animation.end_state
    )
    
    local should_show = state.wifi:query().popup.drawing == "off"
    state.wifi:set({ popup = { drawing = should_show } })
    
    if should_show then
        update_network_info()
    end
end

local function on_mouse_enter()
    state.wifi:set({ popup = { drawing = true } })
    update_network_info()
end

local function on_mouse_exit()
    state.wifi:set({ popup = { drawing = false } })
end

local function on_copy_click(env)
    local label = Sbar.query(env.NAME).label.value
    os.execute('echo "' .. label .. '" | pbcopy')
    
    local original_label = env.NAME:gsub("^.*%.", "")
    Sbar.set(env.NAME, { 
        label = { 
            string = icons.clipboard, 
            align = "center" 
        } 
    })
    
    Sbar.delay(1, function()
        Sbar.set(env.NAME, { 
            label = { 
                string = original_label, 
                align = "right" 
            } 
        })
    end)
end

-- Initialize
local function init()
    -- Create UI components
    local components = create_ui_components()
    for k, v in pairs(components) do
        state[k] = v
    end

    -- Set up event subscriptions
    state.wifi:subscribe({ "wifi_change", "system_woke" }, on_wifi_change)
    state.wifi:subscribe("mouse.clicked", on_click)
    state.wifi:subscribe("mouse.entered", on_mouse_enter)
    state.wifi:subscribe("mouse.exited.global", on_mouse_exit)

    -- Set up click handlers for info items
    for _, item in ipairs({ state.ip, state.mask, state.router }) do
        item:subscribe("mouse.clicked", on_copy_click)
    end

    -- Initial update
    on_wifi_change()
end

-- Initialize the module
init()

return state.wifi