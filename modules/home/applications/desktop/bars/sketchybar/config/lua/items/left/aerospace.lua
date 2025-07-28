-- Aerospace Workspace Manager for SketchyBar
-- Manages workspace visualization and interaction with Aerospace window manager

-- Dependencies
local icons = require("icons")
local colors = require("colors")
local animations = require("animations")
local settings = require("settings")

-- Constants
local UPDATE_DELAY = 0.5      -- Delay for UI updates after changes (seconds)
local POLLING_INTERVAL = 1    -- Workspace polling interval (seconds)

-- Icon configuration
local ICON_CONFIG = {
    focused = {
        size = 14.0 * 1.15,   -- Larger size for focused workspace
        color = colors.theme.c8,
        icon = icons.focused_space
    },
    unfocused = {
        size = 12.0,          -- Default size for unfocused workspaces
        color = colors.theme.fg,
        icon = icons.space
    }
}

-- Application state
local state = {
    spaces = {},
    current_workspace = "",
    workspace_subscriber = nil
}

--- Escapes a workspace name for use in shell commands
-- @param name string Workspace name to escape
-- @return string Escaped name
local function escape_workspace_name(name)
    return name:gsub("'", "'\\''")
end

--- Creates a new workspace item in the bar
-- @param ws_name string Name of the workspace
-- @param is_focused boolean Whether this workspace is currently focused
-- @return table Reference to the created item
local function create_workspace_item(ws_name, is_focused)
    local config = is_focused and ICON_CONFIG.focused or ICON_CONFIG.unfocused
    
    local item = Sbar.add("item", "aerospace.space." .. ws_name, {
        icon = { 
            string = config.icon,
            color = config.color,
            font = { 
                size = config.size
            }
        },
        label = { drawing = false },
        background = { color = colors.transparent, shadow = { drawing = false } },
        padding_left = 0,
        padding_right = 0,
        click_script = string.format("aerospace workspace '%s' 2>/dev/null", escape_workspace_name(ws_name))
    })
    
    return item
end

--- Updates the visual appearance of a workspace item
-- @param item table Reference to the item to update
-- @param is_focused boolean Whether the workspace is now focused
local function update_workspace_appearance(item, is_focused)
    local config = is_focused and ICON_CONFIG.focused or ICON_CONFIG.unfocused
    item:set({
        icon = {
            string = config.icon,
            color = config.color,
            font = { 
                size = config.size
            }
        }
    })
end

--- Sets up event handlers for a workspace item
-- @param item table Reference to the item
-- @param ws_name string Name of the workspace
local function setup_workspace_handlers(item, ws_name)
    -- Click handler for switching workspaces
    item:subscribe("mouse.clicked", function()
        -- Update UI immediately for better responsiveness
        for other_ws_name, other_item in pairs(state.spaces) do
            update_workspace_appearance(other_item, other_ws_name == ws_name)
        end
        state.current_workspace = ws_name
        
        -- Click animation
        local begin_set = { y_offset = -2 }
        local end_set = { y_offset = 0 }
        animations.custom_animation(
            item,
            settings.base_animation,
            settings.base_animation_duration,
            begin_set,
            end_set
        )
        
        -- Delayed update to ensure sync with Aerospace
        Sbar.delay(UPDATE_DELAY, update_workspaces)
    end)
    
    -- Hover effects
    item:subscribe("mouse.entered", function()
        animations.base_hover_animation(item)
    end)
    
    item:subscribe("mouse.exited", function()
        animations.base_leave_hover_animation(item)
    end)
end

--- Updates the list of workspaces from Aerospace
function update_workspaces()
    -- Get currently focused workspace
    Sbar.exec("aerospace list-workspaces --focused", function(focused_ws)
        if focused_ws then
            state.current_workspace = focused_ws:match("^%s*(.-)%s*$")
        end
        
        -- Get all workspaces
        Sbar.exec("aerospace list-workspaces --all", function(ws_list)
            if not ws_list then return end
            
            -- Create a set of current workspaces for comparison
            local current_workspaces = {}
            for ws in ws_list:gmatch("[^\n]+") do
                local ws_name = ws:match("^%s*(.-)%s*$")
                if ws_name and ws_name ~= "" then
                    current_workspaces[ws_name] = true
                end
            end
            
            -- Remove workspaces that no longer exist
            for ws_name, item in pairs(state.spaces) do
                if not current_workspaces[ws_name] then
                    if item and type(item) == "table" and item.remove then
                        item:remove()
                        state.spaces[ws_name] = nil
                    end
                end
            end
            
            -- Add or update existing workspaces
            for ws in ws_list:gmatch("[^\n]+") do
                local ws_name = ws:match("^%s*(.-)%s*$")
                if ws_name and ws_name ~= "" then
                    local is_focused = ws_name == state.current_workspace
                    
                    if state.spaces[ws_name] then
                        -- Update existing workspace
                        update_workspace_appearance(state.spaces[ws_name], is_focused)
                    else
                        -- Create new workspace item
                        local item = create_workspace_item(ws_name, is_focused)
                        setup_workspace_handlers(item, ws_name)
                        state.spaces[ws_name] = item
                    end
                end
            end
        end)
    end)
end

--- Initializes the workspace manager
local function init()
    -- Create hidden subscriber for workspace events
    state.workspace_subscriber = Sbar.add("item", {
        drawing = false,
        updates = true,
    })
    
    -- Set up periodic updates
    state.workspace_subscriber:subscribe("routine", function()
        update_workspaces()
    end)
    
    -- Update on workspace changes
    state.workspace_subscriber:subscribe("workspace_change", update_workspaces)
    
    -- Initial update after a short delay
    Sbar.delay(1, update_workspaces)
end

-- Initialize the workspace manager
init()
