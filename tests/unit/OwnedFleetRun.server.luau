--!strict
-- Opt-in Test diagnostics only; no real adapter or unattended normal startup.
if game.ReplicatedStorage:GetAttribute("RunOwnedFleetTests")~=true then return end
assert(game:GetService("RunService"):IsStudio()and game.GameId==10776833313 and game.CreatorId==149564436,"Approved fake Test only")
-- Keep the heavy synthetic fixtures away from initial GUI subscription checks.
task.wait(30)
local fixtures=require(script.Parent["FleetSchemaSize.spec"])()
require(script.Parent["FleetCodec.spec"])(fixtures)
require(script.Parent["OwnedFleetAccounting.spec"])(fixtures)
require(script.Parent["FleetTransactions.spec"])(fixtures)
require(script.Parent["OwnedFleetSecurity.spec"])(fixtures)
require(script.Parent["OwnedFleetCancellation.spec"])(fixtures)
require(script.Parent["OwnedFleetPerformance.spec"])(fixtures)
require(script.Parent["OwnedFleetBalance.spec"])(fixtures)
require(script.Parent["OwnedFleetProgression.spec"])()
game.ReplicatedStorage:SetAttribute("OwnedFleetPurePassed",true)
print("[Owned Fleet pure/fake] COMPLETE; no real storage")
