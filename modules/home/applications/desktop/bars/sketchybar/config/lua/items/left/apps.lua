local colors = require("colors")
local animations = require("animations")
-- Minimal JSON parser for SketchyBar environment
local json = {}

-- Helper function to check if a character is whitespace
local function isWhitespace(c)
    return c == ' ' or c == '\t' or c == '\n' or c == '\r'
end

-- Parse a JSON string
function json.decode(str, position, nullValue, objectmeta, arrayMeta)
    position = position or 1
    nullValue = nullValue or nil
    
    -- Skip whitespace
    while position <= #str and isWhitespace(str:sub(position, position)) do
        position = position + 1
    end
    
    if position > #str then return nil, "unexpected end of string" end
    
    local firstChar = str:sub(position, position)
    
    -- Parse object
    if firstChar == '{' then
        local obj = {}
        position = position + 1
        
        while true do
            -- Skip whitespace
            while position <= #str and isWhitespace(str:sub(position, position)) do
                position = position + 1
            end
            
            if position > #str then return nil, "unexpected end of string in object" end
            
            if str:sub(position, position) == '}' then
                return obj, position + 1
            end
            
            -- Parse key
            local key, newPos = json.decode(str, position)
            if not key then return nil, "invalid key in object" end
            position = newPos
            
            -- Skip whitespace
            while position <= #str and isWhitespace(str:sub(position, position)) do
                position = position + 1
            end
            
            if position > #str or str:sub(position, position) ~= ':' then
                return nil, "expected ':' after key in object"
            end
            
            position = position + 1
            
            -- Parse value
            local value, newPos = json.decode(str, position)
            if not value then return nil, "invalid value in object" end
            position = newPos
            
            obj[key] = value
            
            -- Skip whitespace
            while position <= #str and isWhitespace(str:sub(position, position)) do
                position = position + 1
            end
            
            if position > #str then return nil, "unexpected end of string in object" end
            
            local nextChar = str:sub(position, position)
            if nextChar == '}' then
                return obj, position + 1
            elseif nextChar ~= ',' then
                return nil, "expected ',' or '}' in object"
            end
            
            position = position + 1
        end
    
    -- Parse array
    elseif firstChar == '[' then
        local arr = {}
        position = position + 1
        local i = 1
        
        while true do
            -- Skip whitespace
            while position <= #str and isWhitespace(str:sub(position, position)) do
                position = position + 1
            end
            
            if position > #str then return nil, "unexpected end of string in array" end
            
            if str:sub(position, position) == ']' then
                return arr, position + 1
            end
            
            -- Parse value
            local value, newPos = json.decode(str, position)
            if not value then return nil, "invalid value in array" end
            position = newPos
            
            arr[i] = value
            i = i + 1
            
            -- Skip whitespace
            while position <= #str and isWhitespace(str:sub(position, position)) do
                position = position + 1
            end
            
            if position > #str then return nil, "unexpected end of string in array" end
            
            local nextChar = str:sub(position, position)
            if nextChar == ']' then
                return arr, position + 1
            elseif nextChar ~= ',' then
                return nil, "expected ',' or ']' in array"
            end
            
            position = position + 1
        end
    
    -- Parse string
    elseif firstChar == '"' then
        position = position + 1
        local result = ""
        local escaped = false
        
        while position <= #str do
            local c = str:sub(position, position)
            
            if escaped then
                if c == '"' then
                    result = result .. '"'
                elseif c == '\\' then
                    result = result .. '\\'
                elseif c == '/' then
                    result = result .. '/'
                elseif c == 'b' then
                    result = result .. '\b'
                elseif c == 'f' then
                    result = result .. '\f'
                elseif c == 'n' then
                    result = result .. '\n'
                elseif c == 'r' then
                    result = result .. '\r'
                elseif c == 't' then
                    result = result .. '\t'
                else
                    -- Skip unknown escape sequence
                    result = result .. c
                end
                escaped = false
            elseif c == '\\' then
                escaped = true
            elseif c == '"' then
                return result, position + 1
            else
                result = result .. c
            end
            
            position = position + 1
        end
        
        return nil, "unterminated string"
    
    -- Parse number
    elseif firstChar:match("[-0-9.]") then
        local start = position
        
        -- Optional minus sign
        if str:sub(position, position) == '-' then
            position = position + 1
        end
        
        -- Integer part
        while position <= #str and str:sub(position, position):match("%d") do
            position = position + 1
        end
        
        -- Fractional part
        if position <= #str and str:sub(position, position) == '.' then
            position = position + 1
            while position <= #str and str:sub(position, position):match("%d") do
                position = position + 1
            end
        end
        
        -- Exponent part
        if position <= #str and (str:sub(position, position):lower() == 'e') then
            position = position + 1
            if position <= #str and (str:sub(position, position) == '+' or str:sub(position, position) == '-') then
                position = position + 1
            end
            while position <= #str and str:sub(position, position):match("%d") do
                position = position + 1
            end
        end
        
        local numStr = str:sub(start, position - 1)
        local num = tonumber(numStr)
        if not num then return nil, "invalid number: " .. numStr end
        return num, position
    
    -- Parse true
    elseif str:sub(position, position + 3) == 'true' then
        return true, position + 4
    
    -- Parse false
    elseif str:sub(position, position + 4) == 'false' then
        return false, position + 5
    
    -- Parse null
    elseif str:sub(position, position + 3) == 'null' then
        return nullValue, position + 4
    end
    
    return nil, "unexpected character: " .. firstChar
