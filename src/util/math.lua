local module = {}


-- Round down to the nearest even integer.
function module.floor2(x)
  return 2 * math.floor(x / 2)
end

-- Round up to the nearest even integer.
function module.ceil2(x)
  return 2 * math.ceil(x / 2)
end

-- Round to the nearest integer.
function module.round(x)
  local hi = math.ceil(x)
  local lo = math.floor(x)
  if hi - x <= x - lo then
    return hi
  else
    return lo
  end
end

-- Round to the nearest multiple of 2.
function module.round2(x)
  return 2 * module.round(x / 2)
end

-- Rotate the given vector by the difference between the given direction and north.
function module.rot(x, y, direction)
  local theta = math.pi * direction / 8
  local cos_theta = math.cos(theta)
  local sin_theta = math.sin(theta)
  return x * cos_theta - y * sin_theta, x * sin_theta + y * cos_theta
end


return module
