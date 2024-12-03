local butil = require("util.blueprint")
local log = require("log")
local mod_defines = require("mod_defines")
local mutil = require("util.math")
local sutil = require("util.string")

local aligning_blueprint = false
local align_relative = nil
local original_position_relative_to_grid = nil

-- LuaRecord: used when grid selection tool is used with library record
local select_grid_blueprint = nil
-- string: used when grid selection tool is used with blueprint item in inventory
local select_grid_exported_blueprint = nil


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

function get_cursor_blueprint(player)
  if (player.cursor_record and player.cursor_record.valid_for_write and player.cursor_record.type == "blueprint") then
    return player.cursor_record
  elseif (player.cursor_stack and player.cursor_stack.is_blueprint) then
    return player.cursor_stack
  end
end

function begin_blueprint_alignment(event, relative)
  local player = game.get_player(event.player_index)

  local blueprint = get_cursor_blueprint(player)
  if not blueprint then
    log.error(event.player_index, {"blueprint-align.msg_bad_cursor"})
    return
  end

  log.debug(event.player_index, string.format("snap : %s", sutil.dumps(blueprint.blueprint_snap_to_grid)))
  log.debug(event.player_index, string.format("pos : %s", sutil.dumps(blueprint.blueprint_position_relative_to_grid)))
  log.debug(event.player_index, string.format("absolute : %s", sutil.dumps(blueprint.blueprint_absolute_snapping)))

  if blueprint.blueprint_snap_to_grid then
    if original_position_relative_to_grid then
      blueprint.blueprint_absolute_snapping = true
      blueprint.blueprint_position_relative_to_grid = original_position_relative_to_grid
    end

    original_position_relative_to_grid = blueprint.blueprint_position_relative_to_grid

    blueprint.blueprint_absolute_snapping = false
    aligning_blueprint = true
    align_relative = relative
    return true
  else
    log.error(event.player_index, {"blueprint-align.msg_no_grid"})
  end
end

function begin_grid_selection(event)
  local player = game.get_player(event.player_index)

  local blueprint = get_cursor_blueprint(player)
  if not blueprint then
    log.error(event.player_index, {"blueprint-align.msg_bad_cursor"})
    return
  end

  local x0, y0, w, h = butil.dimensions(blueprint)
  log.debug(event.player_index, string.format("blueprint dim: %s x %s @ (%s, %s)", w, h, x0, y0))

  if butil.contains_rails(blueprint) and x0 % 2 ~= y0 % 2 then
    log.error(event.player_index, {"blueprint-align.msg_prereq_no_mix_odd_and_even"})
    return
  end

  local selection_tool = { name = mod_defines.prototype.item.grid_selection_tool }
  if player.cursor_stack.can_set_stack(selection_tool) then
    select_grid_blueprint = blueprint
    if not player.cursor_record then
      select_grid_exported_blueprint = player.cursor_stack.export_stack()
    end

    log.debug(event.player_index, string.format("saved select_grid_blueprint: %s", select_grid_blueprint))
    if not player.cursor_stack.set_stack(selection_tool) then
      log.debug(event.player_index, "failed to insert selection tool")
    end

    return true
  else
    log.debug(event.player_index, "could not set cursor stack")
  end
end

script.on_event(
  defines.events.on_lua_shortcut,
  function(event)
    log.debug(event.player_index, string.format("on_lua_shortcut : %s", sutil.dumps(event)))

    if event.prototype_name == mod_defines.prototype.shortcut.align_absolute then
      if begin_blueprint_alignment(event, false) then
        log.info(event.player_index, {"blueprint-align.msg_begin_absolute"})
      end

    elseif event.prototype_name == mod_defines.prototype.shortcut.align_relative then
      if begin_blueprint_alignment(event, true) then
        log.info(event.player_index, {"blueprint-align.msg_begin_relative"})
      end

    elseif event.prototype_name == mod_defines.prototype.shortcut.set_grid then
      if begin_grid_selection(event) then
        log.info(event.player_index, {"blueprint-align.msg_grid_selection_started"})
      end

    end
  end
)

script.on_event(
  mod_defines.input.align_absolute,
  function(event)
    local player = game.get_player(event.player_index)
    log.debug(event.player_index, string.format("on custom_input : %s", sutil.dumps(event)))
    if begin_blueprint_alignment(event, false) then
      log.info(event.player_index, {"blueprint-align.msg_begin_absolute"})
      player.play_sound{ path = mod_defines.sound.align_start }
    end
  end
)

script.on_event(
  mod_defines.input.align_relative,
  function(event)
    local player = game.get_player(event.player_index)
    log.debug(event.player_index, string.format("on custom_input : %s", sutil.dumps(event)))
    if begin_blueprint_alignment(event, true) then
      log.info(event.player_index, {"blueprint-align.msg_begin_relative"})
      player.play_sound{ path = mod_defines.sound.align_start }
    end
  end
)

