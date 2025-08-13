local colors = require("colors").sections.widgets.volume
local icons = require("icons")
local utils = require("utils")

local popup_width = 250

local volume_icon = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = {
    color = colors.icon,
  },
  label = { drawing = false },
  background = { drawing = false },
  popup = utils.create_popup_config("center", 2),
  padding_right = 8,
})

local volume_slider = sbar.add("slider", popup_width, {
  position = "popup." .. volume_icon.name,
  slider = {
    highlight_color = colors.slider.highlight,
    background = {
      height = 12,
      corner_radius = 6,
      color = colors.slider.bg,
      border_color = colors.slider.border,
      border_width = 2,
    },
    knob = {
      string = "􀀁",
      drawing = true,
    },
  },
  background = { color = colors.popup.bg, height = 2, y_offset = -20 },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

-- Update volume icon based on percentage
volume_icon:subscribe("volume_change", function(env)
  local volume = tonumber(env.INFO)
  local icon = utils.volume_icon_for_percentage(volume, icons.volume)
  
  sbar.exec("SwitchAudioSource -t output -c", function(result)
    volume_icon:set({ icon = icon })
    volume_slider:set({ slider = { percentage = volume } })
  end)
end)

-- Audio device management
local current_audio_device = "None"

local function toggle_audio_devices(env)
  if env.BUTTON == "right" then
    sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
    return
  end

  local should_draw = volume_icon:query().popup.drawing == "off"
  if should_draw then
    volume_icon:set({ popup = { drawing = true } })
    sbar.exec("SwitchAudioSource -t output -c", function(result)
      current_audio_device = result:sub(1, -2)
      sbar.exec("SwitchAudioSource -a -t output", function(available)
        local current = current_audio_device
        local counter = 0

        for device in string.gmatch(available, "[^\r\n]+") do
          local device_color = (current == device) and colors.popup.highlight or colors.popup.item
          
          sbar.add("item", "volume.device." .. counter, {
            position = "popup." .. volume_icon.name,
            width = popup_width,
            align = "center",
            label = { string = device, color = device_color },
            background = { drawing = false },
            click_script = string.format(
              'SwitchAudioSource -s "%s" && sketchybar --set /volume.device\\.*/ label.color=%s --set $NAME label.color=%s',
              device,
              colors.popup.item,
              colors.popup.highlight
            ),
          })
          counter = counter + 1
        end
      end)
    end)
  else
    volume_icon:set({ popup = { drawing = false } })
    sbar.remove("/volume.device\\..*/")
  end
end

local function handle_volume_scroll(env)
  local delta = env.SCROLL_DELTA
  sbar.exec(string.format(
    'osascript -e "set volume output volume (output volume of (get volume settings) + %d)"',
    delta
  ))
end

-- Event subscriptions
volume_icon:subscribe(utils.EVENTS.MOUSE_CLICK, toggle_audio_devices)
volume_icon:subscribe(utils.EVENTS.MOUSE_SCROLL, handle_volume_scroll)