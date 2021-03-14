function prefix(s)
  return "blueprint-align__" .. s
end

return {
  prototype = {
    shortcut = prefix("shortcut__align-blueprint"),
  },
  input = {
    shortcut = prefix("shortcut__align-blueprint-input"),
    clear_cursor = prefix("clear-cursor"),
  },
  setting = {
    log_debug = prefix("log-debug"),
    log_info = prefix("log-info"),
    log_error = prefix("log-error"),
  },
}
