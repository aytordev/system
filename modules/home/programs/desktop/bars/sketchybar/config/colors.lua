local constants = require("nix_constants")
local colors = constants.colors

return {
    default = colors.default,
    black = colors.black,
    white = colors.white,
    red = colors.red,
    red_bright = colors.red_bright,
    green = colors.green,
    blue = colors.blue,
    blue_bright = colors.blue_bright,
    yellow = colors.yellow,
    orange = colors.orange,
    magenta = colors.magenta,
    grey = colors.grey,
    transparent = colors.transparent,

    bar = {
        bg = colors.bar.bg,
        border = colors.bar.border,
    },

    popup = {
        bg = colors.popup.bg,
        border = colors.popup.border
    },

    bg1 = colors.bg1,
    bg2 = colors.bg2,

    accent = colors.accent,
    accent_bright = colors.accent_bright,

    spotify_green = colors.spotify_green,

    with_alpha = function(color, alpha)
        if alpha > 1.0 or alpha < 0.0 then return color end
        -- Helper to handle string/number conversion if needed
        local c = color
        if type(c) == "string" then c = tonumber(c) end
        return (c & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
    end,
}
