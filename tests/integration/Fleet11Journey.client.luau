--!strict
if game.ReplicatedStorage:GetAttribute("RunFleet11Journey")~=true then return end
assert(game:GetService("RunService"):IsStudio()and game.GameId==10776833313,"Isolated fake Test only")
local deadline=os.clock()+600
repeat task.wait(.25)until game.ReplicatedStorage:GetAttribute("Fleet11PureComplete")==true or os.clock()>deadline
assert(game.ReplicatedStorage:GetAttribute("Fleet11PureComplete")==true,"Pure tests must finish before GUI timing checks")
local gui=game.Players.LocalPlayer:WaitForChild("PlayerGui")::PlayerGui
require(script.Parent["FirstPlayable.spec"])(gui)
require(script.Parent["FirstPlayableRemote.spec"])(gui)
local Client=require(script.Parent.Parent.Client.Simulation.ConstructionClient)
deadline=os.clock()+90
repeat task.wait(.2)until Client.active().current().bankMinor>=425000 or os.clock()>deadline
assert(Client.active().current().bankMinor>=425000,"Genuine bounded test funding required")
require(script.Parent["OwnedFleet.spec"])(gui)
print("FLEET11_NORMAL_JOURNEY_PASS")
