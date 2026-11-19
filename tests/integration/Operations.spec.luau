--!strict
return function()
	local Client = script.Parent.Parent.Client.Simulation
	local First = require(Client.ConstructionClient); local Operations = require(Client.OperationsClient)
	local R = game:GetService("RunService"); local count = 0
	local function check(v: boolean, message: string) assert(v, message); count += 1 end
	local function waitFor(predicate: () -> boolean, seconds: number, label: string)
		local start = os.clock()
		repeat if predicate() then return end; R.Heartbeat:Wait() until os.clock() - start >= seconds
		error("Timed out: " .. label)
	end
	waitFor(function() return First.active() ~= nil end, 60, "normal First Playable entry")
	local first = First.active()
	first.app.actions[first.app.view.navigation.buttons.Infrastructure](); first.app.actions[first.directory.training]()
	waitFor(function() return Operations.active() ~= nil and Operations.active().app ~= nil end, 15, "normal Training entry")
	local training = Operations.active(); local app = training.app; local ui = training.ui
	check(not first.app.view.gui.Parent, "Only one live GUI/controller")
	check(app.state.route == "Infrastructure", "Normal entry opens control room")
	waitFor(function() return training.current().step >= 2 end, 8, "authoritative progression")
	local initial = training.current()
	check(initial.bankMinor ~= 100000 and initial.generatedKW == initial.deliveredKW, "Genuine delivered electricity earns Credits")
	for _, info in {{"wind", "Weather changes"}, {"peak", "standby cost"}} do
		app.actions[ui.fleet[info[1]].details]()
		local text=""
		for _, item in app.view.feedback.root:GetDescendants() do if item:IsA("TextLabel") then text..=item.Text end end
		check(string.find(text,info[2],1,true)~=nil,"Generator explanation remains accessible in details")
		app.back()
	end
	for _, button in {app.view.kpis.buttons[1], app.view.kpis.buttons[4], app.view.header.overview, app.view.drawer.buttons.Overview} do
		local before = training.current()
		app.actions[button]()
		local text = ""
		for _, item in app.view.feedback.root:GetDescendants() do if item:IsA("TextLabel") then text ..= item.Text end end
		check(string.find(text, string.format("%.2f Credits", before.bankMinor / 100), 1, true) ~= nil, "Actual Bank overview, not preview")
		check(string.find(text, "Live server values", 1, true) ~= nil and string.find(text, "illustrative", 1, true) == nil, "Honest overview time and authority")
		app.back()
	end
	local descendants = #app.view.map.root:GetDescendants()
	check(descendants <= 600, "600 map descendant bound")
	for _, size in {Vector2.new(1366, 704), Vector2.new(1024, 720), Vector2.new(390, 780), Vector2.new(844, 390)} do
		print(string.format("[Operations V13 resize] %dx%d",size.X,size.Y))
		app.view.root.Size = UDim2.fromOffset(size.X, size.Y); app.refresh()
		R.RenderStepped:Wait(); R.RenderStepped:Wait()
		for _, row in ui.fleet do
			check(row.text.TextBounds.Y <= row.text.AbsoluteSize.Y + 1, "Fleet text remains readable without clipping")
			for _, button in {row.toggle, row.minus, row.plus, row.locate} do
				check(button.AbsoluteSize.X >= 44 and button.AbsoluteSize.Y >= 44, "Responsive 44px control")
				check(button.AbsolutePosition.X >= app.view.root.AbsolutePosition.X and button.AbsolutePosition.X + button.AbsoluteSize.X <= app.view.root.AbsolutePosition.X + size.X + 1, "Control remains horizontally reachable")
			end
		end
	end
	app.view.root.Size = UDim2.fromScale(1, 1); app.refresh()
	local function source(id: string): any for _, v in training.current().fleet do if v.id == id then return v end end; return nil end
	local function operate(button: TextButton, predicate: () -> boolean)
		waitFor(function() return not training.current().saving and training.current().status ~= "Pending" end, 5, "command window")
		local sent=os.clock();app.actions[button]()
		waitFor(predicate, 4, "authoritative control acknowledgement")
		print(string.format("[Operations V13 acknowledgement] %s %.3f ms",button.Name,(os.clock()-sent)*1000))
	end
	operate(ui.fleet.gas.minus, function() return source("gas").capKW == 4900 end)
	operate(ui.fleet.gas.plus, function() return source("gas").capKW == 5000 end)
	operate(ui.fleet.wind.toggle, function() return not source("wind").on end)
	operate(ui.fleet.wind.toggle, function() return source("wind").on end)
	check(training.current().step >= initial.step, "Controls preserve simulation progression")
	app.actions[ui.fleet.gas.locate]()
	check(app.state.selectedId == "gas" and app.state.route == "Map", "Fleet Locate/select")
	app.mapController.pan(10, 10); app.mapController.changeZoom(.15); app.mapController.recenter()
	app.navigate("Infrastructure")
	local minute = training.current().step
	waitFor(function() return training.current().step >= minute + 2 end, 6, "ordinary menu keeps simulation running")
	check(#app.view.map.root:GetDescendants() == descendants, "Pan/zoom/resize does not grow map instances")
	check(#training.current().alerts <= 8 and #training.current().forecast.samples == 5, "Bounded alerts and forecast")
	local gui = game:GetService("GuiService")
	app.keyboard.focus(ui.fleet.gas.toggle)
	waitFor(function() return gui.SelectedObject == ui.fleet.gas.toggle end, 2, "fleet keyboard focus")
	check(app.keyboard.valid(ui.fleet.gas.toggle), "Fleet focus is eligible")
	waitFor(function() return not training.current().saving and training.current().status ~= "Pending" end, 5, "keyboard command window")
	app.keyboard.activate()
	waitFor(function() return not source("gas").on end, 4, "keyboard Off confirmation")
	waitFor(function() return not training.current().saving and training.current().status ~= "Pending" end, 5, "keyboard On window")
	app.keyboard.activate()
	waitFor(function() return source("gas").on end, 4, "keyboard On confirmation")
	check(gui.SelectedObject == ui.fleet.gas.toggle, "Acknowledgements preserve focused control")
	local camera = app.view.map.root:GetAttribute("CameraX")
	app.actions[app.view.header.buttons.Help]()
	waitFor(function() return gui.SelectedObject == app.view.feedback.close end, 2, "help modal focus")
	app.back()
	check(app.view.map.root:GetAttribute("CameraX") == camera, "Help preserves map camera")
 app.actions[app.view.header.buttons.Alerts]()
 local alertText=""
 for _,item in app.view.feedback.root:GetDescendants()do if item:IsA("TextLabel")then alertText..=item.Text end end
 check(string.find(alertText,"Last command:",1,true)~=nil,"Bounded authoritative alert details accessible")
 app.back()

	print("[Operations GUI] PASS: " .. count .. " assertions; map descendants=" .. descendants)
end
