local mod_defines = require("mod_defines")

local align_absolute_input = {
  type = "custom-input",
  name = mod_defines.input.align_absolute,
  key_sequence = "CONTROL + ALT + B",
}

local align_absolute_shortcut = {
  type = "shortcut",
  name = mod_defines.prototype.shortcut.align_absolute,
  associated_control_input = align_absolute_input.name,
  action = "lua",
  icon = mod_defines.sprite_path("set-offset-x32.png"),
  small_icon = mod_defines.sprite_path("set-offset-x32.png"),
  icon_size = 32,
  small_icon_size = 32,
}

local align_relative_input = {
  type = "custom-input",
  name = mod_defines.input.align_relative,
  key_sequence = "CONTROL + SHIFT + ALT + B",
  order = "0-align-2",
}

local align_relative_shortcut = {
  type = "shortcut",
  name = mod_defines.prototype.shortcut.align_relative,
  associated_control_input = align_relative_input.name,
  action = "lua",
  icon = mod_defines.sprite_path("align-entities-x32.png"),
  small_icon = mod_defines.sprite_path("align-entities-x32.png"),
  icon_size = 32,
  small_icon_size = 32,
}

local clear_cursor_input = {
  type = "custom-input",
  name = mod_defines.input.clear_cursor,
  key_sequence = "",
  linked_game_control = "clear-cursor",
}

local grid_selection_tool = {
  type = "selection-tool",
  name = mod_defines.prototype.item.grid_selection_tool,
  icon = mod_defines.sprite_path("select-grid-x32.png"),
  icon_size = 32,
  stack_size = 1,
  flags = { "not-stackable", "only-in-cursor", "spawnable" },
  hidden = true,
  alt_select = {
    border_color = data.raw.blueprint.blueprint.alt_select.border_color,
    cursor_box_type = "blueprint-snap-rectangle",
    mode = { "blueprint" },
  },
  select = {
    border_color = data.raw.blueprint.blueprint.select.border_color,
    cursor_box_type = "blueprint-snap-rectangle",
    mode = { "any-tile" },
  },
  always_include_tiles = true,
}

local set_grid_input = {
  type = "custom-input",
  name = mod_defines.input.set_grid,
  key_sequence = "CONTROL + SHIFT + B",
  order = "0-align-1",
}

local set_grid_shortcut = {
  type = "shortcut",
  name = mod_defines.prototype.shortcut.set_grid,
  associated_control_input = set_grid_input.name,
  action = "lua",
  icon = mod_defines.sprite_path("select-grid-x32.png"),
  small_icon = mod_defines.sprite_path("select-grid-x32.png"),
  icon_size = 32,
  small_icon_size = 32,
}

data:extend{
  align_absolute_shortcut,
  align_absolute_input,
  align_relative_shortcut,
  align_relative_input,
  clear_cursor_input,
  grid_selection_tool,
  set_grid_input,
  set_grid_shortcut,
}
