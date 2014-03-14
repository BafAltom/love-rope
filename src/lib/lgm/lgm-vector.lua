require(tostring(lgm_path) .. "lgm-base")
do
  local _base_0 = {
    copy = function(self)
      return Vector(self.x, self.y)
    end,
    norm = function(self)
      return lgm_distance(0, 0, self.x, self.y)
    end,
    setNorm = function(self, newNorm)
      local curNorm = self:norm()
      local normFactor = newNorm / curNorm
      self.x = self.x * normFactor
      self.y = self.y * normFactor
    end,
    scalarProduct = function(self, number)
      local newV = self:copy()
      newV:setNorm(self:norm() * number)
      return newV
    end,
    add = function(self, v2)
      return Vector(self.x + v2.x, self.y + v2.y)
    end,
    minus = function(self, v2)
      return v2:add((self:scalarProduct(-1)))
    end,
    angle = function(self)
      return self:angleWith(Vector(1, 0))
    end,
    angleWith = function(self, v2)
      local a = math.atan2(v2.y, v2.x) - math.atan2(self.y, self.x)
      if a < -math.pi then
        a = a + (2 * math.pi)
      end
      if a > math.pi then
        a = a - (2 * math.pi)
      end
      return a
    end,
    dotProduct = function(self, v2)
      return self.x * v2.x + self.y * v2.y
    end,
    crossProduct = function(self, v2)
      return self:norm() * v2:norm() * math.sin(self:angleWith(v2))
    end,
    isLeftTurn = function(self, v2, strict)
      if strict == nil then
        strict = false
      end
      if strict then
        return (self:crossProduct(v2)) > 0
      else
        return (self:crossProduct(v2)) >= 0
      end
    end,
    __tostring = function(self)
      return "V(" .. tostring(self.x) .. ", " .. tostring(self.y) .. ")"
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, x, y)
      self.x, self.y = x, y
    end,
    __base = _base_0,
    __name = "Vector"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Vector = _class_0
  return _class_0
end
