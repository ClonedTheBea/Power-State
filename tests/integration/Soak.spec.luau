--!strict
-- Ten-minute Studio smoke test, not a low-end hardware performance guarantee.
return function(playerGui: PlayerGui)
	local App = require(script.Parent.Parent.Client.Controllers.AppController)
	local existing = playerGui:FindFirstChild("PowerStateShell")
	if existing then existing:Destroy() end
	local app = App.mount(playerGui)
	local sizes = { { 360, 580 }, { 640, 300 }, { 768, 960 }, { 1024, 708 }, { 1366, 704 }, { 1920, 1020 } }
	local baseline = #app.view.gui:GetDescendants()
	local started = os.clock()
	local cycles = 0
	local ok, problem = xpcall(function()
		while os.clock() - started < 600 do
			cycles += 1
			local size = sizes[(cycles - 1) % #sizes + 1]
			app.view.root.Size = UDim2.fromOffset(size[1], size[2])
			app.selectAsset(if cycles % 2 == 0 then "station" else "capital")
			app.mapController.changeZoom(if cycles % 2 == 0 then 0.15 else -0.15)
			app.mapController.pan(if cycles % 2 == 0 then 60 else -60, 20)
			app.actions[app.view.inspector.close]()
			task.wait(1)
			assert(#app.view.gui:GetDescendants() == baseline, "GUI instance count grew during resize/pan")
			assert(app.state.selectedId ~= nil, "Selection lost during smoke test")
			local zoom = app.view.map.root:GetAttribute("CameraZoom") :: number
			assert(zoom >= 0.55 and zoom <= 1.8, "Camera escaped zoom bounds")
			if cycles % 60 == 0 then print("[Power State R2 Soak] " .. cycles .. " resize/pan cycles; instance count stable") end
		end
	end, function(message: unknown): string return debug.traceback(tostring(message)) end)
	app.destroy()
	App.mount(playerGui)
	assert(ok, tostring(problem))
	print(string.format("[Power State R2 Soak] PASS: %.1f seconds, %d cycles, %d GUI descendants stable", os.clock() - started, cycles, baseline))
end
