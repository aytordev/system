local icons = require("icons")
local colors = require("colors")
local animations = require("animations")
local settings = require("settings")

local spaces = {}
local workspaces = {}
local current_workspace = ""

-- Function to update workspace display
local function update_workspaces()
    -- Get current workspace
    Sbar.exec("aerospace list-workspaces --focused", function(focused_ws)
        current_workspace = focused_ws:match("^%s*(.-)%s*$")
        
        -- Get all workspaces
        Sbar.exec("aerospace list-workspaces --all", function(ws_list)
            -- Clear existing spaces
            for _, space in pairs(spaces) do
                space:remove()
            end
            spaces = {}
            
            -- Parse workspaces
            for ws in ws_list:gmatch("[^\n]+") do
                local ws_name = ws:match("^%s*(.-)%s*$")
                if ws_name ~= "" then
                    local icon, color
                    if ws_name == current_workspace then
                        icon, color = icons.focused_space, colors.theme.c8
                    else
                        icon, color = icons.space, colors.theme.fg
                    end
                    
                    -- Create space item
                    local space = Sbar.add("item", "aerospace.space." .. ws_name, {
                        icon = {
                            string = icon,
                            color = color,
                        },
                        label = { drawing = false },
                        background = {
                            color = colors.transparent,
                            shadow = { drawing = false },
                        },
                        padding_left = 0,
                        padding_right = 0,
                        click_script = "aerospace workspace '" .. ws_name:gsub("'", "'\\''") .. "' 2>/dev/null"
                    })
                    
                    spaces[ws_name] = space
                    
                    -- Set up mouse interactions
                    space:subscribe("mouse.clicked", function()
                        -- Update UI immediately for better responsiveness
                        for other_ws_name, s in pairs(spaces) do
                            s:set({
                                icon = {
                                    string = (other_ws_name == ws_name and icons.focused_space or icons.space),
                                    color = (other_ws_name == ws_name and colors.theme.c8 or colors.theme.fg)
                                }
                            })
                        end
                        current_workspace = ws_name  -- Update current workspace
                        
                        -- Trigger animation
                        local begin_set = { y_offset = -2 }
                        local end_set = { y_offset = 0 }
                        animations.custom_animation(
                            space,
                            settings.base_animation,
                            settings.base_animation_duration,
                            begin_set,
                            end_set
                        )
                        
                        -- Force update after a short delay to ensure everything is in sync
                        Sbar.delay(0.5, function()
                            update_workspaces()
                        end)
                    end)
                    
                    space:subscribe("mouse.entered", function()
                        animations.base_hover_animation(space)
                    end)
                    
                    space:subscribe("mouse.exited", function()
                        animations.base_leave_hover_animation(space)
                    end)
                end
            end
        end)
    end)
end

-- Initial update
update_workspaces()

-- Subscribe to workspace changes
local workspace_subscriber = Sbar.add("item", {
    drawing = false,
    updates = true,
})

-- Update workspaces every second to catch changes
workspace_subscriber:subscribe("routine", function()
    update_workspaces()
end)

-- Also update on workspace change events
workspace_subscriber:subscribe("workspace_change", function()
    update_workspaces()
end)

-- Initial update after a short delay to ensure everything is loaded
Sbar.delay(1, function()
    update_workspaces()
end)
