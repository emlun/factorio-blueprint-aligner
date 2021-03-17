local mutil = require("math")

local module = {}


-- Determine whether the blueprint contains rails and/or train stops.
function module.contains_rails(blueprint)
  for _, ent in pairs(blueprint.get_blueprint_entities() or {}) do
    if ent.name == "straight-rail" or ent.name == "curved-rail" or ent.name == "train-stop" then
      return true
    end
  end
  return false
end

function rotate_box(x_left, x_right, y_top, y_bottom, direction)
  if direction == 0 or direction == 4 then
    return x_left, x_right, y_top, y_bottom
  elseif direction == 2 or direction == 6 then
    return y_top, y_bottom, x_left, x_right

  -- These are mainly designed for curved rails, will likely break for other 8-way entities
  elseif direction == 1 or direction == 5 then
    return x_left, x_right, y_top, y_bottom
  elseif direction == 3 or direction == 7 then
    return y_top, y_bottom, x_left, x_right

  else
    assert(direction < 8 and direction >= 0, "Unknown direction: " .. direction)
  end
end

-- Compute the bounding box for entities and tiles in the blueprint,
-- in the blueprint's internal coordinate frame.
function module.dimensions(blueprint)
  local x_min = nil
  local x_max = nil
  local y_min = nil
  local y_max = nil

  for _, ent in pairs(blueprint.get_blueprint_entities() or {}) do
    local prots = game.get_filtered_entity_prototypes{{ filter = "name", name = ent.name }}

    local box = prots[ent.name].secondary_collision_box or prots[ent.name].selection_box

    local x_left = box.left_top.x
    local x_right = box.right_bottom.x
    local y_top = box.left_top.y
    local y_bottom = box.right_bottom.y

    x_left, x_right, y_top, y_bottom = rotate_box(x_left, x_right, y_top, y_bottom, ent.direction or 0)

    local x_lo = ent.position.x + x_left
    local x_hi = ent.position.x + x_right
    local y_lo = ent.position.y + y_top
    local y_hi = ent.position.y + y_bottom

    x_min = math.min(x_lo, x_min or x_lo)
    x_max = math.max(x_hi, x_max or x_hi)
    y_min = math.min(y_lo, y_min or y_lo)
    y_max = math.max(y_hi, y_max or y_hi)
  end

  for _, ent in pairs(blueprint.get_blueprint_tiles() or {}) do
    local x_lo = ent.position.x
    local x_hi = ent.position.x + 1
    local y_lo = ent.position.y
    local y_hi = ent.position.y + 1

    x_min = math.min(x_lo, x_min or x_lo)
    x_max = math.max(x_hi, x_max or x_hi)
    y_min = math.min(y_lo, y_min or y_lo)
    y_max = math.max(y_hi, y_max or y_hi)
  end

  if module.contains_rails(blueprint) then
    x_min = mutil.floor2(x_min)
    x_max = mutil.ceil2(x_max)
    y_min = mutil.floor2(y_min)
    y_max = mutil.ceil2(y_max)
  else
    x_min = math.floor(x_min)
    x_max = math.ceil(x_max)
    y_min = math.floor(y_min)
    y_max = math.ceil(y_max)
  end

  return x_min, y_min, x_max - x_min, y_max - y_min
end


-- The blueprint center is the coordinate within the blueprint's internal coordinate frame
-- which the game attempts to keep as close as possible to the cursor
-- while placing the blueprint.
-- This may, in each axis,
-- be a half-number if the blueprint centers around a tile center,
-- or an integer if the blueprint centers around a tile edge.
-- If the blueprint contains rails or train stops, both coordinates will be integers.
function module.center(blueprint)
  local x_min, y_min, w, h = module.dimensions(blueprint)
  local cx, cy = x_min + w/2, y_min + h/2
  if module.contains_rails(blueprint) then
    return mutil.round(cx), mutil.round(cy)
  else
    return cx, cy
  end
end

-- Transform a world-coordinate into a coordinate relative to the absolute blueprint grid,
-- respecting blueprint rotation and/or flipping.
-- Undefined behaviour if blueprint has no grid size set.
function module.world_to_blueprint_frame(x, y, direction, flip_x, flip_y, blueprint)
  assert(blueprint.blueprint_snap_to_grid, "Blueprint must have grid size set.")

  local grid_x0 = (blueprint.blueprint_position_relative_to_grid or { x = 0 }).x
  local grid_y0 = (blueprint.blueprint_position_relative_to_grid or { y = 0 }).y

  local grid_w = blueprint.blueprint_snap_to_grid.x
  local grid_h = blueprint.blueprint_snap_to_grid.y

  local bx, by = 0, 0

  if direction == 0 then
    -- grid origin is top-left
    bx = (((x - grid_x0) % grid_w) + grid_w) % grid_w
    by = (((y - grid_y0) % grid_h) + grid_h) % grid_h

  elseif direction == 2 then
    -- grid origin is top-right
    bx = (((y - grid_y0) % grid_h) + grid_h) % grid_h
    by = (((grid_x0 - x) % grid_w) + grid_w) % grid_w

  elseif direction == 4 then
    -- grid origin is bottom-right
    bx = (((grid_x0 - x) % grid_w) + grid_w) % grid_w
    by = (((grid_y0 - y) % grid_h) + grid_h) % grid_h

  else
    -- grid origin is bottom-left
    bx = (((grid_y0 - y) % grid_h) + grid_h) % grid_h
    by = (((x - grid_x0) % grid_w) + grid_w) % grid_w
  end

  local swap_dims = direction == 2 or direction == 6
  if flip_x then
    bx = (swap_dims and grid_h or grid_w) - bx
  end
  if flip_y then
    by = (swap_dims and grid_w or grid_h) - by
  end

  return bx, by
end

return module
