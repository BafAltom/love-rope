require(tostring(lgm_path) .. "lgm-vector")
do
  local _base_0 = {
    asVector = function(self)
      return self.pB:minus(self.pA)
    end,
    intersect = function(self, seg2)
      local v1 = self:asVector()
      local seg1CheckA = v1:isLeftTurn(seg2.pA:minus(self.pB))
      local seg1CheckB = v1:isLeftTurn(seg2.pB:minus(self.pB))
      local seg1Check = seg1CheckA ~= seg1CheckB
      local v2 = seg2:asVector()
      local seg2CheckA = v2:isLeftTurn(self.pA:minus(seg2.pB))
      local seg2CheckB = v2:isLeftTurn(self.pB:minus(seg2.pB))
      local seg2Check = (seg2CheckA ~= seg2CheckB)
      return seg1Check and seg2Check
    end,
    isLeft = function(self, p, strict)
      if strict == nil then
        strict = false
      end
      local vecP = Vector(self.pB.x - p.x, self.pB.y - p.y)
      return self:asVector():isLeftTurn(vecP, strict)
    end,
    __tostring = function(self)
      return "S(" .. tostring(self.pA) .. ", " .. tostring(self.pB) .. ")"
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, pA, pB)
      self.pA, self.pB = pA, pB
    end,
    __base = _base_0,
    __name = "Segment"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Segment = _class_0
  return _class_0
end
