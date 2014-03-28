lgm_distance = function(x1, y1, x2, y2)
  local dxx = x2 - x1
  local dyy = y2 - y1
  return math.sqrt(dxx ^ 2 + dyy ^ 2)
end
modulo_lua = function(x, y)
  return ((x - 1) % y) + 1
end
is_nan = function(x)
  if (x ~= x) then
    return true
  end
  if type(x) ~= "number" then
    return false
  end
  if tostring(x) == tostring((-1) ^ 0.5) then
    return true
  end
  return false
end
