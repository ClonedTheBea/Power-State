--!strict
if game.ReplicatedStorage:GetAttribute("RunRegressionTests")~=true then return end
if not game:GetService("RunService"):IsStudio() then return end
local run = require(script.Parent.unit["Shell.spec"])
run()
local runCurrency = require(script.Parent.unit["CurrencyFormat.spec"])
runCurrency()

require(script.Parent.unit["P2a.spec"])()
if game.GameId==10776833313 then
 require(script.Parent.unit["P3c.spec"])()
 require(script.Parent.unit["FirstPlayable.spec"])()
 require(script.Parent.unit["P3cSafety.spec"])()
 require(game.ServerScriptService.Server.Services.ConstructionTestService).start()
 task.delay(10,function()require(script.Parent.unit["P3cAccounting.spec"])()end)
end
