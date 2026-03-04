local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local constants = require("nix_constants")

-- Configuration from Nix
local ws_config = (constants.items and constants.items.workspaces) or {}
local bounce_animation = ws_config.bounce_animation ~= false
local deferred_loading = ws_config.deferred_loading ~= false

-- Workspace icons and colors (Kanagawa palette)
local space_icons = icons.workspaces
local space_colors = {
	B = colors.blue, C = colors.magenta, D = colors.pink,
	W = colors.cyan, S = colors.green, O = colors.yellow,
}

-- Load AeroSpaceLua
local Aerospace = require("helpers.aerospace")
local aerospace = nil

-- Root is used to handle event subscriptions
local root = sbar.add("item", { drawing = false, background = { drawing = false } })
local workspaces = {}
local initialized = false

-- Build NSScreen ID to SketchyBar display position mapping
local nsscreen_to_display = {}
local log_file = "/tmp/sketchybar_workspaces.log"

local function log(msg)
	local f = io.open(log_file, "a")
	if f then
		f:write(os.date("%H:%M:%S") .. " " .. msg .. "\n")
		f:close()
	end
end

-- Build the mapping synchronously
local function build_monitor_mapping()
	local monitors_output = aerospace:list_monitors()
	local monitor_names_by_position = {}
	for line in monitors_output:gmatch("[^\r\n]+") do
		local position, name = line:match("(%d+)%s*|%s*(.+)")
		if position and name then
			monitor_names_by_position[name:match("^%s*(.-)%s*$")] = tonumber(position)
		end
	end

	local workspace_info = aerospace:query_workspaces()
	local processed = {}
	nsscreen_to_display = {}
	for _, ws in ipairs(workspace_info) do
		local nsscreen_id = math.floor(ws["monitor-appkit-nsscreen-screens-id"])
		local monitor_name = ws["monitor-name"] or ""
		monitor_name = monitor_name:match("^%s*(.-)%s*$")

		if not processed[nsscreen_id] and monitor_names_by_position[monitor_name] then
			nsscreen_to_display[nsscreen_id] = monitor_names_by_position[monitor_name]
			processed[nsscreen_id] = true
			log(string.format(
				"[MAPPING] NSScreen %d (%s) -> display %d",
				nsscreen_id, monitor_name, nsscreen_to_display[nsscreen_id]
			))
		end
	end
	log("[MAPPING] Complete")
end

-- AeroSpace mode indicator
local mode_indicator = sbar.add("item", "aerospace.mode", {
	position = "left",
	background = { drawing = false },
	icon = {
		string = "M",
		color = colors.green,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
		},
	},
	label = { drawing = false },
})

local function update_mode_indicator()
	if not aerospace then
		return
	end
	aerospace:list_modes(true, function(current_mode)
		current_mode = current_mode:match("^%s*(.-)%s*$")

		local icon_str = "M"
		local icon_color = colors.green

		if current_mode == "service" then
			icon_str = "S"
			icon_color = colors.yellow
		end

		mode_indicator:set({
			icon = {
				string = icon_str,
				color = icon_color,
			},
		})
	end)
end

mode_indicator:subscribe("aerospace_mode_change", function()
	update_mode_indicator()
end)

-- Track previously focused workspace for bounce animation
local prev_focused = nil

-- Helper function to get windows grouped by workspace with callbacks
local function withWindows(f)
	aerospace:list_all_windows(function(windows)
		local open_windows = {}
		for _, window in ipairs(windows) do
			local workspace = window.workspace
			local app = window["app-name"]
			if open_windows[workspace] == nil then
				open_windows[workspace] = {}
			end
			table.insert(open_windows[workspace], app)
		end

		aerospace:list_current(function(focused_workspace)
			focused_workspace = focused_workspace:match("^%s*(.-)%s*$")

			aerospace:query_workspaces(function(workspace_info)
				local visible_workspaces = {}
				local workspace_monitors = {}

				for _, ws in ipairs(workspace_info) do
					if ws["workspace-is-visible"] then
						table.insert(visible_workspaces, ws)
					end
					local nsscreen_id = math.floor(ws["monitor-appkit-nsscreen-screens-id"])
					local display_id = nsscreen_to_display[nsscreen_id]
					if not display_id then
						log(string.format("[WARNING] No mapping for NSScreen %d (ws %s)", nsscreen_id, ws.workspace))
						display_id = nsscreen_id
					end
					workspace_monitors[ws.workspace] = display_id
				end

				f({
					open_windows = open_windows,
					focused_workspace = focused_workspace,
					visible_workspaces = visible_workspaces,
					workspace_monitors = workspace_monitors,
				})
			end)
		end)
	end)
end

local function updateWindow(workspace_index, args)
	local open_windows = args.open_windows[workspace_index] or {}
	local focused_workspace = args.focused_workspace
	local visible_workspaces = args.visible_workspaces
	local workspace_monitors = args.workspace_monitors

	local icon_line = ""
	local no_app = #open_windows == 0
	for _, open_window in ipairs(open_windows) do
		local lookup = app_icons[open_window]
		local icon = ((lookup == nil) and app_icons["Default"] or lookup)
		if icon_line ~= "" then
			icon_line = icon_line .. " "
		end
		icon_line = icon_line .. icon
	end

	local is_focused = workspace_index == focused_workspace

	-- Check if this workspace is visible
	local is_visible = false
	for _, visible_ws in ipairs(visible_workspaces) do
		if workspace_index == visible_ws.workspace then
			is_visible = true
			break
		end
	end

	-- Bounce animation when workspace becomes focused
	if bounce_animation and is_focused and prev_focused ~= workspace_index and workspaces[workspace_index] then
		sbar.animate("sin", 10, function()
			workspaces[workspace_index]:set({ y_offset = 6 })
			sbar.animate("sin", 10, function()
				workspaces[workspace_index]:set({ y_offset = 0 })
			end)
		end)
	end

	sbar.animate("tanh", 30, function()
		if no_app and not is_visible and not is_focused then
			workspaces[workspace_index]:set({ drawing = false })
			return
		end

		if no_app then
			icon_line = "—"
		end

		workspaces[workspace_index]:set({
			drawing = true,
			icon = { highlight = is_focused },
			label = {
				string = icon_line,
				highlight = is_focused,
			},
			display = workspace_monitors[workspace_index],
		})
	end)
