local modDefines = require("mod_defines")

local blueprintAlignShortcut = {
  type = "shortcut",
  name = modDefines.shortcutPrototypeName,
  associated_control_input = modDefines.shortcutInput,
  action = "lua",
  icon = data.raw["shortcut"]["give-blueprint"]["icon"],
}

local blueprintAlignShortcutInput = {
  type = "custom-input",
  name = modDefines.shortcutInput,
  key_sequence = "",
}

local clearCursorInput = {
  type = "custom-input",
  name = modDefines.prefix("clear-cursor"),
  key_sequence = "",
  linked_game_control = "clear-cursor",
}

data:extend{
  blueprintAlignShortcut,
  blueprintAlignShortcutInput,
  clearCursorInput,
}
