local Entity = require "entity"

local Hero = class.class(
  Entity, {
    methods = {
      Collide = function(self, e)
        self.game:Log("You hit a monster for 10 damage.")
        e:SetHealth(e:Health() - 10)
      end,

      SetHealth = function(self, h)
        self.game:Log(string.format('Your health is now %d', h))

        Entity.methods.SetHealth(self, h)
      end
    }
})

return Hero
