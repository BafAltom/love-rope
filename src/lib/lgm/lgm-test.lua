lgm_path = "./"
require(tostring(lgm_path) .. "lgm-entity")
require(tostring(lgm_path) .. "lgm-vector")
require(tostring(lgm_path) .. "lgm-segment")
do
  local e1 = Entity(0, 0)
  local e2 = Entity(3, 5)
  assert((e1:distanceTo(e2)) == math.sqrt(3 * 3 + 5 * 5), "distance Test Failed: " .. tostring(e1:distanceTo(e2)))
  e1 = Entity(10, 10)
  e2 = Entity(10, 15)
  assert((e1:distanceTo(e2)) == 5, "distance Test Failed: " .. tostring(e1:distanceTo(e2)) .. " != 5")
end
do
  local e1 = Entity(5, 2)
  local e2 = Entity(-3, 10)
  assert((e1:distanceTo(e2)) == math.sqrt(8 * 8 + 8 * 8))
end
do
  local v1 = Vector(10, 0)
  local v2 = Vector(0, 10)
  assert((v1:angleWith(v2)) == math.pi / 2, "vector test failed, " .. tostring(v1:angleWith(v2)) .. " != math.pi / 2 (" .. tostring(math.pi / 2) .. ")")
end
do
  local v1 = Vector(10, 0)
  local v2 = Vector(5, 5)
  assert((v2:angle()) == -math.pi / 4, "angle is " .. tostring(v2:angle()) .. " not " .. tostring(math.pi / 4))
  assert((v1:angleWith(v2)) == math.pi / 4)
end
do
  local v1 = Vector(5, 5)
  local v2 = Vector(-5, 5)
  assert((v1:angleWith(v2)) == math.pi / 2, tostring(v1:angleWith(v2)))
end
do
  local v1 = Vector(1, 1)
  local v2 = Vector(200, 0)
  assert((v1:angleWith(v2)) == -1 * math.pi / 4)
end
do
  local v1 = Vector(0, 10)
  local v2 = Vector(0, 20)
  assert((v1:dotProduct(v2)) == 200)
end
do
  local v1 = Vector(0, 430)
  local v2 = Vector(242, 0)
  assert((v1:dotProduct(v2)) == 0)
end
do
  local v1 = Vector(24, -58)
  local v2 = Vector(-7, 24)
  assert((v1:dotProduct(v2)) == -1560)
end
do
  local v1 = Vector(1, 0)
  local v2 = Vector(5, 0)
  assert((v1:crossProduct(v2)) == 0)
end
do
  local v1 = Vector(2, 0)
  local v2 = Vector(0, -8)
  assert((v1:crossProduct(v2)) == -16)
end
do
  local v1 = Vector(1, 0)
  local v2 = Vector(0, 1)
  assert(v1:isLeftTurn(v2))
end
do
  local v1 = Vector(5, 5)
  local v2 = Vector(7, -2)
  assert(not v1:isLeftTurn(v2))
end
do
  local v1 = Vector(7, 12)
  local v2 = Vector(14, 24)
  assert(v1:isLeftTurn(v2))
  assert(not v1:isLeftTurn(v2, true))
end
do
  local seg1 = Segment(Vector(-1, 0), Vector(1, 0))
  local seg2 = Segment(Vector(0, -1), Vector(0, 1))
  assert(seg1:intersect(seg2, "Segment Intersection failed"))
end
do
  local seg1 = Segment(Vector(3, 10), Vector(17, 56))
  local seg2 = Segment(Vector(0, -1), Vector(-12, 207))
  assert(not seg1:intersect(seg2, "Segment Intersection failed"))
end
do
  local seg1 = Segment(Vector(-200, -200), Vector(700, 700))
  local seg2 = Segment(Vector(-0.5, 0), Vector(0.5, 0))
  assert(seg1:intersect(seg2, "Segment Intersection failed"))
end
return print("All test passed!")
