local Concord = require("modules.Concord").init({
   useEvents = true
})
local Entity    = Concord.entity
local Component = Concord.component
local System    = Concord.system

local Game = Concord.instance()
Concord.addInstance(Game)

local board = {
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},	
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0},	
}


math.randomseed(os.time() )
local piece_list = {"O","L","S","Z","I","J","T"}

local colorPatterns = {{1,1,1},{1,0,0},{0,1,0},{0,0,1}}

--### HELPER FUNCTIONS START
function deepcopy(orig)
   local orig_type = type(orig)
   local copy
   if orig_type == 'table' then
       copy = {}
       for orig_key, orig_value in next, orig, nil do
           copy[deepcopy(orig_key)] = deepcopy(orig_value)
       end
       setmetatable(copy, deepcopy(getmetatable(orig)))
   else -- number, string, boolean, etc
       copy = orig
   end
   return copy
end

function printGrid(grid)
   for i=1,#grid do
       local finalLine = ""
       for j=1,#grid[1] do
           finalLine = finalLine .. grid[i][j] .. " "
     end
       print(finalLine)
   end
   print("====")
end

function shuffle(tbl)
   local size = #tbl
   for i = size, 1, -1 do
     local rand = math.random(i)
     tbl[i], tbl[rand] = tbl[rand], tbl[i]
   end
   return tbl
 end

--### HELPER FUNCTIONS END



--### COMPONENTS START
local Position = Component(function(e, x, y)
   e.x = x
   e.y = y
end)

local Grid = Component(function(e, grid)
   e.grid = deepcopy(grid)
end)

local CellSize = Component(function(e, cell_size)
   e.cell_size = cell_size
end) 

local isActive = Component()

local IsBoard = Component()

local Color = Component(function(e,value)
   e.color = value
   end)

local ColorValues = Component(function(e,values)
	e.color_values = values
	end)

local Input = Component(function(e,keys)
   e.inputs = {}
   for i=1,#keys do
    e.inputs[keys[i]] = false
   end
   end)

local ARR = Component(function(e,rate)
   e.max = 1.0 / rate
   e.current = 0
   end)

local DAS = Component(function(e,value)
   e.max = value
   e.current = 0
   e.activated = false
   end)

local PieceBucket = Component(function(e)
   e.pieces = {}
end)

local PieceList = Component(function(e,pieces)
   e.pieces = pieces
end)
--### COMPONENTS END


--### ENTITIES START
local brd = Entity()
brd:give(Position,250,125)
brd:give(Grid,board)
brd:give(CellSize,20)
brd:give(Color,1)
brd:give(ColorValues,colorPatterns)
brd:give(IsBoard)
brd:give(PieceBucket)
--brd:give(PieceList, {"O","L","S","Z","I","J","T"})
Game:addEntity(brd)
--### ENTITIES END

--### SYSTEMS START
local BoardRendererSystem = System({IsBoard})
function BoardRendererSystem:draw()

   local brd
   for i = 1, self.pool.size do
      brd = self.pool:get(i)

      local brd_grid = brd:get(Grid).grid
      local brd_position = brd:get(Position)
      local color_values = brd:get(ColorValues).color_values
      local brd_color = color_values[brd:get(Color).color]
      local cell_size = brd:get(CellSize).cell_size
      local square_color,square_number

      for n = 1, #brd_grid do
         for m = 1, #brd_grid[1] do
            square_number = brd_grid[n][m]
            if square_number ~= 0 then
               square_color = color_values[square_number]
               love.graphics.setColor(square_color)
               love.graphics.rectangle("fill",brd_position.x + (cell_size*m),brd_position.y + (cell_size*n),cell_size,cell_size)
            end
            love.graphics.setColor(brd_color)
            love.graphics.rectangle("line", brd_position.x + (cell_size*m), brd_position.y + (cell_size*n),cell_size,cell_size)
         end
      end
   end
end

local PieceBucketSystem = System({PieceBucket})
function PieceBucketSystem:update()
   local piece_bucket
   for i = 1, self.pool.size do
      piece_bucket = self.pool:get(i)
      if #piece_bucket <= 7 then
         new_bucket = shuffle(piece_list)
         for k,v in pairs(new_bucket) do table.insert(piece_bucket, v) end
      end
   end
end



Game:addSystem(PieceBucketSystem(), "update")
Game:addSystem(BoardRendererSystem(), "draw")
--### SYSTEMS END
