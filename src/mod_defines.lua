function prefix(s)
  return "blueprint-align__" .. s
end

return {
  prototype = {
    shortcut = {
      align_absolute = prefix("shortcut__align-blueprint-absolute"),
    },
  },
  input = {
    align_absolute = prefix("input__align-blueprint-absolute"),
    clear_cursor = prefix("clear-cursor"),
  },
  setting = {
    log_debug = prefix("log-debug"),
    log_info = prefix("log-info"),
    log_error = prefix("log-error"),
  },
}
