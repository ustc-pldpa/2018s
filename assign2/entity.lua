local Point = require "point"
local Tiles = require "tiles"

local id = 0

local Entity = class.class(
  class.Object, {
    constructor = function(self, game, pos)
      self.game = game
      self.pos = pos
      self.id = id
      id = id + 1
      table.insert(self.game.entities, self)
    end,

    data = {
      id = 0,
      pos = Point.new(0, 0),
      health = 10
    },

    methods = {
      Id = function(self)
        return self.id
      end,

      Pos = function(self)
        return self.pos
      end,

      SetPos = function(self, pos)
        self.pos = pos
      end,

      Char = function(self)
        return "*"
      end,

      Color = function(self)
        return termfx.color.CYAN
      end,

      Collide = function(self, e) end,

      Think = function(self) end,
      Die = function(self) end,

      Health = function(self)
        return self.health
      end,

      SetHealth = function(self, h)
        self.health = h
        if h <= 0 then
          self:Die()
          self.game:DeleteEntity(self)
        end
      end,

      PathTo = function(self, e)
        local src = self:Pos()
        local dst = e:Pos()
        local dj = ROT.Path.Dijkstra(
          src:X(), src:Y(), function(x, y)
            return not self.game.tiles[x][y]:isinstance(Tiles.WallTile)
        end)

        local path = {}
        dj:compute(
          dst:X(), dst:Y(), function(x, y)
            table.insert(path, Point.new(x, y))
        end)
        return path
      end,

      ComputeLighting = function(self, intensity)
        local _, r, g, b = termfx.colorinfo(self:Color())
        return termfx.rgb2color(
          math.ceil(r * intensity / 256.0 * 5.0),
          math.ceil(g * intensity / 256.0 * 5.0),
          math.ceil(b * intensity / 256.0 * 5.0))
      end,

      VisibleTiles = function(self)
        local src = self:Pos()
        local fov = ROT.FOV.Precise:new(function(_, x, y)
            if x < 1 or x > #self.game.tiles or
              y < 1 or y > #self.game.tiles[1]
            then return false end
            return self.game.tiles[x][y]:isinstance(Tiles.GroundTile)
        end)

        local visible = {}
        fov:compute(
          src:X(), src:Y(), 10, function(x, y, _, _)
            table.insert(visible, Point.new(x, y))
        end)
        return visible
      end,

      CanSee = function(self, e)
        local dst = e:Pos()
        for _, p in ipairs(self:VisibleTiles()) do
          if p == dst then
            return true
          end
        end
        return false
      end
    },

    metamethods = {
      __eq = function(e1, e2)
        return e1:Id() == e2:Id()
      end
    }
})

return Entity
