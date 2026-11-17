--!strict
local App=require(script.Parent.Parent.Client.Controllers.AppController)
local Renderer=require(script.Parent.SettlementRenderer)
local Presentation=require(script.Parent.HybridPresentation)
local Proof={}
function Proof.mount(playerGui:PlayerGui)
	assert(game:GetService("RunService"):IsStudio() and game:GetService("RunService"):IsClient() and game.GameId==10776833313,"Test client only")
	assert(not playerGui:FindFirstChild("PowerStateShell"),"Destroy prior shell first")
	local app=App.mount(playerGui)
	local proof=Renderer.attach(app.view.map.root,app.view.map.terrain)
	local presentation=Presentation.attach(app.view.map)
	local root=app.view.map.root
	root:SetAttribute("ProofNotice","REAL two-atlas Test comparison / illustrative data")
	root:SetAttribute("RequestedProofMode","Native");root:SetAttribute("RequestedProofProfile","Original")
	local mode=root:GetAttributeChangedSignal("RequestedProofMode"):Connect(function()
		local value=root:GetAttribute("RequestedProofMode")
		if value=="Native" or value=="Hybrid" then proof.setMode(value) end
	end)
	local profile=root:GetAttributeChangedSignal("RequestedProofProfile"):Connect(function()
		local value=root:GetAttribute("RequestedProofProfile")
		if value=="Original" or value=="Settlements" then proof.setProfile(value) end
	end)
	local destroyed=false
	local function destroy()
		if destroyed then return end
		destroyed=true;mode:Disconnect();profile:Disconnect();presentation.destroy();proof.destroy();app.destroy()
	end
	app.view.gui.Destroying:Once(function() mode:Disconnect();profile:Disconnect() end)
	return {app=app,proof=proof,destroy=destroy}
end
return table.freeze(Proof)
