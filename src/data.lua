local mod_defines = require("mod_defines")

local blueprint_align_shortcut = {
  type = "shortcut",
  name = mod_defines.prototype.shortcut,
  associated_control_input = mod_defines.input.shortcut,
  action = "lua",
  icon = data.raw["shortcut"]["give-blueprint"]["icon"],
}

local blueprint_align_shortcut_input = {
  type = "custom-input",
  name = mod_defines.input.shortcut,
  key_sequence = "",
}

local clear_cursor_input = {
  type = "custom-input",
  name = mod_defines.input.clear_cursor,
  key_sequence = "",
  linked_game_control = "clear-cursor",
}

data:extend{
  blueprint_align_shortcut,
  blueprint_align_shortcut_input,
  clear_cursor_input,
}
