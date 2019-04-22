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

local Color = Component(function(e,value)
   e.value = value
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

local isBoard = Component()

local mt = {
   {0,1,0},
   {1,1,1},
   {0,0,0}
   }

-- Could be done with a for cycle, but this helps visualising the representation of the board state
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


local e = Entity()
e:give(Position,250,125)
e:give(Grid,20,board)
e:give(Color,4)
e:give(isBoard)
Game:addEntity(e)

local inputKeys = {left = false,right = false,up = false,down = false,space = false,c = false,x = false}

local e = Entity()
e:give(Position,4,2)
e:give(Grid,20,mt)
e:give(Controllable)
e:give(Color,1)
e:give(Input,{"left","right","up","down","space","c","x"})
e:give(ARR,30)
e:give(DAS,0.132)
--30
--0.132

Game:addEntity(e)

colorPatterns = {{1,0,0},{0,1,0},{0,0,1},{1,1,1}}

local BoardRenderer = System({isBoard})
function BoardRenderer:draw()
    local e
    local squareColor
    for i = 1, self.pool.size do
        e = self.pool:get(i)
        local position = e:get(Position)
        local grid = e:get(Grid)
        local boardLineColor = e:get(Color).value
        local cellSize = grid.cellSize
        for i = 1, #grid.grid do
            for j = 1, #grid.grid[1] do
                if grid.grid[i][j]~=0 then
                    squareColor = colorPatterns[grid.grid[i][j]]
                    love.graphics.setColor(squareColor)
                    love.graphics.rectangle("fill",position.x + (cellSize*j),position.y + (cellSize*i),cellSize,cellSize)
                end
                love.graphics.setColor(colorPatterns[boardLineColor])
                love.graphics.rectangle("line",position.x + (cellSize*j),position.y + (cellSize*i),cellSize,cellSize)
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

local PieceInputSystem = System({Input,Controllable})
function PieceInputSystem:update(dt)
    local e
    for i = 1, self.pool.size do
        e= self.pool:get(i)
        local input = e:get(Input).inputs
        local das = e:get(DAS)
        for k,v in pairs(input) do
            if(love.keyboard.isDown(k)) then
                input[k] = true
            else
                input[k] = false
            end
        end
    end
end


local PieceControlSystem = System({Grid})
function PieceControlSystem:moveHorizontally(piece,board,dt)
    local input = piece:get(Input).inputs
    local das = piece:get(DAS)
    local arr = piece:get(ARR)
    if input["left"] and input["right"] then
        das.activated = false
        das.current = 0
        return 
    end
    local cellSize = piece:get(Grid).cellSize
    if das.activated and arr.current <= arr.max then
        arr.current = arr.current + dt
        return
    else
        arr.current = 0
    end

    if input["left"] then
        PieceControlSystem:move(piece,board,"left")
    elseif input["right"] then
        PieceControlSystem:move(piece,board,"right")
    end
end

function PieceControlSystem:move(piece,board,direction)
    local piecePosition = piece:get(Position)
    local pieceGrid = piece:get(Grid).grid
    local boardGrid = board:get(Grid).grid

    -- Clear piece from previous state
    for i=1,#pieceGrid do
        for j=1,#pieceGrid[1] do
            if pieceGrid[i][j] ~= 0 then
                boardGrid[i+piecePosition.y][j+piecePosition.x] = 0
            end
        end
    end
  
    -- Add piece to new state
    if direction == "left" then 
        local newX = piece:get(Position).x - 1
        if PieceControlSystem:isMovePossible(pieceGrid,boardGrid,newX,piecePosition.y) then
            piece:get(Position).x = piece:get(Position).x - 1
        end
      elseif direction == "right" then 
        local newX = piece:get(Position).x + 1
        if PieceControlSystem:isMovePossible(pieceGrid,boardGrid,newX,piecePosition.y) then
            piece:get(Position).x = piece:get(Position).x + 1
        end
      elseif direction == "down" then 
        local newY = piece:get(Position).y + 1
        if PieceControlSystem:isMovePossible(pieceGrid,boardGrid,piecePosition.x,newY) then
            piece:get(Position).y = piece:get(Position).y + 1
        end
    end

    local color = piece:get(Color).value
    for i=1,#pieceGrid do
        for j=1,#pieceGrid[1] do
            if pieceGrid[i][j] ~= 0 then
                boardGrid[i+piecePosition.y][j+piecePosition.x] = pieceGrid[i][j]*color
            end
        end
    end
    printGrid(boardGrid)
    print("=")  
end

function PieceControlSystem:isMovePossible(pieceGrid, boardGrid, x, y)
    for i=1,#pieceGrid do
        for j=1,#pieceGrid[1] do
            if pieceGrid[i][j] ~= 0 then
                if i + y > #boardGrid then return false end
                if pieceGrid[i][j] and boardGrid[i + y][j + x] ~= 0 then
                    return false
                end
            end
        end
    end
    return true
end

function PieceControlSystem:moveDown(piece,board,dt)
    local input = piece:get(Input).inputs
    local cellSize = piece:get(Grid).cellSize
    PieceControlSystem:move(piece,board,"down")
    --e:get(Position).y = e:get(Position).y + 1
end

function PieceControlSystem:update(dt)
    local piece,board
    for i = 1, self.pool.size do
        if self.pool:get(i):get(Controllable) then
            piece = self.pool:get(i)
        elseif self.pool:get(i):get(isBoard) then
            board = self.pool:get(i)
        end
    end
    local input = piece:get(Input).inputs
    local das = piece:get(DAS)
    if input["down"] then PieceControlSystem:moveDown(piece,board,dt) end
    if input["left"] or input["right"] then 
        if not das.activated then
            PieceControlSystem:moveHorizontally(piece,board,dt)
            das.activated = true
        elseif das.activated and das.current <= das.max then
            das.current = das.current + dt
        else
            PieceControlSystem:moveHorizontally(piece,board,dt)
        end
    else
        das.activated = false
        das.current = 0
    end
end


function printGrid(grid)
    for i=1,#grid do
        local finalLine = ""
        for j=1,#grid[1] do
            finalLine = finalLine .. grid[i][j] .. " "
        end
        print(finalLine)
    end
end


Game:addSystem(PieceInputSystem(), "update")
Game:addSystem(PieceControlSystem(), "update")
--Game:addSystem(PieceRenderer(), "draw")
Game:addSystem(BoardRenderer(), "draw")