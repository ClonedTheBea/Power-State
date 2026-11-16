--!strict
return function(playerGui: PlayerGui)
	local Client = script.Parent.Parent.Client
	local App = require(Client.Controllers.AppController)
	local Geometry = require(Client.Views.Map.MapGeometry)
	local Terrain = require(Client.Views.Map.TerrainRenderer)
	local MapView = require(Client.Views.MapView)
	local Preview = require(Client.PreviewData)
	local RunService = game:GetService("RunService")
	local count = 0
	local function check(value: boolean, reason: string) assert(value, reason); count += 1 end
	local function settle() for _ = 1, 4 do RunService.RenderStepped:Wait() end end
	local existing = playerGui:FindFirstChild("PowerStateShell")
	if existing then existing:Destroy() end
	local cold = os.clock()
	local app = App.mount(playerGui)
	local coldMs = (os.clock() - cold) * 1000
	local ok, problem = xpcall(function()
		check(Geometry.segmentVisible(-30, 50, 400, 50, 300, 200), "Crossing line retained with both endpoints culled")
		check(not Geometry.segmentVisible(-80, -30, -20, -10, 300, 200), "Offscreen line culled")
		check(Geometry.band("overview", 0.72) == "overview" and Geometry.band("regional", 0.72) == "regional", "Zoom hysteresis")
		check(Geometry.band("detail", 1.2) == "detail" and Geometry.band("regional", 1.2) == "regional", "Detail hysteresis")
		local host = Instance.new("Frame")
		local fallback = Terrain.create(host, { { id = "missing", kind = "missing", x = 0, y = 0, width = 100, height = 100 } })
		check(fallback.entries[1].root:GetAttribute("Fallback") == true, "Unknown artwork gives labelled native fallback")
		local oversized = {}
		for i = 1, 25 do table.insert(oversized, { id = tostring(i), kind = "land", x = 0, y = 0, width = 10, height = 10 }) end
		check(not pcall(function() Terrain.create(host, oversized) end), "Patch budget rejected before allocation")
		local overlap = MapView.create(host, { metrics = {}, nodes = {
			{ id = "a", name = "A", kind = "Unknown", x = 100, y = 100, description = "" },
			{ id = "b", name = "B", kind = "Settlement", x = 101, y = 101, description = "" },
		}, links = {} })
		overlap.render(0, 0, 1)
		check(overlap.markers.a:GetAttribute("Fallback") == true, "Missing marker art has question-mark target")
		check(overlap.markers.b:GetAttribute("UseAssetPicker") == true and not overlap.markers.b.Visible, "Overlapping target routed to Assets picker")
		check(overlap.markers.a:GetAttribute("Cluster") == true, "Overlap representative is explicitly a cluster")
		host:Destroy()
		app.view.map.markers.station:SetAttribute("Cluster", true)
		app.actions[app.view.map.markers.station]()
		check(app.view.drawer.root.Visible and app.view.drawer.root:GetAttribute("Mode") == "Assets", "Cluster activation opens the accessible picker")
		app.back(); settle()
		local baseline = #app.view.gui:GetDescendants()
		local mapCount = #app.view.map.root:GetDescendants()
		check(mapCount <= 600, "Total map descendant budget, including decorative instances")
		for _, size in { { 360, 580 }, { 640, 300 }, { 768, 960 }, { 1366, 704 } } do
			app.view.root.Size = UDim2.fromOffset(size[1], size[2]); settle()
			app.mapController.recenter()
			app.selectAsset("junction"); app.actions[app.view.inspector.close](); settle()
			for _, zoomDelta in { -10, 0.3, 10 } do
				app.mapController.changeZoom(zoomDelta); app.mapController.pan(-60, 25)
				local map = app.view.map
				local x, y, z = map.root:GetAttribute("CameraX") :: number, map.root:GetAttribute("CameraY") :: number, map.root:GetAttribute("CameraZoom") :: number
				for _, node in Preview.nodes do
					local marker = map.markers[node.id]
					check(math.abs(marker.Position.X.Offset - (x + node.x * z)) < 1.01 and math.abs(marker.Position.Y.Offset - (y + node.y * z)) < 1.01, "Stable world-to-screen asset coordinates")
					check(marker.Size.X.Offset >= 44 and marker.Size.Y.Offset >= 44, "Screen-space hit target survives zoom")
				end
				check(map.terrain.root:GetAttribute("VisiblePatches") :: number <= 24, "Bounded rendered patches")
				check(#app.view.gui:GetDescendants() == baseline, "No instance growth on zoom/pan")
			end
			local x, y, z = app.view.map.root:GetAttribute("CameraX"), app.view.map.root:GetAttribute("CameraY"), app.view.map.root:GetAttribute("CameraZoom")
			app.actions[app.view.layers](); settle()
			check(app.view.drawer.root.Visible and app.view.blocker.Visible, "Layer drawer blocks map input")
			app.actions[app.view.drawer.buttons.Labels](); app.actions[app.view.drawer.buttons.Links]()
			check(app.view.map.root:GetAttribute("LabelsVisible") == false and app.view.map.root:GetAttribute("LinksVisible") == false, "Optional overlays toggle")
			check(app.state.selectedId == "junction", "Layer changes retain selected asset")
			check(app.view.map.root:GetAttribute("CameraX") == x and app.view.map.root:GetAttribute("CameraY") == y and app.view.map.root:GetAttribute("CameraZoom") == z, "Layer changes preserve camera")
			app.actions[app.view.drawer.buttons.Labels](); app.actions[app.view.drawer.buttons.Links]()
			app.actions[app.view.drawer.buttons["Layer_Power flow"]](); settle()
			check(app.view.feedback.root.Visible and not app.view.drawer.root.Visible, "Unavailable analysis explains its future dependency")
			check(app.view.map.root:GetAttribute("PrimaryLayer") == "Geography", "Unavailable analytical layer cannot replace Geography")
			app.back(); settle()
			app.selectAsset("station"); settle(); app.actions[app.view.inspector.locate](); settle()
			check(app.view.map.markers.station.Visible and app.state.selectedId == "station", "Locate reveals selected asset")
			check(app.view.map.root:GetAttribute("CameraZoom") == z, "Locate keeps zoom")
		end
		app.view.map.render(-5000, -5000, 1)
		app.view.root.Size = UDim2.fromOffset(360, 580); settle()
		app.selectAsset("junction"); settle()
		app.view.root.Size = UDim2.fromOffset(640, 300); settle()
		check(game:GetService("GuiService").SelectedObject == app.view.inspector.close, "Rotation rebinds focus to the visible inspector close control")
		app.actions[app.view.inspector.close](); settle()
		app.view.map.render(-5000, -5000, 1)
		check(app.view.map.terrain.root:GetAttribute("VisiblePatches") == 0, "Offscreen terrain actually culled")
		local samples: { number } = {}
		for i = 1, 360 do
			local started = os.clock()
			app.view.map.render(-i % 350, -i % 150, 0.55 + (i % 125) / 100)
			table.insert(samples, (os.clock() - started) * 1000)
			if i % 30 == 0 then RunService.RenderStepped:Wait() end
		end
		table.sort(samples)
		check(#app.view.gui:GetDescendants() == baseline, "Warm render reuse has no instance growth")
		print(string.format("[Power State R3 profile] cold mount %.2f ms; warm map draw p50 %.3f / p95 %.3f ms; map %d / shell %d descendants", coldMs, samples[180], samples[342], mapCount, baseline))
		for _, size in { { 360, 580 }, { 1366, 704 } } do
			app.view.root.Size = UDim2.fromOffset(size[1], size[2]); settle()
			local frames: { number } = {}
			for i = 1, 120 do
				app.mapController.pan(if i % 2 == 0 then 15 else -15, 0)
				app.mapController.changeZoom(if i % 2 == 0 then 0.03 else -0.03)
				table.insert(frames, RunService.RenderStepped:Wait() * 1000)
			end
			table.sort(frames)
			print(string.format("[Power State R3 frames] %dx%d safe root: p50 %.2f / p95 %.2f ms (Studio desktop, not mobile hardware)", size[1], size[2], frames[60], frames[114]))
		end
	end, function(message: unknown): string return debug.traceback(tostring(message)) end)
	app.destroy(); App.mount(playerGui)
	assert(ok, tostring(problem))
	print(string.format("[Power State R3] PASS: %d rendering/interaction assertions", count))
	return count
end
