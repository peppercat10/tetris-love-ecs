local Concord = require("modules.Concord").init({
   useEvents = true
})
local Entity    = Concord.entity
local Component = Concord.component
local System    = Concord.system
local Game = Concord.instance()
Concord.addInstance(Game)

local gd = require("gamedata")
local hf = require("helperfunctions")
local cmp = require("components")
local ent = require("entities")
local syst = require("systems")

math.randomseed(os.time() )

--### Adding entities
for k,v in pairs(ent) do
    Game:addEntity(v)
end

--### Adding systems
Game:addSystem(syst.LineClearSystem(),         "update")
Game:addSystem(syst.InputSystem(),             "update")
Game:addSystem(syst.PieceBucketSystem(),       "update")
Game:addSystem(syst.PieceHoldSystem(),         "update")
Game:addSystem(syst.ActivePieceSetterSystem(), "update")
Game:addSystem(syst.MovementSystem(),          "update")
Game:addSystem(syst.PieceGravitySystem(),      "update")
Game:addSystem(syst.PieceLockerSystem(),       "update")
Game:addSystem(syst.RotationSystem(),          "update")
Game:addSystem(syst.TimeCounterSystem(),       "update")
Game:addSystem(syst.PauseSystem(),             "update")
Game:addSystem(syst.GameOverSystem(),          "update")
Game:addSystem(syst.RestartSystem(),           "update")

Game:addSystem(syst.BoardRendererSystem(),          "draw")
Game:addSystem(syst.IncomingPiecesRendererSystem(), "draw")
Game:addSystem(syst.HeldPieceRendererSystem(),      "draw")
Game:addSystem(syst.ScoreboardRendererSystem(),     "draw")
