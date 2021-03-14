function prefix(s)
  return "blueprint-align__" .. s
end

return {
  prototype = {
    shortcut = prefix("shortcut__align-blueprint"),
  },
  input = {
    shortcut = prefix("shortcut__align-blueprint-input"),
    clearCursor = prefix("clear-cursor"),
  },
  setting = {
    logDebug = prefix("log-debug"),
    logInfo = prefix("log-info"),
    logError = prefix("log-error"),
  },
}
