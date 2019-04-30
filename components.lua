local Concord = require("modules.Concord")
local Component = Concord.component
local gd = require("gamedata")
local hf = require("helperfunctions")
local components = {}

components.ARR = Component(function(e,rate)
    e.max = 1.0 / rate
    e.current = 0
    e.must_be_reset = true
end)

components.CanGoDown = Component(function(e)
    e.can_go_down = true
end)

components.CellSize = Component(function(e, cell_size)
    e.cell_size = cell_size
end)

components.Color = Component(function(e,value)
    e.color = value
end)

components.ColorValues = Component(function(e,values)
    e.color_values = values
end)

components.DAS = Component(function(e,value)
    e.max = value
    e.current = 0
end)

components.DownSpeed = Component(function(e,rate)
    e.max = 1.0 / rate
    e.current = 0
    e.must_be_reset = true
end)

components.GameOver = Component(function(e)
    e.game_over = false
end)

components.Grid = Component(function(e, grid)
    e.grid = hf.deepcopy(grid)
end)

components.HeldPiece = Component(function(e)
    e.held_piece = ""
    e.turn_held = 0
end)

components.Input = Component(function(e,keys)
    e.inputs = {}
    for i=1,#keys do
        e.inputs[keys[i]] = false
    end
end)

components.IsActive = Component(function(e,active)
    e.active = active
end)

components.IsBoard = Component()

components.IsPiece = Component()

components.Input = Component(function(e,keys)
    e.inputs = {}
    for i=1,#keys do
        e.inputs[keys[i]] = false
    end
end)

components.LastAction = Component(function(e)
    e.value = 0
end)

components.LastInput = Component(function(e,keys)
    e.inputs = {}
    for i=1,#keys do
        e.inputs[keys[i]] = false
    end
end)

components.LinesCleared = Component(function(e)
    e.lines_cleared = 0
    e.turn_checked = 0
end)

components.MutablePosition = Component(function(e, x, y)
    e.x = x
    e.y = y
end)

components.Name = Component(function(e,name)
    e.name = name
end)

components.PieceBucket = Component(function(e)
    e.pieces = {}
end)

components.PieceList = Component(function(e,pieces)
    e.pieces = pieces
end)

components.Position = Component(function(e, x, y)
    e.x = x
    e.y = y
end)

components.Rotations = Component(function(e,rotations)
    e.rotations = rotations
    e.current_rotation = 1
end)

components.TimeCounter = Component(function(e)
    e.time_counter = 0
end)

components.Turns = Component(function(e)
    e.turns = 1
end)

components.VisibilityLimit = Component(function(e,limit)
    e.limit = limit
end)

components.VisiblePieces = Component(function(e)
    e.pieces = {}
end)

return components
