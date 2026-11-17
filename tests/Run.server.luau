--!strict
if not game:GetService("RunService"):IsStudio() then return end
local run = require(script.Parent.unit["Shell.spec"])
run()
local runCurrency = require(script.Parent.unit["CurrencyFormat.spec"])
runCurrency()

require(script.Parent.unit["P2a.spec"])()
