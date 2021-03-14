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


return module
