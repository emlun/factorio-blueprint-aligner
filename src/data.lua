local mod_defines = require("mod_defines")

local align_absolute_input = {
  type = "custom-input",
  name = mod_defines.input.align_absolute,
  key_sequence = "CONTROL + SHIFT + B",
}

local align_absolute_shortcut = {
  type = "shortcut",
  name = mod_defines.prototype.shortcut.align_absolute,
  associated_control_input = align_absolute_input.name,
  action = "lua",
  icon = data.raw["shortcut"]["give-blueprint"]["icon"],
}

local clear_cursor_input = {
  type = "custom-input",
  name = mod_defines.input.clear_cursor,
  key_sequence = "",
  linked_game_control = "clear-cursor",
}

data:extend{
  align_absolute_shortcut,
  align_absolute_input,
  clear_cursor_input,
}
