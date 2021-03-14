local modDefines = require("mod_defines")

local blueprintAlignShortcut = {
  type = "shortcut",
  name = modDefines.prototype.shortcut,
  associated_control_input = modDefines.input.shortcut,
  action = "lua",
  icon = data.raw["shortcut"]["give-blueprint"]["icon"],
}

local blueprintAlignShortcutInput = {
  type = "custom-input",
  name = modDefines.input.shortcut,
  key_sequence = "",
}

local clearCursorInput = {
  type = "custom-input",
  name = modDefines.input.clearCursor,
  key_sequence = "",
  linked_game_control = "clear-cursor",
}

data:extend{
  blueprintAlignShortcut,
  blueprintAlignShortcutInput,
  clearCursorInput,
}
