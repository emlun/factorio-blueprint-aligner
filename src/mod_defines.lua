function prefix(s)
  return "blueprint-align__" .. s
end

return {
  shortcutPrototypeName = prefix("shortcut__align-blueprint"),
  shortcutInput = prefix("shortcut__align-blueprint-input"),
  logDebugSetting = prefix("log-debug"),
  logInfoSetting = prefix("log-info"),
  logErrorSetting = prefix("log-error"),
  prefix = prefix,
}
