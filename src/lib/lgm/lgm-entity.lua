require(tostring(lgm_path) .. "lgm-base")
do
  local _base_0 = {
    getX = function(self)
      return self.x
    end,
    getY = function(self)
      return self.y
    end,
    __tostring = function(self)
      return "E(" .. tostring(self.x) .. ", " .. tostring(self.y) .. ")"
    end,
    distanceTo = function(self, ent2)
      return lgm_distance(self.x, self.y, ent2.x, ent2.y)
    end,
    getClosestOf = function(candidateList, maxDistance)
      if maxDistance == nil then
        maxDistance = nil
      end
      if #candidateList == 0 then
        return nil, nil
      end
      if maxDistance == nil then
        while candidateList[1] == self do
          table.remove(candidateList, 1)
        end
        if #candidateList == 0 then
          return nil, nil
        end
        maxDistance = self:distanceTo(candidateList[1])
      end
      local closestCandidate = candidateList[1]
      local closestDistance = maxDistance
      for _, e in ipairs(candidateList) do
        if e ~= self then
          local dx = math.abs(e:getX() - self:getX())
          local dy = math.abs(e:getY() - self:getY())
          if dx < closestDistance and dy < closestDistance then
            local distance = self:distanceTo(e)
            if distance < closestDistance then
              closestCandidate = e
              closestDistance = distance
            end
          end
        end
      end
      return closestCandidate, closestDistance
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, x, y)
      self.x, self.y = x, y
    end,
    __base = _base_0,
    __name = "Entity"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Entity = _class_0
  return _class_0
end
