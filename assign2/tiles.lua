local class = require "class"

local mod = {}

mod.Tile = class.class(
  class.Object, {
    constructor = function(self)
      self.seen = false
    end,

    methods = {
      Char = function(self)
        return error("Char has not been overridden.")
      end,
      SeenChar = function(self)
        return error("SeenChar has not been overridden.")
      end
    }
})

mod.GroundTile = class.class(
  mod.Tile, {
    methods = {
      Char = function(self) return "." end,
      SeenChar = function(self) return " " end
    }
})

mod.WallTile = class.class(
  mod.Tile, {
    methods = {
      Char = function(self) return "#" end,
      SeenChar = function(self) return "+" end
    }
})

return mod
