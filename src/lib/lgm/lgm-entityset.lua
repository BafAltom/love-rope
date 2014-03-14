do
  local _base_0 = {
    size = function(self)
      return #self.entList
    end,
    nextID = function(self)
      self.currentID = self.currentID + 1
      return self.currentID
    end,
    iter = function(self)
      local i = 1
      return function()
        i = i + 1
        if i <= #self.entList then
          return self.entList[i]
        end
      end
    end,
    as_list = function(self)
      return self.entList
    end,
    add = function(self, ent)
      ent.id = self:nextID()
      return table.insert(self.entList, ent)
    end,
    find = function(self, id)
      for _, e in ipairs(self.entList) do
        if e.id == id then
          return e
        end
      end
      return nil
    end,
    removeID = function(self, id)
      for n, e in ipairs(self.entList) do
        if e.id == id then
          table.remove(self.entList, n)
          return 
        end
      end
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self)
      self.currentID = 0
      self.entList = { }
    end,
    __base = _base_0,
    __name = "EntitySet"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  EntitySet = _class_0
  return _class_0
end
