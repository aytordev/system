local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local animations = require("animations")

-- Function to get OS-specific icon
local function get_os_icon()
  local handle = io.popen('uname -s')
  local os_name = handle:read('*a'):gsub('%s+', '')
  handle:close()

  if os_name == 'Darwin' then
    return icons.apple
  elseif os_name == 'Linux' then
    -- Check if it's Arch Linux
    local arch_handle = io.popen('cat /etc/os-release 2>/dev/null | grep -i "arch" || echo ""')
    local is_arch = arch_handle:read('*a')
    arch_handle:close()
    
    if is_arch and is_arch ~= '' then
      return icons.arch
    end
    return icons.linux or '🐧' -- Fallback to generic Linux icon or penguin emoji
  end
  return '💻' -- Fallback icon for unknown OS
end

local logo = Sbar.add("item", {
	icon = {
		string = get_os_icon(),
		color = colors.theme.c10,
		y_offset = 1,
		align = "center",
		font = {
			size = settings.font.size * 1.15,
		},
	},
	label = { drawing = false },
	background = {
		color = colors.theme.c2,
	},
	padding_left = settings.group_paddings,
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

logo:subscribe("mouse.clicked", function()
	animations.base_click_animation(logo)
end)
