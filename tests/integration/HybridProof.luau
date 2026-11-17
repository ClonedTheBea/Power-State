--!strict
-- Require manually from the test mapping. Never loaded by production Bootstrap.
local Client = script.Parent.Parent.Client
local App = require(Client.Controllers.AppController)
local Renderer = require(Client.Views.Map.SpriteTerrainRenderer)
local Loader = require(Client.Views.Map.SpriteAtlasLoader)
local Proof = {}
function Proof.mount(playerGui: PlayerGui, scenario: string?, cohesion: boolean?)
	local mode = scenario or "real"
	local Atlas = require(script.Parent.RealAtlas)
	if mode == "real" then Atlas.assertEnvironment() end
	assert(mode=="real" or mode=="unconfigured" or mode=="ready" or mode=="delayed" or mode=="timeout" or mode=="denied", "Unknown proof scenario")
	local existing = playerGui:FindFirstChild("PowerStateShell")
	assert(not existing, "Destroy the current test shell before mounting the comparison")
	local app = App.mount(playerGui)
	local request: Loader.Request? = nil
	if mode ~= "unconfigured" and mode ~= "real" then
		request = function(done: (boolean) -> ())
			local cancelled = false
			task.delay(if mode == "delayed" then 2 elseif mode == "timeout" then 7 else 0,function()
				if not cancelled then done(mode ~= "denied") end
			end)
			return function() cancelled = true end
		end
	end
	local proof = Renderer.attach(app.view.map.root,app.view.map.terrain,request,nil,nil,
		if mode == "real" then {uri=Atlas.URI,request=Atlas.request} else nil)
	local presentation = if cohesion ~= false then require(script.Parent.HybridPresentation).attach(app.view.map) else nil
	-- Attributes form a Studio-only comparison control without covering mobile navigation.
	app.view.map.root:SetAttribute("ProofNotice",if mode == "real" then "REAL approved atlas / illustrative data" else "SYNTHETIC bounds only")
	app.view.map.root:SetAttribute("RequestedProofMode","Native")
	local connection=app.view.map.root:GetAttributeChangedSignal("RequestedProofMode"):Connect(function()
		local value=app.view.map.root:GetAttribute("RequestedProofMode")
		if value=="Native" or value=="Hybrid" then proof.setMode(value) end
	end)
	print("[Hybrid proof "..mode.."] Set CountryMap.RequestedProofMode to Native or Hybrid in client Explorer.")
	local destroyed=false
	local function destroy()
		if destroyed then return end
		destroyed=true;connection:Disconnect();if presentation then presentation.destroy() end;proof.destroy();app.destroy()
	end
	app.view.gui.Destroying:Once(function() connection:Disconnect() end)
	return {app=app,proof=proof,destroy=destroy}
end
return Proof
