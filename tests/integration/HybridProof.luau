--!strict
-- Require manually from the test mapping. Never loaded by production Bootstrap.
local Client = script.Parent.Parent.Client
local App = require(Client.Controllers.AppController)
local Renderer = require(Client.Views.Map.SpriteTerrainRenderer)
local Loader = require(Client.Views.Map.SpriteAtlasLoader)
local Proof = {}
function Proof.mount(playerGui: PlayerGui, scenario: string?)
	local existing = playerGui:FindFirstChild("PowerStateShell")
	assert(not existing, "Destroy the current test shell before mounting the comparison")
	local app = App.mount(playerGui)
	local mode = scenario or "unconfigured"
	assert(mode=="unconfigured" or mode=="ready" or mode=="delayed" or mode=="timeout" or mode=="denied", "Unknown mock scenario")
	local request: Loader.Request? = nil
	if mode ~= "unconfigured" then
		request = function(done: (boolean) -> ())
			local cancelled = false
			task.delay(if mode == "delayed" then 2 elseif mode == "timeout" then 7 else 0,function()
				if not cancelled then done(mode ~= "denied") end
			end)
			return function() cancelled = true end
		end
	end
	local proof = Renderer.attach(app.view.map.root,app.view.map.terrain,request)
	-- Attributes form a Studio-only comparison control without covering mobile navigation.
	app.view.map.root:SetAttribute("ProofNotice","SYNTHETIC bounds only / no atlas uploaded")
	app.view.map.root:SetAttribute("RequestedProofMode","Native")
	local connection=app.view.map.root:GetAttributeChangedSignal("RequestedProofMode"):Connect(function()
		local value=app.view.map.root:GetAttribute("RequestedProofMode")
		if value=="Native" or value=="Hybrid" then proof.setMode(value) end
	end)
	print("[R3.3 SYNTHETIC] Set CountryMap.RequestedProofMode to Native or Hybrid in client Explorer. No actual atlas.")
	local destroyed=false
	local function destroy()
		if destroyed then return end
		destroyed=true;connection:Disconnect();proof.destroy();app.destroy()
	end
	app.view.gui.Destroying:Once(function() connection:Disconnect() end)
	return {app=app,proof=proof,destroy=destroy}
end
return Proof
