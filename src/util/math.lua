local module = {}


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

function module.floor2(x)
  return 2 * math.floor(x / 2)
end

function module.floor2_odd(x)
  return 2 * math.floor((x + 1) / 2) - 1
end

function module.ceil2(x)
  return 2 * math.ceil(x / 2)
end


return module
