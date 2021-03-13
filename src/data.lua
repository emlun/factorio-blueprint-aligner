local modDefines = require("mod_defines")

local blueprintAlignShortcut = {
  type = "shortcut",
  name = modDefines.shortcutPrototypeName,
  action = "lua",
  icon = data.raw["shortcut"]["give-blueprint"]["icon"]
}

local clearCursorInput = {
  type = "custom-input",
  name = modDefines.prefix("clear-cursor"),
  key_sequence = "",
  linked_game_control = "clear-cursor",
}

data:extend{ blueprintAlignShortcut, clearCursorInput }
