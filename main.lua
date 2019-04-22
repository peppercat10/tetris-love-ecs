local Concord = require("modules.Concord").init({
   useEvents = true
})
local Entity    = Concord.entity
local Component = Concord.component
local System    = Concord.system

local Game = Concord.instance()
Concord.addInstance(Game)

local Position = Component(function(e, x, y)
   e.x = x
   e.y = y
end)

local Grid = Component(function(e, cellSize, grid)
   e.cellSize = cellSize
   e.grid = grid
end)

local Controllable = Component()

local Color = Component(function(e,r,g,b,a)
   e.r = r
   e.g = g
   e.b = b
   e.a = a
   end)

local Input = Component(function(e,pressed,key)
   e.pressed = pressed
   e.key = key
   end)

local AutoRepeatRate = Component(function(e,rate, current)
   e.max = 1.0 / rate
   e.current = current
   end)

local DAS = Component(function(e,value)
   e.value = value
   end)

local e = Entity()
mt = {
   {0,1,0},
   {1,1,1},
   {0,0,0}
   }

e:give(Position,250,250)
e:give(Grid,20,mt)
e:give(Controllable)
e:give(Color,1,0,0,1)
e:give(Input,false,"0")
e:give(AutoRepeatRate,30,0)
e:give(DAS,0.132)
Game:addEntity(e)

local e = Entity()
e:give(Position,250,400)
e:give(Grid,40,mt)
e:give(Color,0,01,1)

Game:addEntity(e)

local PieceRenderer = System({Position,Grid})
function PieceRenderer:draw()
   local e
   love.graphics.setColor(1, 1, 1)
   for i = 1, self.pool.size do
      e = self.pool:get(i)
      local position = e:get(Position)
      local grid = e:get(Grid)
      local color = e:get(Color)
      local cellSize = grid.cellSize
      for i = 1, #grid.grid do
         for j = 1, #grid.grid[1] do
            love.graphics.setColor(color.r,color.g,color.b,color.a)
            if grid.grid[i][j] ~= 0 then
               love.graphics.rectangle("fill",position.x + (cellSize*j),position.y + (cellSize*i),cellSize,cellSize)
               love.graphics.setColor(0,1,1)
               love.graphics.rectangle("line",position.x + (cellSize*j),position.y + (cellSize*i),cellSize,cellSize)

            end
         end
      end
   end
end

local InputSystem = System({Input})
function InputSystem:update()
   local e
   local right = false
   local left = false
   if love.keyboard.isDown("right") then
      right = true
   elseif love.keyboard.isDown("left") then
      left = true
   end
   for i = 1, self.pool.size do
      e = self.pool:get(i)
      if right then
         e:get(Input).pressed = true
         e:get(Input).key = "right"
      elseif left then
         e:get(Input).pressed = true
         e:get(Input).key = "left"         
      else   
         e:get(Input).pressed = false
      end
   end
end

local MovementSystem = System({Input,Controllable})
function MovementSystem:update(dt)
   local e
   for i = 1, self.pool.size do
      e = self.pool:get(i)    
      if e:get(Input).pressed then

         if e:get(AutoRepeatRate).current == 0 then
            if e:get(Input).key == "left" then
               cellSize = e:get(Grid).cellSize
               e:get(Position).x = e:get(Position).x - cellSize
            elseif e:get(Input).key == "right" then
               cellSize = e:get(Grid).cellSize
               e:get(Position).x = e:get(Position).x + cellSize            
            end
            e:get(AutoRepeatRate).current = e:get(AutoRepeatRate).current + dt
         else
            if e:get(AutoRepeatRate).current >= e:get(AutoRepeatRate).max then
               e:get(AutoRepeatRate).current = 0
            else
               e:get(AutoRepeatRate).current = e:get(AutoRepeatRate).current + dt
            end
         end
      end
   end
end

Game:addSystem(InputSystem(), "update")
Game:addSystem(MovementSystem(), "update")
Game:addSystem(PieceRenderer(), "draw")
