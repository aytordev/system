-- require "items.widgets.messages"
require("items.right.widgets.volume")
require("items.right.widgets.battery")

sbar.add("bracket", { "/widgets\\..*/" }, {})

sbar.add("item", "widgets.padding", {
  width = 16,
})
