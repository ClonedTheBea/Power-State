--!strict
local App = require(script.Parent.Parent.Controllers.AppController)
local View = require(script.Parent.OperationsView)
local Presentation = require(script.Parent.OperationsPresentation)
local Details = require(script.Parent.OperationsDetails)
local Reinforcement = require(script.Parent.ReinforcementView)
local Client = {}
local mounted: any = nil
local released: any = nil
local positions = {gas = {250, 400}, wind = {300, 160}, peak = {220, 680}, sub = {500, 400}, a = {740, 240}, b = {740, 670}}
local names = {gas = "Central Gas", wind = "Coastal Wind", peak = "Reserve Peaker", sub = "National Substation", a = "North Customers", b = "East Customers"}
function Client.active(): any return mounted end
function Client.lastRelease(): any return released end
function Client.attachEntry(first: any, playerGui: PlayerGui, reopen: () -> ())
 local button=first.directory.training
 first.app.bind(button,function()
  if mounted then return end
  mounted={loading=true}
  task.spawn(function()
   local ok,problem=pcall(Client.mount,first,playerGui,reopen)
   if not ok then mounted=nil;warn("[Operations GUI] "..tostring(problem))
    if first.app.view.gui.Parent then first.app.showFeedback("Training unavailable","Could not enter training. No profile was reset.",button)end
   end
  end)
 end)
 first.app.view.navigation.buttons.Infrastructure:SetAttribute("LabelOverride","Infrastructure")
 first.app.view.navigation.buttons.Infrastructure:SetAttribute("ShortLabelOverride","Assets")
 first.app.view.navigation.buttons.Infrastructure:SetAttribute("AccessibleLabel","Infrastructure asset directory")

	first.app.refresh()
