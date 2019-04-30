local Concord = require("modules.Concord")
local Entity    = Concord.entity
local Component = Concord.component
local System    = Concord.system
local gd = require("gamedata")
local hf = require("helperfunctions")
local cmp = require("components")
local ent = require("entities")
local systems = {}

function IsCollision(piece,board,direction)
    local piece_grid = piece:get(cmp.Rotations).rotations[piece:get(cmp.Rotations).current_rotation]
    local piece_mutpos = piece:get(cmp.MutablePosition)
    local board_grid = board:get(cmp.Grid).grid
    local current_square_color,test_square_color
    local n_value = 0
    local m_value = 0
    if direction == "down" then
       n_value = 1
    elseif direction == "left" then
       m_value = -1
    elseif direction == "right" then
       m_value = 1
    end
         
    for n=1, #piece_grid do
       for m=1, #piece_grid[1] do
          current_square_color = piece_grid[n][m]
          if current_square_color ~= 0 then 
             if piece_grid[n +n_value] == nil or piece_grid[ n +n_value][ m + m_value] == nil 
                         or piece_grid[n+n_value][m + m_value] == 0 then
                if board_grid[piece_mutpos.y + n + n_value] == nil 
                         or board_grid[piece_mutpos.y + n + n_value][piece_mutpos.x + m + m_value] ~= 0 then
                   
                   return true
                end
             end
          end
       end
    end
     return false
 end
 

 function changePieceOnBoard(piece,board,color)
    local piece_grid = piece:get(cmp.Rotations).rotations[piece:get(cmp.Rotations).current_rotation]
    local board_grid = board:get(cmp.Grid).grid
    local piece_position = piece:get(cmp.MutablePosition)
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

 function GetNextRotationNumber(piece,direction)
     local sum = 0
     local current_rotation = piece:get(cmp.Rotations).current_rotation
     if direction == "cw" then 
         sum = 1
     elseif direction == "ccw" then
         sum = -1
     end
     current_rotation = current_rotation + sum
     if current_rotation > 4 then
         current_rotation = 1
     elseif current_rotation < 1 then
         current_rotation = 4
     end
     return current_rotation
 end
 
 
 function CanRotate(piece,board,rotation)
     local current_rotation_number = piece:get(cmp.Rotations).current_rotation
     local current_piece_grid = piece:get(cmp.Rotations).rotations[current_rotation_number]
     local future_rotation_number = GetNextRotationNumber(piece,rotation)
     local future_piece_grid = piece:get(cmp.Rotations).rotations[future_rotation_number]
     local piece_mutpos = piece:get(cmp.MutablePosition)
     local board_grid = board:get(cmp.Grid).grid
     local test_position = {x=0,y=0}
     local rotation_failed = true
 
     for n=1,#future_piece_grid do
         for m=1, #future_piece_grid[1] do
             if future_piece_grid[n][m] ~= 0 and current_piece_grid[n][m] == 0 then
                 if board_grid[n+piece_mutpos.y][m+piece_mutpos.x] ~= 0 then
                     goto failed
                 end
             end
         end
     end
     rotation_failed = false
     ::failed::
     if rotation_failed == false then
         return {x =0, y = 0}
     end
     return nil
 end


systems.BoardRendererSystem = System({cmp.IsBoard})
function systems.BoardRendererSystem:draw()
   local brd
   for i = 1, self.pool.size do
      brd = self.pool:get(i)

      local brd_grid = brd:get(cmp.Grid).grid
      local brd_position = brd:get(cmp.Position)
      local color_values = brd:get(cmp.ColorValues).color_values
      local brd_color = color_values[brd:get(cmp.Color).color]
      local cell_size = brd:get(cmp.CellSize).cell_size
      local square_color,square_number

      for n = 5, #brd_grid do
         for m = 1, #brd_grid[1] do
            square_number = brd_grid[n][m]
            if square_number ~= 0 then
               square_color = color_values[square_number]
               if square_color ~= nil then
                love.graphics.setColor(square_color)
               else
                return
               end
               love.graphics.rectangle("fill",brd_position.x + (cell_size*m),brd_position.y + (cell_size*n),cell_size,cell_size)

            end
            love.graphics.setColor(brd_color)
            love.graphics.rectangle("line", brd_position.x + (cell_size*m), brd_position.y + (cell_size*n),cell_size,cell_size)
         end
      end
   end
end

