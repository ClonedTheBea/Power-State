--!strict
if game.ReplicatedStorage:GetAttribute("RunIllustratedTests")~=true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Illustrated Test only")
assert(game.ReplicatedStorage:GetAttribute("RunRegressionTests")~=true,"One client test runner")
game.ReplicatedStorage:SetAttribute("IllustratedWorldProof",false)
local player=game.Players.LocalPlayer
local gui=player:WaitForChild("PlayerGui") :: PlayerGui
local shell=gui:WaitForChild("PowerStateShell",60);assert(shell,"Initial fake shell")
local pureDeadline=os.clock()+30
while game.ReplicatedStorage:GetAttribute("LandscapePurePassed")~=true do
	assert(os.clock()<pureDeadline,"Fresh landscape pure tests must pass")
	game:GetService("RunService").Heartbeat:Wait()
end
local fixtures=game.HttpService:JSONDecode((game.ReplicatedStorage:WaitForChild("IllustratedFixtures",10) :: StringValue).Value)
if game.ReplicatedStorage:GetAttribute("RunOrganicFilterProbe")==true then
 require(script.Parent.IllustratedWorld.OrganicFilterProbe)(gui,fixtures[1]);return
end
if game.ReplicatedStorage:GetAttribute("RunOrganicSoak")==true then
 if game.ReplicatedStorage:GetAttribute("RunOrganicGroundTests")==true then
  require(script.Parent.IllustratedWorld["OrganicGround.spec"])(gui,fixtures)
 end
 require(script.Parent.IllustratedWorld.OrganicSoak)(gui,fixtures[1]);return
end
if game.ReplicatedStorage:GetAttribute("RunOrganicGeometryTests")==true then
 require(script.Parent.IllustratedWorld["OrganicCoast.spec"])(fixtures)
 if game.ReplicatedStorage:GetAttribute("OrganicGeometryOnly")==true then return end
end
if game.ReplicatedStorage:GetAttribute("RunOrganicGroundTests")==true then
 require(script.Parent.IllustratedWorld["OrganicGround.spec"])(gui,fixtures)
 if game.ReplicatedStorage:GetAttribute("OrganicGroundOnly")==true then return end
end
task.wait(1)
require(script.Parent.IllustratedWorld["IllustratedWorld.spec"])(gui,fixtures)
if game.ReplicatedStorage:GetAttribute("RunContinuousGroundTests")==true then
 require(script.Parent.IllustratedWorld["ContinuousGround.spec"])(gui,fixtures)
end
game.ReplicatedStorage:SetAttribute("IllustratedTestsPassed",true)
local App=require(script.Parent.Parent.Client.Controllers.AppController)
local Controller=require(script.Parent.IllustratedWorld.IllustratedController)
local mounted: any=nil
local function capture()
	local which=game.ReplicatedStorage:GetAttribute("IllustratedCapture") or "1-Native"
	if mounted then mounted.destroy() end
	local index=tonumber(string.sub(which :: string,1,1)) or 1
	local fixture=fixtures[index];assert(fixture,"Known fixture")
	mounted=App.mount(gui,fixture)
	local proof=Controller.attach(mounted,fixture)
	for i,line in mounted.view.map.linkFrames do line:SetAttribute("PreviewOnly",i==3 and not string.find(which :: string,"Built",1,true)) end
	local w=game.ReplicatedStorage:GetAttribute("IllustratedWidth") or 1366
	local h=game.ReplicatedStorage:GetAttribute("IllustratedHeight") or 704
	mounted.view.root.Size=UDim2.fromOffset(w :: number,h :: number)
	task.defer(function()
		for _=1,4 do game:GetService("RunService").RenderStepped:Wait() end
		mounted.mapController.recenter()
		local zoom=game.ReplicatedStorage:GetAttribute("IllustratedZoom")
		if type(zoom)=="number" then mounted.mapController.changeZoom(zoom-(mounted.view.map.root:GetAttribute("CameraZoom") :: number)) end
		local x,y=game.ReplicatedStorage:GetAttribute("IllustratedLocateX"),game.ReplicatedStorage:GetAttribute("IllustratedLocateY")
		if type(x)=="number" and type(y)=="number" then mounted.mapController.locate(x,y) end
		proof.setEnabled(string.find(which :: string,"Illustrated",1,true)~=nil)
		if string.find(which :: string,"Organic",1,true) then proof.setLandscapeMode("Organic")
  elseif string.find(which :: string,"Ocean",1,true) then proof.setLandscapeMode("Ocean")
		elseif string.find(which :: string,"Ground",1,true) then proof.setLandscapeMode("Ground") end
		local selected=game.ReplicatedStorage:GetAttribute("IllustratedSelected")
		if type(selected)=="number" then mounted.selectAsset(fixture.nodes[selected].id) end
		print("[Illustrated capture]",which,w,h,"seed",fixture.world.seed)
	end)
end
game.ReplicatedStorage:GetAttributeChangedSignal("IllustratedCapture"):Connect(capture)
capture()
