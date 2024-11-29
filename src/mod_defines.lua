function prefix(s)
  return "blueprint-align__" .. s
end

return {
  sprite_path = function(path)
    return "__blueprint-align__/graphics/" .. path
  end,
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
  },
  setting = {
    log_debug = prefix("log-debug"),
    log_info = prefix("log-info"),
    log_error = prefix("log-error"),
  },
  sound = {
    align_start = "utility/entity_settings_copied",
    align_end = "utility/entity_settings_pasted",
  },
}
