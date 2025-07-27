#!/usr/bin/env lua
package.path = package.path .. ";./lua/?.lua" .. ";./lua/?/init.lua" .. ";./scripts/?.lua"

Sbar = require("sketchybar")

Sbar.begin_config()
Sbar.hotload(true)

require("bar")
require("default")
require("items")

Sbar.end_config()

Sbar.event_loop()