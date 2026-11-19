--!strict
if game.ReplicatedStorage:GetAttribute("RunIllustratedTests")~=true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
local fixtures=require(script.Parent["IllustratedWorld.spec"])()
require(script.Parent["LandscapeComposition.spec"])(fixtures)
local existing=game.ReplicatedStorage:FindFirstChild("IllustratedFixtures")
local value=if existing then existing :: StringValue else Instance.new("StringValue")
value.Name="IllustratedFixtures";value.Value=game.HttpService:JSONEncode(fixtures)
value.Parent=game.ReplicatedStorage
game.ReplicatedStorage:SetAttribute("LandscapePurePassed",true)
