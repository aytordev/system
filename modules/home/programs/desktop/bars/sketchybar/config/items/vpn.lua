local app_icons = require("helpers.app_icons")
local colors = require("colors")
local settings = require("settings")

-- VPN icon (shield/lock icon)
local VPN_ICON = "󰒃" -- Nerd font VPN icon
local VPN_CONNECTED_COLOR = 0xff9ed072 -- Green from colors.lua
local VPN_DISCONNECTED_COLOR = colors.with_alpha(colors.white, 0.3)

local vpn = sbar.add("item", "vpn", {
	position = "right",
	background = { drawing = false },
	icon = {
		string = VPN_ICON,
		color = VPN_DISCONNECTED_COLOR,
		font = {
			family = settings.font_icon.text,
			style = settings.font_icon.style_map["Bold"],
			size = settings.font_icon.size,
		},
	},
	label = { drawing = false },
	update_freq = 10,
	popup = {
		align = "center",
		height = 30,
	},
})

-- Add WireGuard item to popup
local vpn_wireguard = sbar.add("item", {
	position = "popup.vpn",
	background = { drawing = false },
	icon = {
		string = app_icons["Wireguard"] or "󱇱",
		font = "sketchybar-app-font:Regular:16.0",
	},
	label = {
		string = "WireGuard",
	},
})

vpn_wireguard:subscribe("mouse.entered", function()
	vpn_wireguard:set({ background = { drawing = true, color = 0x33ffffff } })
end)

vpn_wireguard:subscribe("mouse.exited", function()
	vpn_wireguard:set({ background = { drawing = false } })
end)

vpn_wireguard:subscribe("mouse.clicked", function()
	sbar.exec(
		'if ! pgrep -x "WireGuard" > /dev/null 2>&1; then '
			.. "open -a WireGuard; else "
			.. "osascript -e 'tell application \"System Events\" to "
			.. 'tell process "WireGuard" to click menu bar item 1 of menu bar 2\' &>/dev/null; fi'
	)
	sbar.exec("sketchybar --set vpn popup.drawing=off")
end)

-- Add GlobalProtect item to popup
local vpn_globalprotect = sbar.add("item", {
	position = "popup.vpn",
	background = { drawing = false },
	icon = {
		string = app_icons["Global Protect"] or "󰒄",
		font = "sketchybar-app-font:Regular:16.0",
	},
	label = {
		string = "GlobalProtect",
	},
})

vpn_globalprotect:subscribe("mouse.entered", function()
	vpn_globalprotect:set({ background = { drawing = true, color = 0x33ffffff } })
end)

vpn_globalprotect:subscribe("mouse.exited", function()
	vpn_globalprotect:set({ background = { drawing = false } })
end)

vpn_globalprotect:subscribe("mouse.clicked", function()
	sbar.exec(
		"osascript -e 'tell application \"System Events\" to "
			.. "tell process \"GlobalProtect\" to click menu bar item 1 of menu bar 2' &>/dev/null"
	)
	sbar.exec("sketchybar --set vpn popup.drawing=off")
end)

-- Toggle popup on click
vpn:subscribe("mouse.clicked", function()
	sbar.exec("sketchybar --set vpn popup.drawing=toggle")
end)

vpn:subscribe("mouse.exited.global", function()
	vpn:set({ popup = { drawing = false } })
end)

local function check_vpn_status()
	local is_connected = false
	local vpn_name = ""

	-- Check WireGuard via scutil
	sbar.exec("scutil --nc list", function(output)
		if output:match("%(Connected%).*com%.wireguard") then
			is_connected = true
			vpn_name = "WireGuard"
		end

		if output:match("%(Connected%).*com%.f5%.access") then
			is_connected = true
			vpn_name = vpn_name ~= "" and (vpn_name .. " + F5") or "F5 VPN"
		end

		-- Check for GlobalProtect via IPv4 default route
		-- Only consider connected if default IPv4 route goes through utun interface
		sbar.exec("netstat -rn | grep '^default' | grep -v 'fe80\\|link#'", function(route_output)
			if route_output and route_output:match("utun%d+") then
				-- Default IPv4 route goes through utun interface - VPN is active
				is_connected = true
				local utun_if = route_output:match("utun%d+")
				if utun_if then
					vpn_name = vpn_name ~= "" and (vpn_name .. " + GlobalProtect") or "GlobalProtect"
				end
			end

			-- Update icon color based on final status
			vpn:set({
				icon = {
					color = is_connected and VPN_CONNECTED_COLOR or VPN_DISCONNECTED_COLOR,
				},
			})
		end)
	end)
end

-- Subscribe to network events for real-time updates
vpn:subscribe({
	"wifi_change", -- When WiFi connects/disconnects
	"network_update", -- General network changes
	"system_woke", -- VPN might disconnect during sleep
	"forced", -- Manual triggers
	"routine", -- Periodic fallback every 2 minutes
}, check_vpn_status)

-- Initial check
check_vpn_status()
