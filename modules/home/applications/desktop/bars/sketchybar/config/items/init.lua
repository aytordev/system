-- Sketchybar items configuration
-- Simplified structure following KISS principle

-- Left panel items
require("items.left.apple")
require("items.left.spaces") 
require("items.left.menus")

-- Center panel items (consolidated)
require("items.center.notifications")

-- Right panel items (reverse order for right-to-left placement)
require("items.right.calendar")
require("widgets")
require("items.right.wifi")
require("items.right.media")