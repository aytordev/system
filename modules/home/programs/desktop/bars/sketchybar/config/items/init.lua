-- Items initialization module
-- Loads all active bar items in order (left to right)

-- Disabled modules (uncomment to enable):
-- require("items.apple")  -- Apple menu with system info
-- require("items.menus")  -- App menu bar items (requires Accessibility permissions)

-- Active modules
require("items.workspaces") -- AeroSpace workspace indicators
require("items.calendar") -- Date/time display
require("items.vpn") -- VPN status indicator
require("items.widgets") -- System widgets (battery, volume, etc.)
require("items.media") -- Media playback controls