end

-- Helper function to parse a complete JSON string
function json.parse(str)
    local result, pos = json.decode(str)
    if not result then
        return nil, pos -- pos contains the error message
    end
    
    -- Skip any remaining whitespace
    while pos <= #str and isWhitespace(str:sub(pos, pos)) do
        pos = pos + 1
    end
    
    if pos <= #str then
        return nil, "unexpected character at position " .. pos
    end
    
    return result
end

local app_icons = require("helpers.icon_map")

local apps = {}
local icon_cache = {}

--- Get the appropriate icon for an application
-- @param appName string The name of the application
-- @return string The icon to display
local function getIconForApp(appName)
    if not appName then
        print("⚠️ App name is nil, using default icon")
        return app_icons["Default"] -- Default icon if none found
    end
    
    -- Clean up the app name (remove version numbers, extra spaces, etc.)
    local cleanName = appName
        :gsub(" %d+%.%d+.*$", "")  -- Remove version numbers (e.g., "App 1.2.3" -> "App")
        :gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    
    -- Check cache first
    if icon_cache[cleanName] then
        return icon_cache[cleanName]
    end
    
    -- Try exact match first
    local icon = app_icons[cleanName]
    
    -- If no exact match, try case-insensitive match
    if not icon then
        for key, value in pairs(app_icons) do
            if key:lower() == cleanName:lower() then
                icon = value
                break
            end
        end
    end
    
    -- Fall back to default icon if still not found
    if not icon then
        print(string.format("⚠️ No icon found for app: %s (cleaned as: %s), using default", appName, cleanName))
        icon = app_icons["Default"] -- Default icon if none found
    end
    
    -- Cache the result
    icon_cache[cleanName] = icon
    return icon
end

