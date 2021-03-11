local modDefines = require("mod_defines")

local blueprintAlignShortcut = {
  type = "shortcut",
  name = modDefines.shortcutPrototypeName,
  action = "lua",
  icon = data.raw["shortcut"]["give-blueprint"]["icon"]
}

data:extend{ blueprintAlignShortcut }
