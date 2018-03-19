local Point = require "point"
local Tiles = require "tiles"
local Hero = require "hero"
local Monster = require "monster"
local Light = require "light"

local FG
local BG

local Game = class.class(
  class.Object, {
    constructor = function(self)
      self:Log("Welcome to a Lua roguelike.")
      self:Log("Use arrow keys to move. Move into an enemy to attack. Use (tab) to wait. ")
      self:Log("Press (q) to quit.")

      -- Construct map.
      brogue = ROT.Map.Rogue(self.MAP_SIZE:X(), self.MAP_SIZE:Y())
      brogue:create(
        function(x, y, val)
          local tile = ({Tiles.GroundTile, Tiles.WallTile, Tiles.DoorTile})[val+1]
          if self.tiles[x] == nil then self.tiles[x] = {} end
          self.tiles[x][y] = tile.new()
          if self.tiles[x][y]:isinstance(Tiles.GroundTile) then
            table.insert(self.floors, Point.new(x,y))
          end
        end, false)

      -- Place hero, lights, and monsters.
      self.hero = Hero.new(self, self:RandomFloor())
      --self.lights = {Light.new(self, self.hero:Pos(), 0.5), Light.new(self, self:RandomFloor(), 1.0)}
      self.lights = {Light.new(self, self.hero:Pos(), 0.5)}
      for i = 1, self.NUM_MONSTERS do
        Monster.new(self, self:RandomFloor())
      end
    end,

    data = {
      log = {},
      tiles = {},
      floors = {},
      input = "",
      hero = nil,
      lights_on = false,
      entities = {},
      lights = {},
      MAP_SIZE = Point.new(70, 30),
      LOG_SIZE = Point.new(40, 30),
      NUM_MONSTERS = 3,
    },

    methods = {
      Start = function(self)
        termfx.init()
        termfx.outputmode(termfx.output.COL256)
        FG = termfx.grey2color(23)
        BG = termfx.grey2color(2)
        termfx.attributes(FG, BG)
        ok, err = pcall(function()
            self:Draw()
            while true do
              evt = termfx.pollevent()
              if evt.char == "q" then
                break
              else
                self:HandleInput(evt)
              end
              self:Draw()
            end
        end)
        termfx.shutdown()

        if err ~= nil then
          print(err)
          print(debug.traceback())
        end
      end,

      TryMove = function(self, entity, vector)
        local pos = entity:Pos()
        local dst = pos + vector

        -- Collision detection with walls
        if self.tiles[dst:X()][dst:Y()]:isinstance(Tiles.WallTile) then
          return
        end

        for _, e in ipairs(self.entities) do
          if dst == e:Pos() then
            entity:Collide(e)
            return
          end
        end

        pos:SetX(dst:X())
        pos:SetY(dst:Y())
      end,

      Log = function(self, entry)
        entry = "> " .. entry
        for line in entry:gmatch("[^\r\n]+") do
          while line:len() > self.LOG_SIZE:X() do
            table.insert(self.log, line:sub(1, self.LOG_SIZE:X()))
            line = " " .. line:sub(self.LOG_SIZE:X() + 1)
          end
          table.insert(self.log, line)
        end

        while #self.log > self.LOG_SIZE:Y() do
          table.remove(self.log, 1)
        end
      end,

      DeleteEntity = function(self, e)
        if e == self.hero then
          termfx.shutdown()
          print("Player died!")
          os.exit()
        end

        for i = 1, #self.entities do
          if self.entities[i] == e then
            table.remove(self.entities, i)
            break
          end
        end
      end,

      Hero = function(self)
        return self.hero
      end,

      WindowSize = function(self)
        return Point.new(self.MAP_SIZE:X() + self.LOG_SIZE:X() + 3,
                         self.MAP_SIZE:Y() + 2)
      end,

      HandleInput = function(self, evt)
        if #evt.char == 0 then
          local key = evt.key
          if key == termfx.key.ARROW_UP or key == termfx.key.ARROW_DOWN or
            key == termfx.key.ARROW_LEFT or key == termfx.key.ARROW_RIGHT or
            key == termfx.key.TAB
          then
            -- Move hero if arrow keys are sent
            local dirx = 0
            local diry = 0
            if key == termfx.key.ARROW_UP then
              diry = -1
            elseif key == termfx.key.ARROW_DOWN then
              diry = 1
            elseif key == termfx.key.ARROW_LEFT then
              dirx = -1
            elseif key == termfx.key.ARROW_RIGHT then
              dirx = 1
            end

            if dirx ~= 0 or diry ~= 0 then
              self:TryMove(self.hero, Point.new(dirx, diry))
              self.lights[1]:SetPos(self.hero:Pos())
            end

            for _, e in ipairs(self.entities) do
              e:Think()
            end
          elseif key == termfx.key.ENTER then
            -- Output the input line to log
            self:RunCommand(self.input)
            self.input = ""
          elseif key == termfx.key.BACKSPACE2 then
            if self.input:len() > 0 then
              self.input = self.input:sub(1, self.input:len() - 1)
            end
          else
            -- Add typed character to the stored input
            self.input = self.input .. string.char(key)
          end
        else
          self.input = self.input .. evt.char
        end
      end,

      RunCommand = function(self, input)
        local parts = {}
        for part in string.gmatch(input, "%S+") do
          table.insert(parts, part)
        end

        local command = parts[1]
        if command == "lights" then
          local arg = parts[2]
          self.lights_on = arg == "on"
        end
      end,

      RandomFloor = function(self)
        return self.floors[math.random(#self.floors)]
      end,


      Draw = function(self)
        -- Draw a frame.
        termfx.clear()
        local window_size = self:WindowSize()
        termfx.rect(self.MAP_SIZE:X() + 2, 1, 1, window_size:Y(), "│")
        termfx.rect(1, 1, window_size:X(), 1, "─")
        termfx.rect(1, 1, 1, window_size:Y(), "│")
        termfx.rect(window_size:X(), 1, 1, window_size:Y(), "│")
        termfx.rect(1, window_size:Y(), window_size:X(), 1, "─")
        termfx.setcell(1, 1, "┌")
        termfx.setcell(window_size:X(), 1, "┐")
        termfx.setcell(1, window_size:Y(), "└")
        termfx.setcell(window_size:X(), window_size:Y(), "┘")
        termfx.rect(self.MAP_SIZE:X() + 3, 2, self.LOG_SIZE:X(), self.LOG_SIZE:Y(), " ")

        -- Draw input
        termfx.printat(self.MAP_SIZE:X() + 3, self.MAP_SIZE:Y() + 1, "command: " .. self.input)

        -- Draw log
        for i, line in ipairs(self.log) do
          termfx.printat(self.MAP_SIZE:X() + 3, 1 + i, line)
        end

        -- Draw map
        local intensities = {}
        for i = 1, #self.tiles do
          intensities[i] = {}
          for j = 1, #self.tiles[1] do
            intensities[i][j] = 0
          end
        end

        local visible = self.hero:VisibleTiles()

        -- Mark visible tiles as seen.
        for _, t in ipairs(visible) do self.tiles[t:X()][t:Y()].seen = true end

        -- Figure out every tile where light touches
        for _, light in ipairs(self.lights) do
          for _, p in ipairs(light:VisibleTiles()) do
            local dist = light:Pos():Dist(p)
            local modifier = light:Intensity()
            intensities[p:X()][p:Y()] = math.min(
              intensities[p:X()][p:Y()] +
                modifier * math.max((10.0 - dist) / 10.0, 0.0),
              1.0)
          end
        end

        -- Clear the board
        for i = 1, self.MAP_SIZE:X() do
          for j = 1, self.MAP_SIZE:Y() do
            termfx.setcell(i + 1, j + 1, ' ', termfx.grey2color(2), BG)
          end
        end

        if self.lights_on then
          for i, row in ipairs(self.tiles) do
            for j, col in ipairs(row) do
              termfx.setcell(i+1, j+1, col:Char(), termfx.grey2color(23), BG)
            end
          end

          for _, e in ipairs(self.entities) do
            if not e:isinstance(Light) then
              local p = e:Pos()
              termfx.setcell(p:X()+1, p:Y()+1, e:Char(), e:Color(), termfx.grey2color(8))
            end
          end
        else
          -- Draw seen tiles as outline.
          for i, row in ipairs(self.tiles) do
            for j, col in ipairs(row) do
              if col.seen then
                termfx.setcell(i+1, j+1, col:SeenChar(), termfx.grey2color(4), BG)
              end
            end
          end

          for _, p in ipairs(visible) do
            local c = math.floor(intensities[p:X()][p:Y()] * 21 + 4)
            termfx.setcell(p:X() + 1, p:Y() + 1, self.tiles[p:X()][p:Y()]:Char(),
                           termfx.grey2color(c), BG)
          end

          -- Draw entities
          for _, e in ipairs(self.entities) do
            if not e:isinstance(Light) and self.hero:CanSee(e) then
              local pos = e:Pos()
              local c = e:ComputeLighting(intensities[pos:X()][pos:Y()])
              if c ~= termfx.rgb2color(0,0,0) then
                termfx.setcell(pos:X()+1, pos:Y()+1, e:Char(), c, termfx.grey2color(8))
              end
            end
          end
        end

        termfx.present()
      end,

    }
})

return Game
