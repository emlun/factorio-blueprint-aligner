local modDefines = require("mod_defines")

local module = {}

function module.debug(player_index, s)
  if settings.get_player_settings(player_index)[modDefines.setting.logDebug].value then
    game.print(s)
  end
end

function module.info(player_index, s)
  if settings.get_player_settings(player_index)[modDefines.setting.logInfo].value then
    game.print(s)
  end
end

function module.error(player_index, s)
  if settings.get_player_settings(player_index)[modDefines.setting.logError].value then
    game.print(s)
  end
end

return module
