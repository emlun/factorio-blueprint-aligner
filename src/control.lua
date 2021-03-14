local butil = require("util.blueprint")
local log = require("log")
local mod_defines = require("mod_defines")
local mutil = require("util.math")
local sutil = require("util.string")

local aligning_blueprint = false
local original_absolute_snapping = false
local original_position_relative_to_grid = nil
local original_restored = false

local ceil2 = mutil.ceil2
local floor2 = mutil.floor2
local floor2_odd = mutil.floor2_odd
local round = mutil.round
local round2 = mutil.round2


function get_pointer_snapping_mode(size, min, rails)
  if rails then
    if size % 4 == 0 then
      return round2
    elseif size % 4 == 3 then
      return floor2_odd
    elseif min % 2 == 1 then
      return round2
    else
      return floor2
    end
  end

  if size % 2 == 1 then
    return math.floor
  else
    return round
  end
end

function rotate_size(w, h, direction)
  if direction == 0 or direction == 4 then
    return w, h
  else
    return h, w
  end
end

function round_or(x, do_other, other)
  if do_other then
    return other(x)
  else
    return round(x)
  end
end

function snap_center(x_min, y_min, w, h, direction, rails)
  local cx = w / 2 + x_min
  local cy = h / 2 + y_min

  local horz_size, vert_size = rotate_size(w, h, direction)
  local horz_odd = horz_size % 2 == 1
  local vert_odd = vert_size % 2 == 1

  if direction == 0 then
    return round_or(cx, horz_odd, math.floor), round_or(cy, vert_odd, math.floor)
  elseif direction == 2 then
    return round_or(cx, horz_odd, math.floor), round_or(cy, vert_odd, math.ceil)
  elseif direction == 4 then
    return round_or(cx, horz_odd, math.ceil), round_or(cy, vert_odd, math.ceil)
  elseif direction == 6 then
    return round_or(cx, horz_odd, math.ceil), round_or(cy, vert_odd, math.floor)
  end
  return snapped_x, snapped_y
end

function rail_snap(x, rails)
  if rails then
    return ceil2(x)
  end

  return x
end

function begin_blueprint_alignment(event)
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
    log.info(event.player_index, {"blueprint-align.msg_begin"})

    original_restored = false
    original_absolute_snapping = blueprint.blueprint_absolute_snapping
    original_position_relative_to_grid = blueprint.blueprint_position_relative_to_grid

    blueprint.blueprint_absolute_snapping = false
    aligning_blueprint = true
  else
    log.error(event.player_index, {"blueprint-align.msg_no_grid"})
  end
end

script.on_event(
  defines.events.on_lua_shortcut,
  function(event)
    log.debug(event.player_index, string.format("on_lua_shortcut : %s", sutil.dumps(event)))
    if event.prototype_name == mod_defines.prototype.shortcut.align_absolute then
      begin_blueprint_alignment(event)
    end
  end
)

script.on_event(
  mod_defines.input.align_absolute,
  function(event)
    log.debug(event.player_index, string.format("on custom_input : %s", sutil.dumps(event)))
    begin_blueprint_alignment(event)
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
      local rails = butil.contains_rails(blueprint)
      local flipdim = event.direction == 0 or event.direction == 4

      local x_min, y_min, w, h = butil.dimensions(blueprint)
      log.debug(event.player_index, string.format("dim: (%s, %s) %sx%s", x_min, y_min, w, h))

      -- Building placement snaps to tile edge or tile center
      -- depending on if the size in the respective dimension is even or odd,
      -- and to even or odd tiles depending on if the blueprint contains rails
      local snapping_x = get_pointer_snapping_mode(flipdim and w or h, flipdim and x_min or y_min, rails)
      local snapping_y = get_pointer_snapping_mode(flipdim and h or w, flipdim and y_min or x_min, rails)

      local ex = snapping_x(event.position.x)
      local ey = snapping_y(event.position.y)

      local sx = blueprint.blueprint_snap_to_grid.x
      local sy = blueprint.blueprint_snap_to_grid.y

      local bx = 0
      local by = 0

      local center_x, center_y = snap_center(x_min, y_min, w, h, event.direction, rails)

      if event.direction == 0 then
        bx = (ex % sx) - center_x
        by = (ey % sy) - center_y

      elseif event.direction == 2 then
        local topright_x = (ex % sy) + center_y
        local topright_y = (ey % sx) - center_x
        bx = topright_x - sy
        by = topright_y

      elseif event.direction == 4 then
        local btmright_x = (ex % sx) + center_x
        local btmright_y = (ey % sy) + center_y
        bx = btmright_x - sx
        by = btmright_y - sy

      elseif event.direction == 6 then
        local btmleft_x = (ex % sy) - center_y
        local btmleft_y = (ey % sx) + center_x
        bx = btmleft_x
        by = btmleft_y - sx

      end

      if event.flip_horizontal then
        if event.direction == 0 or event.direction == 4 then
          bx = bx - sx + 2 * ((ex - bx) % sx)
        else
          by = by - sx + 2 * ((ey - by) % sx)
        end
      end
      if event.flip_vertical then
        if event.direction == 0 or event.direction == 4 then
          by = by - sy + 2 * ((ey - by) % sy)
        else
          bx = bx - sy + 2 * ((ex - bx) % sy)
        end
      end

      rbx = rail_snap(bx, rails)
      rby = rail_snap(by, rails)

      log.debug(event.player_index, string.format("ex %d, ey %d", ex, ey))
      log.debug(event.player_index, string.format("cx %d, cy %d", center_x, center_y))
      log.debug(event.player_index, string.format("sx %d, sy %d", sx, sy))
      log.debug(event.player_index, string.format("bx %d, by %d", bx, by))
      log.debug(event.player_index, string.format("rbx %d, rby %d", rbx, rby))
      log.debug(event.player_index, string.format("blueprint: %s", sutil.dumps(blueprint)))

      blueprint.blueprint_absolute_snapping = true
      blueprint.blueprint_position_relative_to_grid = { x = rbx, y = rby }

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