end

local function updateWindows()
	withWindows(function(args)
		for workspace_index, _ in pairs(workspaces) do
			updateWindow(workspace_index, args)
		end
		prev_focused = args.focused_workspace
	end)
end

local function updateWorkspaceMonitor()
	aerospace:query_workspaces(function(workspace_info)
		for _, ws in ipairs(workspace_info) do
			local space_index = ws.workspace
			local nsscreen_id = math.floor(ws["monitor-appkit-nsscreen-screens-id"])
			local display_id = nsscreen_to_display[nsscreen_id] or nsscreen_id
			if workspaces[space_index] then
				workspaces[space_index]:set({ display = display_id })
			end
		end
	end)
end

-- ── Curtain Effect Support ──────────────────────────────────────────────
-- When menus expand, workspaces fade out. When menus collapse, fade back in.

root:subscribe("fade_out_spaces", function()
	sbar.animate("tanh", 30, function()
		for _, ws in pairs(workspaces) do
			ws:set({
				width = 0,
				icon = { color = colors.transparent },
				label = { color = colors.transparent },
			})
		end
		mode_indicator:set({
			width = 0,
			icon = { color = colors.transparent },
		})
	end)
end)

root:subscribe("fade_in_spaces", function()
	-- Instant reset to zero state (prevents glitches from stale sizes)
	for _, ws in pairs(workspaces) do
		ws:set({
			width = 0,
			icon = { color = colors.transparent },
			label = { color = colors.transparent },
		})
	end
	mode_indicator:set({
		width = 0,
		icon = { color = colors.transparent },
	})

	-- Then animate expansion
	sbar.animate("tanh", 30, function()
		for _, ws in pairs(workspaces) do
			ws:set({
				width = "dynamic",
				icon = { color = colors.with_alpha(colors.white, 0.3) },
				label = { color = colors.with_alpha(colors.white, 0.3) },
			})
		end
		mode_indicator:set({
			width = "dynamic",
			icon = { color = colors.green },
		})
	end)
	-- Restore proper highlight state
	updateWindows()
end)

-- ── Initialization ──────────────────────────────────────────────────────

local function initialize_workspaces()
	if initialized then
		return
	end
	initialized = true

	build_monitor_mapping()
	update_mode_indicator()

	aerospace:query_workspaces(function(workspace_info)
		for _, entry in ipairs(workspace_info) do
			local workspace_index = entry.workspace
			local ws_icon = space_icons[workspace_index] or workspace_index
			local ws_color = space_colors[workspace_index] or colors.white

			local workspace = sbar.add("item", {
				click_script = "aerospace workspace " .. workspace_index .. " 2>/dev/null",
				drawing = false,
				background = { drawing = false },
				icon = {
					color = colors.with_alpha(ws_color, 0.3),
					drawing = true,
					font = { family = settings.font.numbers },
					highlight_color = ws_color,
					string = ws_icon,
				},
				label = {
					color = colors.with_alpha(ws_color, 0.3),
					drawing = true,
					font = "sketchybar-app-font:Regular:16.0",
					highlight_color = ws_color,
				},
			})

			workspaces[workspace_index] = workspace
		end

		updateWindows()
		updateWorkspaceMonitor()

		root:subscribe("aerospace_workspace_change", function()
			updateWindows()
		end)

		root:subscribe("front_app_switched", function()
			updateWindows()
		end)

		root:subscribe("display_change", function()
			build_monitor_mapping()
			updateWorkspaceMonitor()
			updateWindows()
		end)

		aerospace:list_current(function(focused_workspace)
			focused_workspace = focused_workspace:match("^%s*(.-)%s*$")
			prev_focused = focused_workspace
			if workspaces[focused_workspace] then
				workspaces[focused_workspace]:set({
					icon = { highlight = true },
					label = { highlight = true },
				})
			end
		end)
	end)
end

-- ── Deferred or Immediate Loading ───────────────────────────────────────

if deferred_loading then
	-- Register custom event for deferred loading
	sbar.add("event", "aerospace_is_ready")

	-- Background poll: wait for AeroSpace to respond
	sbar.exec(
		'while ! aerospace list-workspaces --all 2>/dev/null; do sleep 0.5; done && sketchybar --trigger aerospace_is_ready',
		function() end
	)

	-- When AeroSpace is ready, connect and initialize
	root:subscribe("aerospace_is_ready", function()
		local success, result = pcall(function()
			return Aerospace.new()
		end)
		if success and result:is_initialized() then
			aerospace = result
			initialize_workspaces()
		end
	end)
else
	-- Blocking retry loop (original behavior)
	local max_retries = 30
	local retry_count = 0
	while retry_count < max_retries do
		local success, result = pcall(function()
			return Aerospace.new()
		end)
		if success and result:is_initialized() then
			aerospace = result
			break
		else
			os.execute("sleep 0.5")
			retry_count = retry_count + 1
		end
	end

	if aerospace and aerospace:is_initialized() then
		initialize_workspaces()
	end
end
