local Point

Point = class.class(
  class.Object, {
    constructor = function(self, x, y)
      self.x = x
      self.y = y
    end,

    data = {
      x = 0, y = 0,
    },

    methods = {
      Dist = function(self, p)
        return ((p:X() - self.x)^2 + (p:Y() - self.y)^2)^(0.5)
      end,

      X = function(self) return self.x end,

      Y = function(self) return self.y end,

      SetX = function(self, x) self.x = x end,

      SetY = function(self, y) self.y = y end,
    },

    metamethods = {
      __add = function(self, p)
        return Point.new(self:X() + p:X(), self:Y() + p:Y())
      end,

      __sub = function(self, p)
        return Point.new(self:X() - p:X(), self:Y() - p:Y())
      end,

      __eq = function(self, p)
        return self:X() == p:X() and self:Y() == p:Y()
      end,

      __tostring = function(self)
        return string.format("{%d, %d}", self:X(), self:Y())
      end
    }
})

-- If the --native-point flag is passed in, use the native Point implementation
-- instead of the pure lua one.
local use_native_point = false
for _, a in ipairs(arg) do
  if a == "--native-point" then
    use_native_point = true
  end
end

if use_native_point then
  return require "native_point"
else
  return Point
end
