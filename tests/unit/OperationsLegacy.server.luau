--!strict
-- Explicit fake-only retained acceptance. Never calls any real proof runner.
if game.ReplicatedStorage:GetAttribute("OperationsV11Legacy") ~= true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Test only")
assert(game.ReplicatedStorage:GetAttribute("RunRegressionTests") ~= true and game.ReplicatedStorage:GetAttribute("RunOperationsTests") ~= true, "One runner")
-- These suites intentionally have different return arities; only their assertions are used.
require(script.Parent["P2a.spec"])()
require(script.Parent["P3c.spec"])()
require(script.Parent["P3cSafety.spec"])()
require(script.Parent["FirstPlayable.spec"])()
require(script.Parent["P2bAccounting.spec"])()
require(script.Parent["P3cRegression.spec"])()
require(game.ServerScriptService.Server.Services.PersistentTestService).startEconomy()
game.ReplicatedStorage:SetAttribute("OperationsLegacyReady", true)
print("[Operations V11 retained server] COMPLETE; pure/fake only")
