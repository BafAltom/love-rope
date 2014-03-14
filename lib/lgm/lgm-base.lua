lgm_distance = function(x1, y1, x2, y2)
  local dxx = x2 - x1
  local dyy = y2 - y1
  return math.sqrt(dxx ^ 2 + dyy ^ 2)
end
