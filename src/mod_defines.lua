function prefix(s)
  return "blueprint-align__" .. s
end

return {
  shortcutPrototypeName = prefix("shortcut__align-blueprint"),
  shortcutInput = prefix("shortcut__align-blueprint-input"),
  clearCursorInput = prefix("clear-cursor"),
  logDebugSetting = prefix("log-debug"),
  logInfoSetting = prefix("log-info"),
  logErrorSetting = prefix("log-error"),
}
