local mod_defines = require("mod_defines")

local module = {}

function module.debug(player_index, s)
  if settings.get_player_settings(player_index)[mod_defines.setting.log_debug].value then
    game.print(s)
  end
end

function module.info(player_index, s)
  if settings.get_player_settings(player_index)[mod_defines.setting.log_info].value then
    game.print(s)
  end
end

function module.error(player_index, s)
  if settings.get_player_settings(player_index)[mod_defines.setting.log_error].value then
    game.print(s)
  end
end

return module
