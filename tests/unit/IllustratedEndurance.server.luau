--!strict
-- The standalone tail does not enable Bootstrap's full-regression preview services.
if game.ReplicatedStorage:GetAttribute("RunIllustratedEnduranceTail")~=true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
assert(game.ReplicatedStorage:GetAttribute("RunRegressionTests")~=true,"One preview-service owner")
require(game.ServerScriptService.Server.World.GeneratedService).start()
