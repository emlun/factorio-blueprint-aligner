local butil = require("util.blueprint")
local log = require("log")
local mod_defines = require("mod_defines")
local mutil = require("util.math")
local sutil = require("util.string")

local aligning_blueprint = false
local align_relative = nil
local original_absolute_snapping = false
local original_position_relative_to_grid = nil
local original_restored = false


function translate_blueprint(dx, dy, blueprint)
  local entities = blueprint.get_blueprint_entities()
  if entities ~= nil then
    for _, ent in pairs(entities) do
      ent.position.x = ent.position.x + dx
      ent.position.y = ent.position.y + dy
    end
    blueprint.set_blueprint_entities(entities)
  end

  local tiles = blueprint.get_blueprint_tiles()
  if tiles ~= nil then
    for _, tile in pairs(tiles) do
      tile.position.x = tile.position.x + dx
      tile.position.y = tile.position.y + dy
    end
    blueprint.set_blueprint_tiles(tiles)
  end
end

function begin_blueprint_alignment(event, relative)
  local player = game.get_player(event.player_index)

  if not (player.is_cursor_blueprint() and player.cursor_stack and player.cursor_stack.valid_for_read) then
    log.error(event.player_index, {"blueprint-align.msg_bad_cursor"})
    return
  end

  log.debug(event.player_index, string.format("snap : %s", sutil.dumps(player.cursor_stack.blueprint_snap_to_grid)))
  log.debug(event.player_index, string.format("pos : %s", sutil.dumps(player.cursor_stack.blueprint_position_relative_to_grid)))
  log.debug(event.player_index, string.format("absolute : %s", sutil.dumps(player.cursor_stack.blueprint_absolute_snapping)))

  local blueprint = player.cursor_stack

  if blueprint.blueprint_snap_to_grid then
    if relative then
      log.info(event.player_index, {"blueprint-align.msg_begin_relative"})
    else
      log.info(event.player_index, {"blueprint-align.msg_begin_absolute"})
    end

    original_restored = false
    original_absolute_snapping = blueprint.blueprint_absolute_snapping
    original_position_relative_to_grid = blueprint.blueprint_position_relative_to_grid

    blueprint.blueprint_absolute_snapping = false
    aligning_blueprint = true
    align_relative = relative
  else
    log.error(event.player_index, {"blueprint-align.msg_no_grid"})
  end
end

script.on_event(
  defines.events.on_lua_shortcut,
  function(event)
    log.debug(event.player_index, string.format("on_lua_shortcut : %s", sutil.dumps(event)))
    if event.prototype_name == mod_defines.prototype.shortcut.align_absolute then
      begin_blueprint_alignment(event, false)
    elseif event.prototype_name == mod_defines.prototype.shortcut.align_relative then
      begin_blueprint_alignment(event, true)
    end
  end
)

script.on_event(
  mod_defines.input.align_absolute,
  function(event)
    log.debug(event.player_index, string.format("on custom_input : %s", sutil.dumps(event)))
    begin_blueprint_alignment(event, false)
  end
)

script.on_event(
  mod_defines.input.align_relative,
  function(event)
    log.debug(event.player_index, string.format("on custom_input : %s", sutil.dumps(event)))
    begin_blueprint_alignment(event, true)
  end
)

script.on_event(
  defines.events.on_pre_build,
  function(event)
    log.debug(event.player_index, string.format("on_pre_build : %s", sutil.dumps(event)))

    if aligning_blueprint then
      log.debug(event.player_index, string.format("Finishing blueprint alignment..."))

      local player = game.get_player(event.player_index)
      local blueprint = player.cursor_stack
      local rounding = butil.contains_rails(blueprint) and mutil.round2 or mutil.round

      blueprint.blueprint_absolute_snapping = true
      blueprint.blueprint_position_relative_to_grid = original_position_relative_to_grid

      local center_x, center_y = butil.center(blueprint)
      local click_x_in_grid, click_y_in_grid = butil.world_to_blueprint_frame(
        event.position.x,
        event.position.y,
        event.direction,
        event.flip_horizontal,
        event.flip_vertical,
        blueprint
      )
      local dx, dy = rounding(click_x_in_grid - center_x), rounding(click_y_in_grid - center_y)

      log.debug(event.player_index, string.format("grid pos: %s", sutil.dumps(blueprint.blueprint_position_relative_to_grid)))
      log.debug(event.player_index, string.format("click pos: (%s, %s)", event.position.x, event.position.y))
      log.debug(event.player_index, string.format("click pos in grid: (%s, %s)", click_x_in_grid, click_y_in_grid))
      log.debug(event.player_index, string.format("blueprint center: (%s, %s)", center_x, center_y))
      log.debug(event.player_index, string.format("dxy: (%s, %s)", dx, dy))

      if align_relative then
        translate_blueprint(dx, dy, blueprint)
      else
        blueprint.blueprint_position_relative_to_grid = {
          x = blueprint.blueprint_position_relative_to_grid.x + dx,
          y = blueprint.blueprint_position_relative_to_grid.y + dy,
        }
      end

      aligning_blueprint = false
      log.info(event.player_index, {"blueprint-align.msg_finished"})
    end
  end
)

script.on_event(
  mod_defines.input.clear_cursor,
  function(event)
    local player = game.get_player(event.player_index)
    log.debug(event.player_index, string.format("on custom_input : %s", sutil.dumps(event)))

    if aligning_blueprint then
      local blueprint = player.cursor_stack

      log.debug(event.player_index,
                string.format("Restoring original settings: absolute %s, offset %s",
                              original_absolute_snapping,
                              sutil.dumps(original_position_relative_to_grid)))

      blueprint.blueprint_absolute_snapping = original_absolute_snapping
      blueprint.blueprint_position_relative_to_grid = original_position_relative_to_grid
      original_restored = true
    end
  end
)

script.on_event(
  defines.events.on_player_cursor_stack_changed,
  function(event)
    if aligning_blueprint then
      log.debug(event.player_index, "Blueprint alignment aborted.")

      aligning_blueprint = false

      if (not original_restored) and original_position_relative_to_grid then
        log.error(
          event.player_index, {
            "blueprint-align.msg_abort_without_restore",
            original_position_relative_to_grid.x,
            original_position_relative_to_grid.y
        })
      end

      original_absolute_snapping = false
      original_position_relative_to_grid = nil
    end
  end
)
