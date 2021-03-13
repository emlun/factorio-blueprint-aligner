local modDefines = require("mod_defines")
local log = require("log")
local sutil = require("util.string")

local aligning_blueprint = false
local original_absolute_snapping = false
local original_position_relative_to_grid = nil

function round(x)
  local hi = math.ceil(x)
  local lo = math.floor(x)
  if hi - x <= x - lo then
    return hi
  else
    return lo
  end
end

function compute_blueprint_dimensions(blueprint)
  local x_min = nil
  local x_max = nil
  local y_min = nil
  local y_max = nil

  for _, ent in pairs(blueprint.get_blueprint_entities()) do
    local prots = game.get_filtered_entity_prototypes{{ filter = "name", name = ent.name }}

    local x_lo = math.floor(ent.position.x + prots[ent.name].selection_box.left_top.x)
    local x_hi = math.ceil(ent.position.x + prots[ent.name].selection_box.right_bottom.x)
    local y_lo = math.floor(ent.position.y + prots[ent.name].selection_box.left_top.y)
    local y_hi = math.ceil(ent.position.y + prots[ent.name].selection_box.right_bottom.y)

    x_min = math.min(x_lo, x_min or x_lo)
    x_max = math.max(x_hi, x_max or x_hi)
    y_min = math.min(y_lo, y_min or y_lo)
    y_max = math.max(y_hi, y_max or y_hi)
  end

  for _, ent in pairs(blueprint.get_blueprint_tiles()) do
    local x_lo = ent.position.x
    local x_hi = ent.position.x + 1
    local y_lo = ent.position.y
    local y_hi = ent.position.y + 1

    x_min = math.min(x_lo, x_min or x_lo)
    x_max = math.max(x_hi, x_max or x_hi)
    y_min = math.min(y_lo, y_min or y_lo)
    y_max = math.max(y_hi, y_max or y_hi)
  end

  return x_min, y_min, x_max - x_min, y_max - y_min
end

script.on_event(
  defines.events.on_lua_shortcut,
  function(event)
    local player = game.get_player(event.player_index)
    log.debug(event.player_index, string.format("on_lua_shortcut : %s", sutil.dumps(event)))

    if event.prototype_name == modDefines.shortcutPrototypeName then
      if not (player.is_cursor_blueprint() and player.cursor_stack and player.cursor_stack.valid_for_read) then
        log.error(event.player_index, {"blueprint-align.msg_bad_cursor"})
        return
      end

      log.debug(event.player_index, string.format("snap : %s", sutil.dumps(player.cursor_stack.blueprint_snap_to_grid)))
      log.debug(event.player_index, string.format("pos : %s", sutil.dumps(player.cursor_stack.blueprint_position_relative_to_grid)))
      log.debug(event.player_index, string.format("absolute : %s", sutil.dumps(player.cursor_stack.blueprint_absolute_snapping)))

      local blueprint = player.cursor_stack

      if blueprint.blueprint_snap_to_grid then
        log.info(event.player_index, {"blueprint-align.msg_begin"})

        original_absolute_snapping = blueprint.blueprint_absolute_snapping
        original_position_relative_to_grid = blueprint.blueprint_position_relative_to_grid

        blueprint.blueprint_absolute_snapping = false
        aligning_blueprint = true
      else
        log.error(event.player_index, {"blueprint-align.msg_no_grid"})
      end
    end
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

      local bx = round(event.position.x)
      local by = round(event.position.y)

      local sx = blueprint.blueprint_snap_to_grid.x;
      local sy = blueprint.blueprint_snap_to_grid.y;

      log.debug(event.player_index, string.format("entities: %s", sutil.dumps(blueprint.get_blueprint_entities())))

      xmin, ymin, w, h = compute_blueprint_dimensions(blueprint)
      log.debug(event.player_index, string.format("dim: (%s, %s) %sx%s", xmin, ymin, w, h))

      bx = (bx % sx) - math.ceil(w / 2) - xmin
      by = (by % sy) - math.ceil(h / 2) - ymin

      log.debug(event.player_index, string.format("bx %d, by %d", bx, by))
      log.debug(event.player_index, string.format("blueprint: %s", sutil.dumps(blueprint)))

      blueprint.blueprint_absolute_snapping = true
      blueprint.blueprint_position_relative_to_grid = { x = bx, y = by }

      aligning_blueprint = false
      log.info(event.player_index, {"blueprint-align.msg_finished"})
    end
  end
)

script.on_event(
  modDefines.prefix("clear-cursor"),
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
    end
  end
)

script.on_event(
  defines.events.on_player_cursor_stack_changed,
  function(event)
    if aligning_blueprint then
      log.info(event.player_index, {"blueprint-align.msg_abort"})
      aligning_blueprint = false
      original_absolute_snapping = false
      original_position_relative_to_grid = nil
    end
  end
)