end
function Client.mount(first: any, playerGui: PlayerGui, reopen: () -> ()): any
	assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Training Test only")
	local folder = game.ReplicatedStorage:WaitForChild("OperationsTraining", 10); assert(folder, "Training host unavailable")
	local intent = folder:WaitForChild("Intent") :: RemoteEvent
	local remote = folder:WaitForChild("Snapshot") :: RemoteEvent
	local current: any = nil; local app: any = nil; local ui: any = nil
	local entered: any = nil
	local received = 0; local pending = false; local destroyed = false; local leaving = false; local errorReason: string? = nil
	local connection = remote.OnClientEvent:Connect(function(value: any)
		if destroyed or type(value) ~= "table" or value.version ~= 1 then return end
		if value.mode == "Unavailable" then errorReason = tostring(value.reason); return end
		if value.mode == "FirstPlayable" and leaving then
			released = value.last
			destroyed = true; mounted = nil
			if app then app.destroy() end
			task.defer(reopen); return
		end
		if value.mode ~= "Operations" or type(value.fleet) ~= "table" or #value.fleet ~= 3 then return end
		if current and (value.epoch ~= current.epoch or value.revision < current.revision) then return end
		current = value; entered = entered or value; received = os.clock(); pending = false
		if value.saveBlocked then leaving = false end
		if app then app.present() end
	end)
	intent:FireServer({version = 1, kind = "Enter"})
	local began = os.clock()
	while not current and not errorReason and os.clock() - began < 10 do task.wait(.05) end
	if not current then connection:Disconnect(); intent:FireServer({version = 1, kind = "Exit"}); error(errorReason or "Training entry timed out") end
	-- Cosmetic terrain is reused from the existing Native country descriptor; it never determines electricity.
	local world = first.current().world
	local preview: any = {world = world, nodes = {}, links = {}, metrics = {
		{label = "BANK · LIVE", value = "Loading", detail = "Training Credits"},
		{label = "DELIVERY / DEMAND", value = "Loading", detail = "Completed electricity interval"},
		{label = "UNSERVED", value = "Loading", detail = "Demand not delivered"},
		{label = "HEADROOM", value = "Loading", detail = "Dispatchable, not guaranteed deliverable reserve"},
	}}
	for _, id in {"gas", "wind", "peak", "sub", "a", "b"} do
		table.insert(preview.nodes, {id = id, name = names[id], kind = if id == "sub" then "Substation" elseif id == "a" or id == "b" then "Settlement" else "Generator",
			x = positions[id][1], y = positions[id][2], description = "Operations training infrastructure · server-authoritative electricity"})
	end
	for _, pair in {{"gas", "sub"}, {"wind", "sub"}, {"peak", "sub"}, {"sub", "a"}, {"sub", "b"}} do table.insert(preview.links, {from = pair[1], to = pair[2]}) end
	first.destroy()
	app = App.mount(playerGui, preview); ui = View.create(app)
	local details = Details.create(app, function() return current end, function() return os.clock()-received end)
	local function overview(button: GuiButton) details.open("Bank", button) end
	for _, button in app.view.kpis.buttons do app.actions[button] = function() overview(button) end end
	app.actions[app.view.header.overview] = function() overview(app.view.header.overview) end
	app.view.drawer.buttons.Overview.Text = "Bank / overview"
	app.actions[app.view.drawer.buttons.Overview] = function() overview(app.view.drawer.buttons.Overview) end
	local function send(kind: string, source: any?, on: boolean?, cap: number?)
		if pending or leaving or os.clock() - received >= 3 then return end
		if current.saving then return end
		if kind == "Control" then if current.saveBlocked then return end end
		local payload: any = {version = 1, kind = kind, epoch = current.epoch, revision = current.revision, sequence = current.nextSequence}
		if kind == "Control" then payload.sourceId = source; payload.on = on; payload.capKW = cap end
		if kind == "ConfirmReinforcement" then payload.quoteId = current.investment.quoteId end
		pending = true; intent:FireServer(payload); app.present()
	end
	local investment = Reinforcement.create(app, ui, function() return current end, function() return os.clock()-received end, function(kind) send(kind) end)
	investment.review.LayoutOrder = 9 -- Fleet controls precede the secondary investment action.
	app.view.navigation.buttons.Build:SetAttribute("LabelOverride","Build")
	app.view.drawer.buttons.Build.Text="Build"
	local function find(id: string): any for _, source in current.fleet do if source.id == id then return source end end; return nil end
	app.bind(ui.bank, function() details.open("Bank", ui.bank) end)
	app.bind(ui.forecastButton, function() details.open("Forecast", ui.forecastButton) end)
	for id, row in ui.fleet do
		app.bind(row.details, function() details.open(id, row.details) end)
		app.bind(row.toggle, function() local s = find(id); send("Control", id, not s.on, s.capKW) end)
		app.bind(row.minus, function() local s = find(id); send("Control", id, s.on, math.max(0, s.capKW - 100)) end)
		app.bind(row.plus, function() local s = find(id); send("Control", id, s.on, math.min(s.installedKW, s.capKW + 100)) end)
		app.bind(row.locate, function() app.navigate("Map"); app.selectAsset(id); app.mapController.locate(positions[id][1], positions[id][2]) end)
	end
	app.bind(ui.retry, function() send("Retry") end)
	app.bind(ui.back, function() app.navigate("Map") end)
	app.bind(ui.leave, function()
		if leaving or pending then return end
		leaving = true; intent:FireServer({version = 1, kind = "Exit"}); app.refresh()
	end)
	for _, group in {app.view.navigation.buttons, app.view.navigation.bottom, app.view.drawer.buttons} do
		if group.Infrastructure then
			local button = group.Infrastructure
			if button == app.view.navigation.buttons.Infrastructure then
				button:SetAttribute("LabelOverride", "Control room"); button:SetAttribute("ShortLabelOverride", "Fleet")
				button:SetAttribute("AccessibleLabel", "Operations control room")
			else button.Text = "Control room" end
			app.actions[button] = function() app.navigate("Infrastructure") end
		end
	end
	for _, button in {app.view.header.buttons.Alerts, app.view.drawer.buttons.Alerts} do
		app.actions[button] = function() details.open("Alerts", button) end
	end
	for _, button in {app.view.header.buttons.Help, app.view.drawer.buttons.Help} do app.actions[button] = function()
		app.showFeedback("Operating your national grid", "1. Review the conditional forecast. Wind falls as demand rises.\n2. Enable Reserve Peaker before the shortage; it costs more but can restore service.\n3. Output caps are limits, not forced generation. The server chooses the cheapest feasible dispatch.\n4. Spare generation cannot widen East's 3 MW feeder. Review East reinforcement to widen it to 4 MW for 500 Credits.\n\nMenus keep the active simulation running. Retry resumes a safely suspended calculation without catching up missed time.\n\nTab / D-pad: focus. Enter / A: activate. PgUp/PgDn or LB/RB: scroll panels. M: grid. Escape / B: back. Map focus supports arrows/stick and zoom controls.\n\nTraining is temporary fake storage. Stop Play discards it.", button)
	end end
	for _, group in {app.view.navigation.buttons, app.view.navigation.bottom, app.view.drawer.buttons} do
		if group.Build then app.actions[group.Build] = function()
			investment.open(group.Build)
		end end
	end
	app.actions[app.view.drawer.buttons.Links] = function()
		local enabled = app.view.map.root:GetAttribute("LinksVisible") ~= true
		app.view.map.setOptions(app.view.map.root:GetAttribute("LabelsVisible") == true, enabled)
		app.view.drawer.buttons.Links.Text = "Connections · " .. (if enabled then "on" else "off")
	end
	app.view.drawer.buttons.Links.Text = "Connections · on"
	app.setLayoutAdapter(function(_layout: any, route: string): boolean?
		if route == "Infrastructure" then
			-- Fleet is a dedicated responsive workspace; Grid retains the same map/camera.
			return false
		end
		return nil
	end)
	app.setPresenter(function()
		Presentation.update(app, ui, current, os.clock()-received<3, pending, leaving)
		investment.refresh(); details.refresh()
	end)
	app.navigate("Infrastructure")
	local nextReviewRefresh = 0
	local beat = game:GetService("RunService").Heartbeat:Connect(function()
		if not destroyed and os.clock() >= nextReviewRefresh and (os.clock() - received >= 3 or (app.view.feedback.root.Visible and app.view.feedback.root:GetAttribute("ReinforcementReview") == true)) then
			nextReviewRefresh = os.clock() + .25; app.present()
		end
	end)
	app.view.gui.Destroying:Once(function()
		if not destroyed then intent:FireServer({version = 1, kind = "Exit"}); mounted = nil end
		destroyed = true; connection:Disconnect(); beat:Disconnect()
	end)
	mounted = {app = app, ui = ui, current = function() return current end, entry = entered, send = send, investment = investment, details = details}
	return mounted
end
return table.freeze(Client)
