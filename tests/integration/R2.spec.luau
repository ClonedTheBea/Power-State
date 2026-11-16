--!strict
-- Exercises production controller transitions and lifecycle, not copied state formulas.
return function(playerGui: PlayerGui)
	local player = game:GetService("Players").LocalPlayer
	assert(player)
	local App = require(script.Parent.Parent.Client.Controllers.AppController)
	local existing = playerGui:FindFirstChild("PowerStateShell")
	if existing then existing:Destroy() end
	local app = App.mount(playerGui)
	local count = 0
	local function check(condition: boolean, message: string) assert(condition, message); count += 1 end
	local function settle() for _ = 1, 5 do game:GetService("RunService").RenderStepped:Wait() end end
	local ok, problem = xpcall(function()
		check(playerGui.ScreenOrientation == Enum.ScreenOrientation.Sensor, "Shell permits portrait and landscape rotation")
		for _, size in { { 360, 580 }, { 640, 300 }, { 768, 960 }, { 1366, 704 }, { 1600, 840 } } do
			app.view.root.Size = UDim2.fromOffset(size[1], size[2]); settle()
			app.selectAsset("station"); settle()
			app.mapController.recenter(); app.mapController.changeZoom(2); app.mapController.pan(-70, -30)
			local zoom = app.view.map.root:GetAttribute("CameraZoom")
			local function centre(): Vector2
				local map = app.view.map.root
				return (map.AbsoluteSize / 2 - Vector2.new(map:GetAttribute("CameraX") :: number, map:GetAttribute("CameraY") :: number)) / (zoom :: number)
			end
			local before = centre()
			app.actions[app.view.inspector.close](); settle()
			check(app.state.selectedId == "station" and not app.view.inspector.root.Visible, "Close preserves selection")
			check(app.view.map.root:GetAttribute("CameraZoom") == zoom, "Close preserves zoom")
			check((centre() - before).Magnitude < 1, "Close preserves world centre, including dock resize")
			app.actions[app.view.details](); settle()
			check(app.view.inspector.title.Text == "Westhaven Station", "Reopen restores asset context")
			check(app.view.map.root:GetAttribute("CameraZoom") == zoom, "Reopen does not recenter")
			check((centre() - before).Magnitude < 1, "Reopen preserves panned world centre")
			app.actions[app.view.inspector.expand](); settle()
			check(app.state.inspectorStage == "expanded", "Expand inspector")
			app.actions[app.view.inspector.expand](); settle()
			check(app.state.inspectorStage == "peek", "Peek inspector")
			app.actions[app.view.inspector.expand](); settle()
			check(app.state.inspectorStage == "half", "Return half inspector")
			app.navigate("Government"); app.navigate("Map"); settle()
			check(app.state.selectedId == "station", "Routes preserve selection")
			check(app.view.map.root:GetAttribute("CameraZoom") == zoom, "Routes preserve camera zoom")
			app.actions[app.view.header.overview](); settle()
			check(app.view.feedback.root.Visible and app.view.blocker.Visible, "Overview blocks background input")
			for _ = 1, 4 do app.keyboard.step(1) end
			check(game:GetService("GuiService").SelectedObject == app.view.feedback.close, "Feedback traps focus")
			app.keyboard.activate(); settle()
			check(not app.view.feedback.root.Visible, "Keyboard activates close once")
			check(game:GetService("GuiService").SelectedObject == app.view.header.overview, "Close restores invoker")
			app.actions[app.view.assetList](); settle()
			for _ = 1, 8 do
				app.keyboard.step(1)
				local selected = game:GetService("GuiService").SelectedObject
				check(selected ~= nil and selected:IsDescendantOf(app.view.drawer.root), "Drawer focus stays in visible list")
			end
			app.actions[app.view.drawer.buttons.Asset_east](); settle()
			check(app.state.selectedId == "east" and not app.view.drawer.root.Visible, "Accessible asset-list selection")
			app.actions[app.view.inspector.close](); settle()
			check(not app.view.blocker.Visible, "Nonmodal inspector does not block map")
		end
		app.view.root.Size = UDim2.fromOffset(360, 580); app.selectAsset("capital"); settle()
		local zoom = app.view.map.root:GetAttribute("CameraZoom")
		app.view.root.Size = UDim2.fromOffset(640, 300); settle()
		check(app.state.selectedId == "capital" and app.view.inspector.root.Visible, "Open-sheet rotation keeps selection")
		check(app.view.map.root:GetAttribute("CameraZoom") == zoom, "Rotation retains zoom")
		check(not app.keyboard.valid(app.view.details), "Full landscape sheet excludes covered map controls from focus")
		app.navigate("Build"); settle()
		check(app.view.map.root.Visible and app.view.feedback.root.Visible, "Build remains an honest preview over the same map")
		check(app.view.map.root:GetAttribute("CameraZoom") == zoom, "Build preserves camera")
		app.back()
		app.actions[app.view.mapFocus](); check(app.state.mapFocus, "Explicit map focus")
		app.back(); check(not app.state.mapFocus, "Back returns UI focus")
	end, function(message: unknown): string return debug.traceback(tostring(message)) end)
	app.destroy()
	local restored = App.mount(playerGui)
	settle()
	local shells = 0
	for _, item in playerGui:GetChildren() do if item.Name == "PowerStateShell" then shells += 1 end end
	check(shells == 1, "Single shell after remount")
	check(restored.view.root.Parent ~= nil, "Remount remains usable")
	assert(ok, tostring(problem))
	print(string.format("[Power State R2 Interaction] PASS: %d assertions", count))
	return count
end