script.on_event(
  mod_defines.input.set_grid,
  function(event)
    local player = game.get_player(event.player_index)
    log.debug(event.player_index, string.format("on custom_input : %s", sutil.dumps(event)))
    if begin_grid_selection(event) then
      player.play_sound{ path = mod_defines.sound.align_start }
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
      local blueprint = get_cursor_blueprint(player)
      if not blueprint then
        log.error(event.player_index, {"blueprint-align.msg_bad_cursor"})
      end

      local rounding = butil.contains_rails(blueprint) and mutil.round2 or mutil.round

      if not blueprint.blueprint_absolute_snapping then
        blueprint.blueprint_absolute_snapping = true
        blueprint.blueprint_position_relative_to_grid = original_position_relative_to_grid or { x = 0, y = 0 }
      end
      original_position_relative_to_grid = nil

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
        dx, dy = mutil.rot(dx, dy, event.direction)
        if event.flip_horizontal then
          dx = -dx
        end
        if event.flip_vertical then
          dy = -dy
        end
        local flip_xor = (
          (event.flip_horizontal and not event.flip_vertical)
          or (event.flip_vertical and not event.flip_horizontal))
        if (event.direction == defines.direction.east or event.direction == defines.direction.west) and flip_xor then
          dx, dy = -dx, -dy
        end

        blueprint.blueprint_position_relative_to_grid = {
          x = blueprint.blueprint_position_relative_to_grid.x + dx,
          y = blueprint.blueprint_position_relative_to_grid.y + dy,
        }
        local _, _, w, h = butil.dimensions(blueprint)
        translate_blueprint(((center_x + w) % w) - center_x, ((center_y + h) % h) - center_y, blueprint)
      end

      aligning_blueprint = false
      player.play_sound{ path = mod_defines.sound.align_end }
      player.create_local_flying_text{
        text = {"blueprint-align.msg_finished"},
        create_at_cursor = true,
      }
    end
  end
)

script.on_event(
  defines.events.on_player_selected_area,
  function(event)
    local player = game.get_player(event.player_index)
    if event.item == mod_defines.prototype.item.grid_selection_tool then
      log.debug(event.player_index, string.format("on_player_selected_area : %s", sutil.dumps(event.area)))

      local selected_x_min = math.floor(event.area.left_top.x)
      local selected_y_min = math.floor(event.area.left_top.y)
      local selected_w = math.ceil(event.area.right_bottom.x) - selected_x_min
      local selected_h = math.ceil(event.area.right_bottom.y) - selected_y_min

      local x_min = selected_x_min
      local y_min = selected_y_min
      local w = selected_w
      local h = selected_h

      if select_grid_blueprint and select_grid_blueprint.valid then
        local blueprint = select_grid_blueprint

        if select_grid_exported_blueprint then
          player.cursor_stack.import_stack(select_grid_exported_blueprint)
          blueprint = player.cursor_stack
        else
          player.cursor_stack.clear()
        end

        local fudged = false

        local x0, _, _, _ = butil.dimensions(blueprint)
        local oddity = x0 % 2

        if butil.contains_rails(blueprint) then
          if w % 2 ~= 0 then
            w = w + 1
            fudged = true
          end
          if h % 2 ~= 0 then
            h = h + 1
            fudged = true
          end

          if x_min % 2 ~= oddity then
            x_min = x_min - 1
            fudged = true
          end
          if y_min % 2 ~= oddity then
            y_min = y_min - 1
            fudged = true
          end
        end

        x_min = x_min % w
        y_min = y_min % h

        blueprint.blueprint_snap_to_grid = { x = w, y = h }
        blueprint.blueprint_absolute_snapping = true
        blueprint.blueprint_position_relative_to_grid = { x = x_min, y = y_min }
        select_grid_blueprint = nil
        select_grid_exported_blueprint = nil

        local center_x, center_y = butil.center(blueprint)
        translate_blueprint(((center_x + w) % w) - center_x, ((center_y + h) % h) - center_y, blueprint)

        if fudged then
          log.info(event.player_index, {"blueprint-align.msg_grid_selection_finished_fudged",
                                        selected_w, selected_h,
                                        selected_x_min, selected_y_min,
                                        w, h,
                                        x_min, y_min
          })
          player.play_sound{ path = "utility/console_message" }
          player.create_local_flying_text{ text = {"blueprint-align.msg_grid_selection_finished_fudged_short"}, create_at_cursor = true }
        else
          player.play_sound{ path = mod_defines.sound.align_end }
          player.create_local_flying_text{ text = {"blueprint-align.msg_grid_selection_finished"}, create_at_cursor = true }
        end
      end
    end
  end
)

script.on_event(
  mod_defines.input.clear_cursor,
  function(event)
    local player = game.get_player(event.player_index)
    log.debug(event.player_index, string.format("on custom_input : %s", sutil.dumps(event)))

    if aligning_blueprint then
      local blueprint = get_cursor_blueprint(player)

      log.debug(event.player_index,
                string.format("Restoring original settings: offset %s",
                              sutil.dumps(original_position_relative_to_grid)))

      blueprint.blueprint_absolute_snapping = original_position_relative_to_grid ~= nil
      blueprint.blueprint_position_relative_to_grid = original_position_relative_to_grid
      original_position_relative_to_grid = false
    end
  end
)

script.on_event(
  defines.events.on_player_cursor_stack_changed,
  function(event)
    local player = game.get_player(event.player_index)

    if (select_grid_blueprint or select_grid_exported_blueprint)
      and not (
        player.cursor_stack
        and player.cursor_stack.valid_for_read
        and player.cursor_stack.name == mod_defines.prototype.item.grid_selection_tool
    ) then
      log.debug(event.player_index, "Grid selection aborted.")
      log.debug(event.player_index,
                string.format("player cursor stack: %s, %s, %s",
                              sutil.dumps(player.cursor_stack),
                              player.cursor_stack.valid,
                              player.cursor_stack.valid_for_read))

      if select_grid_exported_blueprint then
        player.clear_cursor()
        player.cursor_stack.import_stack(select_grid_exported_blueprint)
        player.clear_cursor()
      end

      select_grid_blueprint = nil
      select_grid_exported_blueprint = nil
    end

    if aligning_blueprint then
      log.debug(event.player_index, "Blueprint alignment aborted.")

      aligning_blueprint = false

      if original_position_relative_to_grid then
        log.error(
          event.player_index, {
            "blueprint-align.msg_abort_without_restore",
            original_position_relative_to_grid.x,
            original_position_relative_to_grid.y
        })
      end

      original_position_relative_to_grid = nil
    end
  end
)
