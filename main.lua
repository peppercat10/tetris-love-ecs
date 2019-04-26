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
	{0,0,0,0,1,0,0,0,0,0},
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


local I_matrix = {
    {0,0,0,0},
    {1,1,1,1},
    {0,0,0,0},
    {0,0,0,0}
}

local J_matrix = {
    {1,0,0},
    {1,1,1},
    {0,0,0}
}

local L_matrix = {
    {0,0,1},
    {1,1,1},
    {0,0,0}
}

local O_matrix = {
    {1,1},
    {1,1}
}

local S_matrix = {
    {0,1,1},
    {1,1,0},
    {0,0,0}
}

local T_matrix = {
    {0,1,0},
    {1,1,1},
    {0,0,0}
}

local Z_matrix = {
    {1,1,0},
    {0,1,1},
    {0,0,0}
}

local piece_matrices = {I = I_matrix, J = J_matrix, L = L_matrix, O = O_matrix,S=S_matrix,T=T_matrix,Z = Z_matrix}


math.randomseed(os.time() )
local piece_list = {"O","L","S","Z","I","J","T"}

local colorPatterns = {
    {1,1,1},
    {0.921, 0.376, 0.376},
    {0.921, 0.662, 0.376},
    {0.490, 0.921, 0.376},
    {0.376, 0.815, 0.921},
    {0.376, 0.388, 0.921},
    {0.780, 0.376, 0.921},
    {0.894, 0.917, 0.4},}

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

function printArray(arr)
    local final_line = ""
    for i=1, #arr do
        final_line = final_line .. arr[i]
    end
    print(final_line)
    print("===")
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

local MutablePosition = Component(function(e, x, y)
    e.x = x
    e.y = y
 end)

local Grid = Component(function(e, grid)
   e.grid = deepcopy(grid)
end)

local CellSize = Component(function(e, cell_size)
   e.cell_size = cell_size
end) 

local IsActive = Component(function(e,active)
    e.active = active
end)

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

local VisiblePieces = Component(function(e)
    e.pieces = {}
end)

local PieceList = Component(function(e,pieces)
   e.pieces = pieces
end)

local IsPiece = Component()

local Name = Component(function(e,name)
    e.name = name
end)

local VisibilityLimit = Component(function(e,limit)
    e.limit = limit
end)

