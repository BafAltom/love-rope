lgm_path = "./"
require(tostring(lgm_path) .. "lgm-entity")
require(tostring(lgm_path) .. "lgm-entityset")
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
  local es = EntitySet()
  local e1 = Entity(1, 1)
  local e2 = Entity(225, 130)
  local e3 = Entity(-300, -103)
  local closest, d = e1:getClosestOf(es:as_list())
  assert(closest == nil and d == nil)
  es:add(Entity(50, 25))
  es:add(Entity(200, 150))
  es:add(Entity(-140, 20))
  es:add(Entity(53, -12))
  es:add(Entity(0, 0))
  es:add(e3)
  closest, d = e1:getClosestOf(es:as_list())
  assert(closest:getX() == 0 and closest:getY() == 0 and d == math.sqrt(2), tostring(closest))
  closest, d = e2:getClosestOf(es:as_list())
  assert(closest:getX() == 200 and closest:getY() == 150, tostring(closest))
  local e = es:find(e3.id)
  assert(e == e3)
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
  local v1 = Vector(1, 1)
  local v2 = v1:scalarProduct(2)
  assert((v2.x == 2 and v2.y == 2), tostring(v2))
end
do
  local v1 = Vector(0, 20)
  local v2 = v1:scalarProduct(-1.5)
  assert((v2.x == 0 and v2.y == -30), tostring(v2))
end
do
  local v1 = Vector(180, 243)
  local v2 = v1:scalarProduct(5.25)
  assert((v2.x == 945 and v2.y == 1275.75), tostring(v2))
end
do
  local v1 = Vector(0, 0)
  local v2 = v1:scalarProduct(4)
  assert((v2.x == 0 and v2.y == 0), tostring(v2))
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
  assert(seg1:intersect(seg2), "Segment Intersection failed")
end
do
  local seg1 = Segment(Vector(3, 10), Vector(17, 56))
  local seg2 = Segment(Vector(0, -1), Vector(-12, 207))
  assert(not seg1:intersect(seg2), "Segment Intersection failed")
end
do
  local seg1 = Segment(Vector(-200, -200), Vector(700, 700))
  local seg2 = Segment(Vector(-0.5, 0), Vector(0.5, 0))
  assert(seg1:intersect(seg2), "Segment Intersection failed")
end
do
  assert(is_nan(0 / 0))
  assert(is_nan(-0 / 0))
  assert(is_nan((-1) ^ .5))
  assert(not is_nan(1))
  assert(not is_nan(0))
  assert(not is_nan(false))
end
return print("All tests have passed!")
