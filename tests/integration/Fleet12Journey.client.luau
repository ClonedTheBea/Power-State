--!strict
if game.ReplicatedStorage:GetAttribute("RunFleet12Journey")~=true then return end
assert(game:GetService("RunService"):IsStudio()and game.GameId==10776833313,"Fake Test journey only")
local gui=game.Players.LocalPlayer:WaitForChild("PlayerGui")::PlayerGui
local Client=require(script.Parent.Parent.Client.Simulation.ConstructionClient)
local loadDeadline=os.clock()+60
repeat task.wait(.1)until (Client.active()and Client.active().current().fleet)or os.clock()>loadDeadline
assert(Client.active()and Client.active().current().fleet,"Normal fake entry must load")
local began=os.clock()
require(script.Parent["FirstPlayable.spec"])(gui)
local live=Client.active();local districtAt=os.clock();local districtStep=live.current().step
assert(live.current().finance.bank.openingGrantMinor==100000,"One original grant")
assert(live.current().fleet.project.priceMinor==200000,"Explicit selected trial catalogue")
local deadline=os.clock()+1100;local last=0
repeat
 task.wait(1);live=Client.active()
 if os.clock()-last>=60 then
  last=os.clock();print("FLEET12_NORMAL_EARNING",live.current().step,live.current().bankMinor,"elapsed",os.clock()-began)
 end
until live.current().bankMinor>=225000 or os.clock()>deadline
assert(live.current().bankMinor>=225000,"Normal earnings must reach wind; no accelerator")
print("FLEET12_NORMAL_AFFORDABILITY",game.HttpService:JSONEncode({elapsedSeconds=os.clock()-began,
 districtElapsedSeconds=districtAt-began,afterDistrictSeconds=os.clock()-districtAt,districtStep=districtStep,
 windStep=live.current().step,bankMinor=live.current().bankMinor,warning="ordinary fake host; no diagnostic funding"}))
require(script.Parent["OwnedFleet.spec"])(gui,false,200000)
game.ReplicatedStorage.P3cConstruction:SetAttribute("Fleet12ClientJourneyComplete",true)
print("FLEET12_NORMAL_JOURNEY_PASS")
