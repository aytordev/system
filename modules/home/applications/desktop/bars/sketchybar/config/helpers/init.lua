package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

local script_path = debug.getinfo(1, "S").source:match("@?(.*/)")
local config_path = script_path:gsub("/helpers/?$", "")

package.path = package.path .. ";" .. config_path .. "/?.lua"
package.path = package.path .. ";" .. config_path .. "/lua/?.lua"

local function safe_require(module)
    local status, result = pcall(require, module)
    if not status then
        print("❌ Error loading module: " .. module .. ": " .. tostring(result))
        return nil
    end
    print("✅ Loaded module: " .. module)
    return result
end

return {
    safe_require = safe_require,
    config_path = config_path
}