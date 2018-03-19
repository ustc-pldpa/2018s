local Entity = require "entity"

local Light = class.class(
  Entity, {
    constructor = function(self, game, pos, intensity)
      Entity.constructor(self, game, pos)
      self.intensity = intensity
    end,

    data = {
      intensity = 0
    },

    methods = {
      Intensity = function(self)
        return self.intensity
      end
    }
})

return Light
