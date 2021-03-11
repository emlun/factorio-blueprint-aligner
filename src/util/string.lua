local module = {}

function module.dumps(value)
  if (type(value) == "table") then
    local contents = ""

    for k, v in pairs(value) do
      if contents ~= "" then
        contents = contents .. ", "
      end
      contents = contents .. string.format("%s: %s", module.dumps(k), module.dumps(v))
    end

    return "{ " .. contents .. " }"
  else
    return string.format("%s", value)
  end
end

return module

