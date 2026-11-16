--!strict
return function(playerGui: PlayerGui)
	local Client = script.Parent.Parent.Client
	local App = require(Client.Controllers.AppController)
	local Transform = require(game:GetService("ReplicatedStorage").Shared.Util.MapTransform)
	local Fixture = require(Client.Views.Map.MapFixture)
	local RunService = game:GetService("RunService")
	local count = 0
	local function check(value: boolean, reason: string) assert(value, reason); count += 1 end
	local function settle() for _ = 1, 5 do RunService.RenderStepped:Wait() end end
	local existing = playerGui:FindFirstChild("PowerStateShell")
	if existing then existing:Destroy() end
	local app = App.mount(playerGui)
	local ok, problem = xpcall(function()
		settle()
		local map = app.view.map
		local size = map.viewport.AbsoluteSize
		check(math.abs((map.root:GetAttribute("CameraZoom") :: number) - Transform.homeZoom(size.X, size.Y)) < 0.001,
			"First settled frame uses final viewport, not constructor geometry")
		check(Transform.homeZoom(1800, 1100) > 1, "Large desktop no longer capped at 1x")
		check(Transform.homeZoom(20, 20) == Transform.MIN_ZOOM, "Tiny safe area retains minimum zoom and pan access")
		check(Transform.homeZoom(9000, 9000) == Transform.MAX_ZOOM, "Default framing respects maximum zoom")
		local ids: { [string]: boolean } = {}
		for _, patch in Fixture do
			check(not ids[patch.id], "Cosmetic patch identities remain unique")
			ids[patch.id] = true
		end
		local terrain = map.terrain.root
		check(terrain:FindFirstChild("ExhaustStack", true) ~= nil, "Power-station silhouette present")
		check(terrain:FindFirstChild("Clock", true) ~= nil and terrain:FindFirstChild("CoastalPier", true) ~= nil,
			"Capital and coastal settlement have distinct landmarks")
		local baseline = #app.view.gui:GetDescendants()
		check(#map.root:GetDescendants() <= 600, "Refinement retains 600-descendant ceiling")
		for _, dimensions in { {360,580}, {640,300}, {768,960}, {1366,704}, {1920,1020} } do
			app.view.root.Size = UDim2.fromOffset(dimensions[1], dimensions[2]); settle()
			app.mapController.recenter()
			size = map.viewport.AbsoluteSize
			local zoom = map.root:GetAttribute("CameraZoom") :: number
			check(math.abs(zoom - Transform.homeZoom(size.X, size.Y)) < 0.001, "Recenter uses country framing")
			local previous = math.clamp(math.min(size.X / 950, size.Y / 650), 0.55, 1)
			-- Narrow portrait is width-limited; the expanded coast needs slightly more room.
			if size.X > size.Y * 1.65 then check(zoom >= previous, "Wide viewport country framing is no smaller than R3") end
			app.selectAsset("station"); settle(); app.actions[app.view.inspector.locate](); settle()
			check(map.markers.station.Visible and app.state.selectedId == "station", "Refined art leaves Locate and selection reachable")
			check(map.root:GetAttribute("CameraZoom") == zoom, "Locate keeps refined camera zoom")
			check(#app.view.gui:GetDescendants() == baseline, "Resize and inspector do not allocate art")
		end
	end, function(message: unknown): string return debug.traceback(tostring(message)) end)
	app.destroy(); App.mount(playerGui)
	assert(ok, tostring(problem))
	print(string.format("[Power State R3.1] PASS: %d framing/refinement assertions", count))
	return count
end
