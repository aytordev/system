-- Widgets module - simplified structure
-- Groups all widget functionality in a single location

require("widgets.battery")
require("widgets.volume")
-- require("widgets.messages") -- Disabled - requires full disk access

-- Group all widgets together for styling consistency
sbar.add("bracket", { "/widgets\\..*/" }, {})

-- Add spacing after widgets
sbar.add("item", "widgets.padding", {
    width = 16,
})
