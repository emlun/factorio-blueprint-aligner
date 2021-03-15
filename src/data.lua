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

local align_relative_input = {
  type = "custom-input",
  name = mod_defines.input.align_relative,
  key_sequence = "CONTROL + SHIFT + ALT + B",
}

local align_relative_shortcut = {
  type = "shortcut",
  name = mod_defines.prototype.shortcut.align_relative,
  associated_control_input = align_relative_input.name,
  action = "lua",
  icon = data.raw["shortcut"]["give-blueprint"]["icon"],
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
  icon = data.raw.blueprint.blueprint.icon,
  icon_size = data.raw.blueprint.blueprint.icon_size,
  stack_size = 1,
  flags = { "spawnable", "only-in-cursor" },
  alt_selection_color = data.raw.blueprint.blueprint.alt_selection_color,
  alt_selection_cursor_box_type = "blueprint-snap-rectangle",
  alt_selection_mode = { "blueprint" },
  selection_color = data.raw.blueprint.blueprint.selection_color,
  selection_cursor_box_type = "blueprint-snap-rectangle",
  selection_mode = { "any-tile" },
  always_include_tiles = true,
}

local set_grid_input = {
  type = "custom-input",
  name = mod_defines.input.set_grid,
  key_sequence = "CONTROL + SHIFT + G",
}

local set_grid_shortcut = {
  type = "shortcut",
  name = mod_defines.prototype.shortcut.set_grid,
  associated_control_input = set_grid_input.name,
  action = "lua",
  icon = data.raw["shortcut"]["give-blueprint"]["icon"],
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