local LastAction = Component(function(e)
e.value = 0
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
brd:give(VisiblePieces):give(LastAction)
--brd:give(VisibilityLimit,20)
Game:addEntity(brd)

local piece_J = Entity()
piece_J:give(Grid,J_matrix)
piece_J:give(Color,2)
piece_J:give(IsPiece)
piece_J:give(Name,"J")
piece_J:give(IsActive,false):give(Position,3,0):give(MutablePosition,3,0)
Game:addEntity(piece_J)

local piece_L = Entity()
piece_L:give(Grid,L_matrix)
piece_L:give(Color,3)
piece_L:give(IsPiece)
piece_L:give(Name,"L")
piece_L:give(IsActive,false):give(Position,3,0):give(MutablePosition,3,0)
Game:addEntity(piece_L)

local piece_T = Entity()
piece_T:give(Grid,T_matrix)
piece_T:give(Color,4)
piece_T:give(IsPiece)
piece_T:give(Name,"T")
piece_T:give(IsActive,false):give(Position,3,0):give(MutablePosition,3,0)
Game:addEntity(piece_T)

local piece_S = Entity()
piece_S:give(Grid,S_matrix)
piece_S:give(Color,5)
piece_S:give(IsPiece)
piece_S:give(Name,"S")
piece_S:give(IsActive,false):give(Position,3,0):give(MutablePosition,3,0)
Game:addEntity(piece_S)

local piece_Z = Entity()
piece_Z:give(Grid,Z_matrix)
piece_Z:give(Color,6)
piece_Z:give(IsPiece)
piece_Z:give(Name,"Z")
piece_Z:give(IsActive,false):give(Position,3,0):give(MutablePosition,3,0)
Game:addEntity(piece_Z)

local piece_I = Entity()
piece_I:give(Grid,I_matrix)
piece_I:give(Color,7)
piece_I:give(IsPiece)
piece_I:give(Name,"I")
piece_I:give(IsActive,false):give(Position,3,0):give(MutablePosition,3,0)
Game:addEntity(piece_I)

local piece_O = Entity()
piece_O:give(Grid,O_matrix)
piece_O:give(Color,8)
piece_O:give(IsPiece)
piece_O:give(Name,"O")
piece_O:give(IsActive,false):give(Position,4,0):give(MutablePosition,4,0)
Game:addEntity(piece_O)


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
      --local visibility_limit = brd:get(VisibilityLimit).limit
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

local PieceBucketSystem = System({PieceBucket,VisiblePieces})
function PieceBucketSystem:update()
   local piece_bucket,visible_pieces
   for i = 1, self.pool.size do
      piece_bucket = self.pool:get(i):get(PieceBucket).pieces
      visible_pieces = self.pool:get(i):get(VisiblePieces).pieces
      if #piece_bucket <= 7 then
         new_bucket = shuffle(piece_list)
         for k,v in pairs(new_bucket) do table.insert(piece_bucket, v) end
      end
   end
   local pieces_to_add = 6 - #visible_pieces
   if pieces_to_add > 0 then
    local tmp_piece
    for i = 1, pieces_to_add do
        tmp_piece = table.remove(piece_bucket,1)
        table.insert(visible_pieces,tmp_piece)
    end
    end
end

local IncomingPiecesRendererSystem = System({IsBoard,"boardPool"},{IsPiece,"piecePool"})
function IncomingPiecesRendererSystem:drawPiece(piece,x_position,y_position,cell_size)
    grid = piece:get(Grid).grid
    color = colorPatterns[piece:get(Color).color]
    grid_color = colorPatterns[1]
    for n = 1, #grid do
        for m = 1, #grid[1] do
            if grid[n][m] ~= 0 then
                love.graphics.setColor(color)
                love.graphics.rectangle("fill",x_position + (cell_size*m),y_position + (cell_size*n),cell_size,cell_size)
                love.graphics.setColor(grid_color)
                love.graphics.rectangle("line",x_position + (cell_size*m),y_position + (cell_size*n),cell_size,cell_size)
            end
        end
    end

end

function IncomingPiecesRendererSystem:draw()
    local board, y_draw, cell_size, future_pieces
    for i = 1, self.boardPool.size do
        board = self.boardPool:get(i)
        future_pieces = board:get(VisiblePieces).pieces
        cell_size = board:get(CellSize).cell_size
        x_draw = cell_size * (#board:get(Grid).grid + 3.5)
        y_draw = board:get(Position).y
        y_gap = cell_size * 3
        if #future_pieces > 0 then
            local y_current = y_draw
            local wanted_piece
            for j = 2, #future_pieces do
                for h = 1, self.piecePool.size do
                    if self.piecePool:get(h):get(Name).name == future_pieces[j] then
                        wanted_piece = self.piecePool:get(h)
                        break
                    end
                end                
                IncomingPiecesRendererSystem:drawPiece(wanted_piece,x_draw,y_current,cell_size)
                y_current = y_current + y_gap
            end
        end
    end
end

local ActivePieceSetterSystem = System({IsBoard,"boardPool"},{IsPiece,"piecePool"})
function ActivePieceSetterSystem:update()
    local active_piece_name
    local active_piece
    local visible_pieces
    local board_grid
    for i = 1, self.piecePool.size do
        if self.piecePool:get(i):get(IsActive).active then return end
    end

    for i = 1, self.boardPool.size do
        visible_pieces = self.boardPool:get(i):get(VisiblePieces).pieces
        board_grid = self.boardPool:get(i):get(Grid).grid
        if not visible_pieces[1] then
            return
        else
            active_piece_name = visible_pieces[1]
        end
        for i = 1, self.piecePool.size do
            if self.piecePool:get(i):get(Name).name == active_piece_name then
                active_piece = self.piecePool:get(i)
                break
            end
        end 
        active_piece:get(IsActive).active = true
        local piece_grid = active_piece:get(Grid).grid
        local piece_position = active_piece:get(Position)
        active_piece:get(MutablePosition).x = piece_position.x
        active_piece:get(MutablePosition).y = piece_position.y
        local color_number = active_piece:get(Color).color
        local current_cell_to_add
        for n = 1, #piece_grid do
            for m = 1, #piece_grid[1] do
                if piece_grid[n][m] ~= 0 then
                    current_cell_to_add = {y = n+piece_position.y, x = m+piece_position.x }
                    board_grid[current_cell_to_add.y][current_cell_to_add.x] = color_number
                end
            end
        end
    end
end


function changePieceOnBoard(piece,board,color)
    local piece_grid = piece:get(Grid).grid
    --printGrid(piece_grid)
    local board_grid = board:get(Grid).grid
    local piece_position = piece:get(MutablePosition)
    local square
    for n = 1, #piece_grid do
        for m = 1, #piece_grid[1] do
            if piece_grid[n][m] ~= 0 then
                square = { x = m + piece_position.x, y = n + piece_position.y }
                board_grid[square.y][square.x] = color
            end
        end
    end    
end

function isCollision(piece,board,direction)
    local piece_grid = piece:get(Grid).grid
    local board_grid = board:get(Grid).grid
    local current_square,test_square,square_in_board

    if direction == "down" then
        --Step 1: iterate through all piece squares, ignore squares that belong to the piece and have another occupied square below them
        local current_square_color
        for n=1, #piece_grid do
            for m=1, #piece_grid do
                current_square_color = piece_grid[n][m]
                
            end
        end
    end
end

local PieceGravitySystem = System({IsActive,"piecePool"},{IsBoard,"boardPool"})
function PieceGravitySystem:pushDown(piece,board)
    -- Clear previous position
    if isCollision(piece,board,"down") then
        return
    end
    changePieceOnBoard(piece,board,0)

    -- Set new position
    piece:get(MutablePosition).y = piece:get(MutablePosition).y + 1
    changePieceOnBoard(piece,board,piece:get(Color).color)
end

function PieceGravitySystem:update(dt)
    local active_piece
    local active_board
    for i = 1, self.boardPool.size do
        active_board = self.boardPool:get(i)
        
    end 

    local last_action = active_board:get(LastAction).value
    if last_action < 1.0 then
        active_board:get(LastAction).value = active_board:get(LastAction).value + dt
        return
    end
    active_board:get(LastAction).value = 0
    last_action = 0
    for i = 1, self.piecePool.size do
        if self.piecePool:get(i):get(IsActive).active then
            active_piece = self.piecePool:get(i)
            PieceGravitySystem:pushDown(active_piece,active_board)
        end
    end
    
    

end

Game:addSystem(PieceBucketSystem(), "update")
Game:addSystem(ActivePieceSetterSystem(), "update")
Game:addSystem(PieceGravitySystem(), "update")
Game:addSystem(BoardRendererSystem(), "draw")
Game:addSystem(IncomingPiecesRendererSystem(), "draw")

--### SYSTEMS END