--- Parse the output of the aerospace list-windows command
-- @param output string The raw output from the command
-- @return table The parsed windows data
local function parseWindowsOutput(output)
    print("🔍 Parsing windows output...")
    print("Raw output from aerospace:", output) -- Debug log
    
    if not output or output == "" then
        print("⚠️ Empty output from aerospace command")
        return {}
    end
    
    -- Check if the output is in text format (starts with a number and contains pipes)
    if output:match("^%s*%d+") and output:match("|") then
        print("📝 Detected text format, parsing...")
        local windows = {}
        
        -- Process each line
        for line in output:gmatch("[^\r\n]+") do
            -- Extract window ID, app name, and title using pattern matching
            local id, app_name, title = line:match("^%s*(%d+)%s*|%s*([^|]+)|%s*(.*)%s*$")
            
            if id and app_name then
                -- Clean up the app name and title (remove extra whitespace)
                app_name = app_name:match("^%s*(.-)%s*$")
                title = title and title:match("^%s*(.-)%s*$") or ""
                
                print(string.format("  - Found window: ID=%s, App=%s, Title=%s", id, app_name, title))
                
                -- Add to windows table
                table.insert(windows, {
                    ["window-id"] = tonumber(id),
                    ["app-name"] = app_name,
                    ["title"] = title
                })
            end
        end
        
        print(string.format("✅ Successfully parsed %d windows from text format", #windows))
        return windows
    end
    
    -- If not in text format, try to parse as JSON
    print("🔍 Trying to parse as JSON...")
    local success, result, err = pcall(function()
        return json.parse(output)
    end)
    
    if not success then
        print("Error in json.parse:", result)
        return {}
    end
    
    if not result then
        print("Failed to parse JSON:", err or "unknown error")
        return {}
    end
    
    if type(result) ~= "table" then
        print("Warning: Expected table but got", type(result))
        return {}
    end
    
    print("Successfully parsed", #result, "windows")
    return result
end

--- Get the current workspace name
-- @param callback function Function to call with the workspace name
local function getCurrentWorkspace(callback)
    print("🔄 Fetching current workspace...")  -- Debug log
    
    -- Use the same pattern as aerospace.lua with callbacks
    Sbar.exec("aerospace list-workspaces --focused", function(focused_ws)
        if not focused_ws or focused_ws == "" then
            print("⚠️ Empty result from 'aerospace list-workspaces --focused'")
            -- Try alternative approach if the first one fails
            Sbar.exec("aerospace list-workspaces --all", function(ws_list)
                if not ws_list or ws_list == "" then
                    print("❌ Could not get workspace list from Aerospace")
                    callback("")
                    return
                end
                
                -- Find the focused workspace in the list
                for ws in ws_list:gmatch("[^\r\n]+") do
                    if ws:match("%*$") then  -- Focused workspace has a * at the end
                        local workspace = ws:match("^%s*(.-)%s*%*?%s*$")
                        print("✅ Found focused workspace:", workspace)
                        callback(workspace)
                        return
                    end
                end
                
                print("⚠️ No focused workspace found in list")
                callback("")
            end)
            return
        end
        
        -- Clean up the result (remove any trailing whitespace or markers)
        local workspace = focused_ws:gsub("^%s*(.-)%s*%*?%s*$", "%1")
        print("✅ Current workspace:", workspace)
        callback(workspace)
    end)
end

--- Get windows for a specific workspace
-- @param workspace string The workspace name
-- @return table List of windows
local function getWindowsForWorkspace(workspace, callback)
    print("🔄 Getting windows for workspace:", workspace)
    local cmd = string.format('aerospace list-windows --workspace "%s"', workspace)
    print("🔧 Executing command:", cmd)
    
    Sbar.exec(cmd, function(output, error_type, error_msg)
        if error_type ~= 0 or not output then
            print("❌ Error executing command:", error_msg or "Unknown error")
            callback({})
            return
        end
        
        print("✅ Raw output:", output)
        local windows = parseWindowsOutput(output)
        print("✅ Parsed windows:", #windows)
        callback(windows)
    end)
end

--- Get the currently focused window
-- @return table The focused window data or nil
local function getFocusedWindow()
    -- Primero obtenemos el workspace actual
    local focused_ws = Sbar.exec("aerospace list-workspaces --focused")
    if not focused_ws or focused_ws == "" then
        return nil
    end
    
    -- Luego obtenemos las ventanas del workspace actual
    local windows_output = Sbar.exec("aerospace list-windows --workspace " .. focused_ws)
    if not windows_output or windows_output == "" then
        return nil
    end
    
    -- Parseamos las ventanas
    local windows = parseWindowsOutput(windows_output)
    if not windows or #windows == 0 then
        return nil
    end
    
    -- Asumimos que la primera ventana es la que tiene el foco
    -- (esto es una simplificación, podrías necesitar una lógica más sofisticada)
    return windows[1]
end

--- Draw the app icons for the current workspace
local function drawApps()
    getCurrentWorkspace(function(workspace)
        if not workspace or workspace == "" then 
            print("⚠️ No workspace found, skipping app drawing")
            return 
        end
        
        print("🔄 Drawing apps for workspace:", workspace)
        getWindowsForWorkspace(workspace, function(windows)
            -- Limpiar apps existentes de manera segura
            for id, app in pairs(apps) do
                if app and type(app) == "table" and app.remove then
                    local success, err = pcall(function()
                        app:remove()
                    end)
                    if not success then
                        print("⚠️ Error removing app " .. tostring(id) .. ": " .. tostring(err))
                    end
                end
                apps[id] = nil
            end
            
            -- Si no hay ventanas, salir
            if not windows or #windows == 0 then
                print("ℹ️ No apps found in workspace:", workspace)
                return
            end
            
            -- Procesar cada ventana
            for _, w in ipairs(windows) do
                if not w["app-name"] or not w["window-id"] then
                    print("⚠️ Invalid window data:", w)
                    goto continue
                end
                
                local unique_id = w["app-name"] .. "-" .. w["window-id"]
                print("  - Adding app:", w["app-name"], "(ID:", w["window-id"], ")")
                
                local app = Sbar.add("item", unique_id, {
                    icon = { drawing = false },
                    label = {
                        string = getIconForApp(w["app-name"]),
                        font = "sketchybar-app-font:Regular:14.0",
                        highlight = false,
                        highlight_color = colors.theme.c8,
                    },
                    click_script = string.format('aerospace focus --window-id %d', math.floor(w["window-id"])),
                })
                
                apps[unique_id] = app
                app:subscribe("mouse.clicked", function()
                    animations.base_click_animation(app)
                end)
                
                ::continue::
            end
            
            -- Resaltar ventana enfocada
            local focused = getFocusedWindow()
            if focused then
                highlightApp(focused)
            end
        end)
    end)
end

--- Highlight the focused application
-- @param window table The window data to highlight or nil to clear highlights
local function highlightApp(window)
    if not window then
        -- Clear all highlights if no window is focused
        for _, app in pairs(apps) do
            app:set({ label = { highlight = false } })
        end
        return
    end
    
    local focused_id = window["app-name"] .. "-" .. window["window-id"]
    for id, app in pairs(apps) do
        app:set({ label = { highlight = (id == focused_id) } })
    end
end

--- Update the apps display
local function updateApps()
    -- Clear existing apps
    for id, app in pairs(apps) do
        if app and type(app) == "table" and app.name then
            -- Solo intentar eliminar si el elemento existe
            local success, err = pcall(function()
                Sbar.remove(app.name)
            end)
            if not success then
                print("⚠️ Error removing item " .. tostring(app.name) .. ": " .. tostring(err))
            end
        end
    end
    apps = {}
    
    -- Redraw apps for current workspace
    drawApps()
end

-- Initialize the apps display
updateApps()

-- Subscribe to workspace and focus changes
local apps_subscriber = Sbar.add("item", {
    drawing = false,
    updates = true,
})

-- Handle workspace changes
apps_subscriber:subscribe("workspace_change", function()
    Sbar.delay(0.1, function()
        updateApps()
    end)
end)

-- Handle focus changes with async pattern
apps_subscriber:subscribe("routine", function()
    getCurrentWorkspace(function()
        local focused = getFocusedWindow()
        highlightApp(focused)
    end)
end)

-- Also update on window focus events
apps_subscriber:subscribe("window_focus", function()
    Sbar.delay(0.1, function()
        getCurrentWorkspace(function()
            local focused = getFocusedWindow()
            highlightApp(focused)
        end)
    end)
end)

-- Update when windows are closed
apps_subscriber:subscribe("window_close", function(env)
    print("ℹ️ Window closed, updating apps...")
    Sbar.delay(0.1, function()
        updateApps()
    end)
end)

-- Also update when windows are opened
apps_subscriber:subscribe("window_open", function(env)
    print("ℹ️ New window opened, updating apps...")
    Sbar.delay(0.1, function()
        updateApps()
    end)
end)

-- Initial draw
Sbar.delay(1, function()
    print("🚀 Initializing apps module...")
    drawApps()
end)
