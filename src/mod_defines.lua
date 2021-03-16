function prefix(s)
  return "blueprint-align__" .. s
end

return {
  prototype = {
    item = {
      grid_selection_tool = prefix("item__grid-selection-tool"),
    },
    shortcut = {
      align_absolute = prefix("shortcut__align-blueprint-absolute"),
      align_relative = prefix("shortcut__align-blueprint-relative"),
      set_grid = prefix("shortcut__set-grid"),
    },
  },
  input = {
    align_absolute = prefix("input__align-blueprint-absolute"),
    align_relative = prefix("input__align-blueprint-relative"),
    set_grid = prefix("input__set-grid"),
    clear_cursor = prefix("clear-cursor"),
    move_grid_up = prefix("input__move-grid-up"),
    move_grid_down = prefix("input__move-grid-down"),
    move_grid_left = prefix("input__move-grid-left"),
    move_grid_right = prefix("input__move-grid-right"),
  },
  setting = {
    log_debug = prefix("log-debug"),
    log_info = prefix("log-info"),
    log_error = prefix("log-error"),
  },
}