systems.PieceBucketSystem = System({cmp.VisiblePieces})
function systems.PieceBucketSystem:update()
    if gd.pause then return end
   local piece_bucket,visible_pieces
   for i = 1, self.pool.size do
      piece_bucket = self.pool:get(i):get(cmp.PieceBucket).pieces
      visible_pieces = self.pool:get(i):get(cmp.VisiblePieces).pieces
      if #piece_bucket <= 7 then
         new_bucket = hf.shuffle(gd.piece_list)
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

systems.IncomingPiecesRendererSystem = System({cmp.IsBoard,"boardPool"},{cmp.IsPiece,"piecePool"})
function systems.IncomingPiecesRendererSystem:drawPiece(piece,x_position,y_position,cell_size)
    grid = piece:get(cmp.Grid).grid
    color = gd.colorPatterns[piece:get(cmp.Color).color]
    grid_color = gd.colorPatterns[1]
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

function systems.IncomingPiecesRendererSystem:draw()

    local board, y_draw, cell_size, future_pieces
    for i = 1, self.boardPool.size do
        board = self.boardPool:get(i)
        future_pieces = board:get(cmp.VisiblePieces).pieces
        cell_size = board:get(cmp.CellSize).cell_size
        x_draw = cell_size * (#board:get(cmp.Grid).grid)
        y_draw = board:get(cmp.Position).y + cell_size*4
        y_gap = cell_size * 3
        if #future_pieces > 0 then
            local y_current = y_draw
            local wanted_piece
            for j = 2, #future_pieces do
                for h = 1, self.piecePool.size do
                    if self.piecePool:get(h):get(cmp.Name).name == future_pieces[j] then
                        wanted_piece = self.piecePool:get(h)
                        break
                    end
                end                
                systems.IncomingPiecesRendererSystem:drawPiece(wanted_piece,x_draw,y_current,cell_size)
                y_current = y_current + y_gap
            end
        end
    end
end

systems.ActivePieceSetterSystem = System({cmp.IsBoard,"boardPool"},{cmp.IsPiece,"piecePool"})
function systems.ActivePieceSetterSystem:update()
    if gd.pause then return end
    local active_piece_name
    local active_piece
    local visible_pieces
    local board_grid
    for i = 1, self.piecePool.size do
        if self.piecePool:get(i):get(cmp.IsActive).active then return end
        
    end

    for i = 1, self.boardPool.size do
        visible_pieces = self.boardPool:get(i):get(cmp.VisiblePieces).pieces
        board_grid = self.boardPool:get(i):get(cmp.Grid).grid
        self.boardPool:get(i):get(cmp.LastAction).value = 0
        if not visible_pieces[1] then
            return
        else
            active_piece_name = visible_pieces[1]
        end
        for i = 1, self.piecePool.size do
            if self.piecePool:get(i):get(cmp.Name).name == active_piece_name then
                active_piece = self.piecePool:get(i)
                break
            end
        end 
        active_piece:get(cmp.IsActive).active = true
        local piece_grid = active_piece:get(cmp.Grid).grid
        local piece_position = active_piece:get(cmp.Position)
        active_piece:get(cmp.MutablePosition).x = piece_position.x
        active_piece:get(cmp.MutablePosition).y = piece_position.y
        active_piece:get(cmp.CanGoDown).can_go_down = true
        active_piece:get(cmp.Rotations).current_rotation = 1
        local color_number = active_piece:get(cmp.Color).color
        local current_cell_to_add
        for n = 1, #piece_grid do
            for m = 1, #piece_grid[1] do
                if piece_grid[n][m] ~= 0 then
                    current_cell_to_add = {y = n + piece_position.y, x = m + piece_position.x }
                    if board_grid[current_cell_to_add.y][current_cell_to_add.x] ~= 0 then 
                        self.boardPool:get(i):get(cmp.GameOver).game_over = true
                        return
                    end
                    board_grid[current_cell_to_add.y][current_cell_to_add.x] = color_number
                end
            end
        end
    end
end

systems.PieceGravitySystem = System({cmp.IsActive,"piecePool"},{cmp.IsBoard,"boardPool"})
function systems.PieceGravitySystem:pushDown(piece,board)

    if IsCollision(piece,board,"down") == true then
         piece:get(cmp.CanGoDown).can_go_down = false
        return
    end
    piece:get(cmp.CanGoDown).can_go_down = true
    changePieceOnBoard(piece,board,0)

    piece:get(cmp.MutablePosition).y = piece:get(cmp.MutablePosition).y + 1
    changePieceOnBoard(piece,board,piece:get(cmp.Color).color)
end

function systems.PieceGravitySystem:update(dt)
    if gd.pause then return end
    local active_piece
    local active_board
    for i = 1, self.boardPool.size do
        active_board = self.boardPool:get(i)
        
    end 

    local last_action = active_board:get(cmp.LastAction).value
    if last_action < 1.0 then
        active_board:get(cmp.LastAction).value = active_board:get(cmp.LastAction).value + dt
        return
    end
    last_action = 0
    for i = 1, self.piecePool.size do
        if self.piecePool:get(i):get(cmp.IsActive).active then
            active_piece = self.piecePool:get(i)
            systems.PieceGravitySystem:pushDown(active_piece,active_board)
            if(active_piece:get(cmp.CanGoDown).can_go_down == true) then
               active_board:get(cmp.LastAction).value = 0
            end
        end
    end
end

systems.PieceLockerSystem = System({cmp.IsActive,"piecePool"},{cmp.IsBoard,"boardPool"})
function systems.PieceLockerSystem:lock(piece,board)
   piece:get(cmp.IsActive).active = false
   table.remove(board:get(cmp.VisiblePieces).pieces,1)
   board:get(cmp.Turns).turns = board:get(cmp.Turns).turns + 1
end
function systems.PieceLockerSystem:update()
    if gd.pause then return end
   local active_piece,active_board,last_action,can_go_down
   for i=1, self.boardPool.size do
      active_board = self.boardPool:get(i)
      for j=1, self.piecePool.size do
        if self.piecePool:get(j):get(cmp.IsActive).active then
            active_piece = self.piecePool:get(j)
            last_action = active_board:get(cmp.LastAction).value
            can_go_down = active_piece:get(cmp.CanGoDown).can_go_down
            if last_action >= 0.9 and can_go_down == false then
                systems.PieceLockerSystem:lock(active_piece,active_board)
            end
        end
      end
   end
end

systems.InputSystem = System({cmp.Input})
function systems.InputSystem:update(dt)
    local e
    for i = 1, self.pool.size do
        e = self.pool:get(i)
        local input = e:get(cmp.Input).inputs
        local last_input = e:get(cmp.LastInput).inputs
        for k,v in pairs(input) do
            if(love.keyboard.isDown(k)) then
                input[k] = true
            else
                input[k] = false
                last_input[k] = false
            end
        end
    end
end

systems.MovementSystem = System({cmp.IsBoard,"boardPool"},{cmp.IsActive,"piecePool"})
function systems.MovementSystem:MoveLeft(piece,board)
    changePieceOnBoard(piece,board,0)
    piece:get(cmp.MutablePosition).x = piece:get(cmp.MutablePosition).x - 1
    changePieceOnBoard(piece,board,piece:get(cmp.Color).color)
end

function systems.MovementSystem:MoveRight(piece,board)
    changePieceOnBoard(piece,board,0)
    piece:get(cmp.MutablePosition).x = piece:get(cmp.MutablePosition).x + 1
    changePieceOnBoard(piece,board,piece:get(cmp.Color).color)    
end

function systems.MovementSystem:MoveDown(piece,board)
    changePieceOnBoard(piece,board,0)
    piece:get(cmp.MutablePosition).y = piece:get(cmp.MutablePosition).y + 1
    changePieceOnBoard(piece,board,piece:get(cmp.Color).color)    
end

function systems.MovementSystem:CanMoveDASARR(board,direction,dt,dasarr)
    local last_input = board:get(cmp.LastInput).inputs

    if last_input[direction] == false then
        dasarr.current = 0
        return true
    end
    if dasarr.current >= dasarr.max then
        if dasarr.must_be_reset then
            dasarr.current = 0
        end
        return true
    else
        dasarr.current = dasarr.current + dt
        return false
    end
end


function systems.MovementSystem:update(dt)
    if gd.pause then return end
    local active_board, active_piece, cell_size, inputs
    for i = 1, self.boardPool.size do
        active_board = self.boardPool:get(i)
        cell_size = active_board:get(cmp.CellSize).cell_size
        inputs = active_board:get(cmp.Input).inputs
        for j = 1, self.piecePool.size do
            if self.piecePool:get(j):get(cmp.IsActive).active then
                active_piece = self.piecePool:get(j)
                local das = active_board:get(cmp.DAS)
                local arr = active_board:get(cmp.ARR)
                local down_speed = active_board:get(cmp.DownSpeed)
                local last_inputs = active_board:get(cmp.LastInput).inputs
                local last_action = active_board:get(cmp.LastAction).last_action
                if inputs.space then
                    local grid_size = #active_board:get(cmp.Grid).grid
                    
                    for i = 1, grid_size  do
                        if last_inputs.space == false then
                            active_board:get(cmp.LastAction).value = 1.0
                            if not IsCollision(active_piece,active_board,"down") and last_inputs.space == false then
                                systems.MovementSystem:MoveDown(active_piece,active_board)
                            else 
                                last_inputs.space = true
                                last_action = 0
                                break
                            end
                        end
                    end
                end


                if inputs.left and systems.MovementSystem:CanMoveDASARR(active_board,"left",dt,das) then
                    if systems.MovementSystem:CanMoveDASARR(active_board,"left",dt,arr) 
                            and not IsCollision(active_piece,active_board,"left") then
                        systems.MovementSystem:MoveLeft(active_piece,active_board)
                        last_inputs.left = true
                        last_action = 0
                    end

                elseif inputs.right and systems.MovementSystem:CanMoveDASARR(active_board,"right",dt,das) then
                    if systems.MovementSystem:CanMoveDASARR(active_board,"right",dt,arr) 
                            and not IsCollision(active_piece,active_board,"right") then
                        systems.MovementSystem:MoveRight(active_piece,active_board)
                        last_inputs.right = true
                        last_action = 0
                    end

                elseif inputs.down and systems.MovementSystem:CanMoveDASARR(active_board,"down",dt,down_speed) then
                    if not IsCollision(active_piece,active_board,"down") then
                        systems.MovementSystem:MoveDown(active_piece,active_board)
                        last_inputs.down = true
                        last_action = 0
                    end
                end
                
            end
        end
    end
end

systems.RotationSystem = System({cmp.IsBoard,"boardPool"},{cmp.IsActive,"piecePool"})
function systems.RotationSystem:update()
    if gd.pause then return end
    local active_board, active_piece, current_input, last_input
    for i = 1, self.boardPool.size do
        active_board = self.boardPool:get(i)
        current_input = active_board:get(cmp.Input).inputs
        last_input = active_board:get(cmp.LastInput).inputs
        
        for j = 1, self.piecePool.size do
            active_piece = self.piecePool:get(j)
            local rotations = active_piece:get(cmp.Rotations)
            local position_to_rotate
            if active_piece:get(cmp.IsActive).active then
                if current_input.up == true and last_input.up == false then
                    last_input.up = true
                    position_to_rotate = CanRotate(active_piece,active_board,"cw") 
                    if position_to_rotate ~= nil then
                        changePieceOnBoard(active_piece,active_board,0)
                        active_piece:get(cmp.MutablePosition).x = active_piece:get(cmp.MutablePosition).x + position_to_rotate.x
                        active_piece:get(cmp.MutablePosition).y = active_piece:get(cmp.MutablePosition).y + position_to_rotate.y
                        rotations.current_rotation = GetNextRotationNumber(active_piece,"cw")
                        changePieceOnBoard(active_piece,active_board,active_piece:get(cmp.Color).color)
                    end
                end
            end
        end
        
    end

end

systems.PieceHoldSystem = System({cmp.IsBoard,"boardPool"},{cmp.IsActive,"piecePool"})

function systems.PieceHoldSystem:update()
    if gd.pause then return end
    local active_board,held_piece,active_piece,inputs,turns
    for i=1,self.boardPool.size do
        active_board = self.boardPool:get(i)
        turns = active_board:get(cmp.Turns).turns
        held_piece = active_board:get(cmp.HeldPiece)
        inputs = active_board:get(cmp.Input).inputs
        if held_piece.turn_held == turns then
            return
        end
        if inputs.c then
            for j=1,self.piecePool.size do
                active_piece = self.piecePool:get(j)
                if active_piece:get(cmp.IsActive).active then
                    active_piece:get(cmp.IsActive).active = false
                    changePieceOnBoard(active_piece,active_board,0)
                    if held_piece.held_piece ~= "" then
                       active_board:get(cmp.VisiblePieces).pieces[1] = held_piece.held_piece
                    else
                        table.remove(active_board:get(cmp.VisiblePieces).pieces,1)
                    end
                    held_piece.held_piece = active_piece:get(cmp.Name).name
                    held_piece.turn_held = turns
                end
            end
        end
    end
end

systems.HeldPieceRendererSystem = System({cmp.IsBoard,"boardPool"},{cmp.IsPiece,"piecePool"})
function systems.HeldPieceRendererSystem:draw()
    local board,cell_size,piece,piece_name,piece_grid,color
    local offset = {x = 0, y = 0}
    for i=1, self.boardPool.size do
        board = self.boardPool:get(i)
        cell_size = board:get(cmp.CellSize).cell_size
        piece_name = board:get(cmp.HeldPiece).held_piece
        if piece_name == "" then return end
        for j=1, self.piecePool.size do
            if piece_name == self.piecePool:get(j):get(cmp.Name).name then
                piece = self.piecePool:get(j)
                color = piece:get(cmp.Color).color
                break
            end
        end
        piece_grid = piece:get(cmp.Grid).grid
        offset.x = board:get(cmp.Position).x - 5*cell_size
        offset.y = board:get(cmp.Position).y + 4*cell_size
        for n = 1, #piece_grid do
            for m = 1, #piece_grid[1] do
                if piece_grid[n][m] ~= 0 then
                    love.graphics.setColor(board:get(cmp.ColorValues).color_values[color])
                    love.graphics.rectangle("fill",offset.x + m*cell_size,offset.y + n*cell_size, cell_size, cell_size)
                    love.graphics.setColor(board:get(cmp.ColorValues).color_values[1])
                    love.graphics.rectangle("line",offset.x + m*cell_size,offset.y + n*cell_size, cell_size, cell_size)
                end
            end
        end
    end
end

systems.LineClearSystem = System({cmp.LinesCleared})
function systems.LineClearSystem:shiftRight(board_grid,zero_line)
    local line_to_shift
    for i=1,zero_line do
        line_to_copy_from = zero_line - i
        if line_to_copy_from == 0 then return end
        print(line_to_copy_from)
        line_to_paste_to = zero_line - (i - 1)
        print(line_to_paste_to)
        for j = 1, #board_grid[1] do
            board_grid[line_to_paste_to][j] = board_grid[line_to_copy_from][j]
        end
    end
end

function systems.LineClearSystem:update()
    if gd.pause then return end
    local line_clear,board, board_grid
    local lines_to_remove = {}
    for i=1,self.pool.size do
        board = self.pool:get(i)
        line_clear = board:get(cmp.LinesCleared)
        if line_clear.turn_checked == board:get(cmp.Turns).turns then return end
        board_grid = board:get(cmp.Grid).grid
        for n=1, #board_grid do
            for m=1, #board_grid[1] do
                if board_grid[n][m] == 0 then goto not_clear end
            end
            table.insert(lines_to_remove,n)
            line_clear.lines_cleared = line_clear.lines_cleared + 1
            ::not_clear::
        end
        for j=1, #lines_to_remove do
            systems.LineClearSystem:shiftRight(board_grid,lines_to_remove[j])
        end
        line_clear.turn_checked = line_clear.turn_checked + 1
    end
end

systems.TimeCounterSystem = System({cmp.TimeCounter})
function systems.TimeCounterSystem:update(dt)
    for i=1, self.pool.size do
        self.pool:get(i):get(cmp.TimeCounter).time_counter = self.pool:get(i):get(cmp.TimeCounter).time_counter + dt
    end
end

systems.ScoreboardRendererSystem = System({cmp.LinesCleared,cmp.TimeCounter})
function systems.ScoreboardRendererSystem:draw()
    local board
    for i = 1, self.pool.size do
        board = self.pool:get(i)
        love.graphics.print("Lines cleared: " .. board:get(cmp.LinesCleared).lines_cleared,500,450,0,1)
        love.graphics.print("Time elapsed: " ..  math.floor(board:get(cmp.TimeCounter).time_counter) .. "s",500,470,0,1)
        if gd.pause then
            love.graphics.print("PAUSED",350,75,0,1) 
        end
    end
end

systems.PauseSystem = System({cmp.Input})
function systems.PauseSystem:update()
    local input, last_input
    for i = 1, self.pool.size do
        input = self.pool:get(i):get(cmp.Input).inputs
        last_input = self.pool:get(i):get(cmp.LastInput).inputs
        if last_input.p == true then return end
        if input.p == true then
            last_input.p = true
            if gd.pause == false then gd.pause = true else gd.pause = false end
        end
    end
end

systems.GameOverSystem = System({cmp.Input})
function systems.GameOverSystem:update()
    local game_over
    for i = 1, self.pool.size do
        game_over = self.pool:get(i):get(cmp.GameOver)
        if game_over.game_over then
            gd.pause = true
        end
    end
end

systems.RestartSystem = System({cmp.Input})
function systems.RestartSystem:update()
    local board,input,last_input
    for i = 1, self.pool.size do
        board = self.pool:get(i)
        input = self.pool:get(i):get(cmp.Input).inputs
        last_input = self.pool:get(i):get(cmp.LastInput).inputs
        if last_input.r == true then return end
        if input.r == true then
            love.event.quit("restart")
        end
        end             
end



return systems