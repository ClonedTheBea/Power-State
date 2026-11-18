--!strict
local App = require(script.Parent.Parent.Controllers.AppController)
local View = require(script.Parent.OperationsView)
local Client = {}
local mounted: any = nil
local released: any = nil
local positions = {gas = {250, 400}, wind = {300, 160}, peak = {220, 680}, sub = {500, 400}, a = {740, 240}, b = {740, 670}}
local names = {gas = "Central Gas", wind = "Coastal Wind", peak = "Reserve Peaker", sub = "National Substation", a = "North Customers", b = "East Customers"}
function Client.active(): any return mounted end
function Client.lastRelease(): any return released end
function Client.attachEntry(first: any, playerGui: PlayerGui, reopen: () -> ())
	for _, group in {first.app.view.navigation.buttons, first.app.view.navigation.bottom, first.app.view.drawer.buttons} do
		local button = group.Infrastructure
		if button then
			if button == first.app.view.navigation.buttons.Infrastructure then
				button:SetAttribute("LabelOverride", "Operations Training"); button:SetAttribute("ShortLabelOverride", "Training")
				button:SetAttribute("AccessibleLabel", "Enter Operations Training")
			else button.Text = "Operations Training" end
			first.app.actions[button] = function()
				if mounted then return end
				mounted = {loading = true}
				task.spawn(function()
					local ok, problem = pcall(Client.mount, first, playerGui, reopen)
					if not ok then
						mounted = nil; warn("[Operations GUI] " .. tostring(problem))
						if first.app.view.gui.Parent then first.app.showFeedback("Training unavailable", "Could not enter the training country. No profile was reset.", button) end
					end
				end)
			end
		end
	end
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
		if app then app.refresh() end
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
		{label = "RELIABILITY", value = "Loading", detail = "Delivered / requested energy"},
		{label = "HEADROOM", value = "Loading", detail = "Dispatchable, not guaranteed deliverable reserve"},
	}}
	for _, id in {"gas", "wind", "peak", "sub", "a", "b"} do
		table.insert(preview.nodes, {id = id, name = names[id], kind = if id == "sub" then "Substation" elseif id == "a" or id == "b" then "Settlement" else "Generator",
			x = positions[id][1], y = positions[id][2], description = "Operations training infrastructure · server-authoritative electricity"})
	end
	for _, pair in {{"gas", "sub"}, {"wind", "sub"}, {"peak", "sub"}, {"sub", "a"}, {"sub", "b"}} do table.insert(preview.links, {from = pair[1], to = pair[2]}) end
	first.destroy()
	app = App.mount(playerGui, preview); ui = View.create(app)
	local function send(kind: "Control" | "Retry", source: any?, on: boolean?, cap: number?)
		if pending or leaving or os.clock() - received >= 3 then return end
		if current.saving then return end
		if kind == "Control" then if current.saveBlocked then return end end
		local payload: any = {version = 1, kind = kind, epoch = current.epoch, revision = current.revision, sequence = current.nextSequence}
		if kind == "Control" then payload.sourceId = source; payload.on = on; payload.capKW = cap end
		pending = true; intent:FireServer(payload); app.refresh()
	end
	local function find(id: string): any for _, source in current.fleet do if source.id == id then return source end end; return nil end
	for id, row in ui.fleet do
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
	for _, button in {app.view.header.overview, app.view.drawer.buttons.Overview, app.view.header.buttons.Alerts, app.view.drawer.buttons.Alerts} do
		app.actions[button] = function() app.navigate("Infrastructure") end
	end
	for _, button in app.view.kpis.buttons do app.actions[button] = function() app.navigate("Infrastructure") end end
	for _, button in {app.view.header.buttons.Help, app.view.drawer.buttons.Help} do app.actions[button] = function()
		app.showFeedback("Operating your national grid", "1. Review the conditional forecast. Wind falls as demand rises.\n2. Enable Reserve Peaker before the shortage; it costs more but can restore service.\n3. Output caps are limits, not forced generation. The server chooses the cheapest feasible dispatch.\n4. Spare generation cannot widen East's 3 MW feeder. Reinforcement is a future project.\n\nMenus keep the active simulation running. Retry resumes a safely suspended calculation without catching up missed time.\n\nTab / D-pad: focus. Enter / A: activate. M: grid. Escape / B: back. Map focus supports arrows/stick and zoom controls.\n\nTraining is temporary fake storage. Stop Play discards it.", button)
	end end
	for _, group in {app.view.navigation.buttons, app.view.navigation.bottom, app.view.drawer.buttons} do
		if group.Build then app.actions[group.Build] = function()
			app.showFeedback("Training fleet is already installed", "This mode teaches dispatch and network operation. New fleet purchases are not implemented. Return to First Playable for the existing district project.", group.Build)
		end end
	end
	app.actions[app.view.drawer.buttons.Links] = function()
		local enabled = app.view.map.root:GetAttribute("LinksVisible") ~= true
		app.view.map.setOptions(app.view.map.root:GetAttribute("LabelsVisible") == true, enabled)
		app.view.drawer.buttons.Links.Text = "Connections · " .. (if enabled then "on" else "off")
	end
	app.view.drawer.buttons.Links.Text = "Connections · on"
	app.setLayoutAdapter(function(layout: any, route: string): boolean?
		if route == "Infrastructure" then
			if layout.content.width >= 900 then layout.mapWidth = layout.content.width - 430; return true end
			return false
		end
		return nil
	end)
	app.setPresenter(function()
		local v = app.view
		local healthy = os.clock() - received < 3
		v.header.identity.Text = "POWER STATE · Operations Training"
		v.header.status.Text = if not healthy then "Connection unavailable" else current.status .. " · minute " .. current.step
		v.kpis.cards[1].value.Text = string.format("%.2f Credits", current.bankMinor / 100)
		v.kpis.cards[2].value.Text = string.format("%.3f / %.3f MW", current.deliveredKW / 1000, current.demandKW / 1000)
		v.kpis.cards[3].value.Text = string.format("%.1f%%", current.reliability * 100)
		v.kpis.cards[4].value.Text = string.format("%.3f MW", current.headroomKW / 1000)
		local controls = app.state.route == "Infrastructure"
		ui.panel.Visible = controls
		if controls then
			v.pageTitle.Visible = false; v.pageTag.Visible = false; v.pageBody.Visible = false; v.pageBack.Visible = false
			local width = v.page.Parent.AbsoluteSize.X; local height = v.page.Parent.AbsoluteSize.Y
			if width >= 900 then
				v.page.Position = UDim2.fromOffset(width - 420, 0); v.page.Size = UDim2.fromOffset(420, height)
			else v.page.Position = UDim2.fromOffset(0, 0); v.page.Size = UDim2.fromOffset(width, height) end
		else
			v.page.Position = UDim2.fromOffset(0, 0); v.page.Size = UDim2.fromScale(1, 1)
			v.pageTitle.Visible = true; v.pageTag.Visible = true; v.pageBody.Visible = true; v.pageBack.Visible = true
		end
		ui.status.Text = if leaving then "Saving and leaving training…" elseif not healthy then "Connection unavailable. Controls disabled."
			elseif pending then "Command pending — awaiting server" else current.outcome .. " · " .. current.status .. (if current.saving then " · checkpoint pending" else "")
		ui.totals.Text = string.format("Generated %.3f MW · Installed 9 MW\nAvailable %.3f MW · Unserved %.3f MW\nLive Bank %.2f Credits · Confirmed %.2f Credits\nSales %.2f · Expenses %.2f · Net %.2f Credits\nHeadroom is not guaranteed deliverable reserve.", current.generatedKW / 1000, current.availableKW / 1000, current.unmetKW / 1000,
			current.bankMinor / 100, current.savedBankMinor / 100, current.salesMinor / 100, current.expensesMinor / 100, (current.salesMinor - current.expensesMinor) / 100)
		for _, source in current.fleet do
			local row = ui.fleet[source.id]
			row.text.TextSize = 14 * (v.root:GetAttribute("TextScale") or 1)
			row.text.Text = string.format("%s · %s\nOutput %.3f / available %.3f MW · Installed %.1f MW\nCap %.1f MW · %.0f Credits/MWh + %.0f Credits/h On\nCosts %.2f variable + %.2f fixed Credits%s", source.name, if source.on then "On" else "Off", source.outputKW / 1000, source.availableKW / 1000, source.installedKW / 1000, source.capKW / 1000,
				source.variableMinorPerMWh / 100, source.fixedMinorPerHour / 100, source.variableExpenseMinor / 100, source.fixedExpenseMinor / 100,
				if source.id == "wind" then string.format("\nWind potential %.3f MW · curtailed %.3f MW", source.potentialKW / 1000, source.curtailedKW / 1000) else "")
			row.toggle.Text = if source.on then "Switch Off" else "Switch On"
			for _, button in {row.toggle, row.minus, row.plus} do button.Active = healthy and not pending and not leaving and not current.saving and not current.saveBlocked end
		end
		local forecast = {"CONDITIONAL 60-MINUTE FORECAST · issued minute " .. current.forecast.step,
			"Offsets from issue minute · current controls · capacity estimate, not a routed solve"}
		for _, sample in current.forecast.samples do
			table.insert(forecast, string.format("+%d min: demand %.2f · wind %.2f · available %.2f MW%s%s", sample.offset, sample.demandKW / 1000, sample.windKW / 1000, sample.availableKW / 1000,
				if sample.capacityShortfallKW > 0 then " · SHORTAGE" else "", if sample.branchLimited then " · feeder constrained" else ""))
		end
		ui.forecast.Text = table.concat(forecast, "\n")
		ui.alerts.Text = if #current.alerts > 0 then table.concat(current.alerts, "\n") else "No active operational alerts."
		ui.retry.Visible = current.status == "Suspended" or current.status == "Invalidated" or current.saveBlocked
		ui.retry.Active = healthy and not pending and not leaving
		local selected = app.state.selectedId
		if positions[selected] then
			v.inspector.title.Text = names[selected]; v.inspector.tag.Text = "OPERATIONS · TRAINING"
			local source = find(selected)
			v.inspector.body.Text = if source then string.format("%s · output %.3f MW\nAvailable %.3f MW · cap %.1f MW\nOpen Control room to change dispatch limits.", if source.on then "On" else "Off", source.outputKW / 1000, source.availableKW / 1000, source.capKW / 1000)
				else "Shared electrical network. East feeder capacity: 3 MW. View Control room for national service and forecast."
			local sink = current.sinks[selected]
			if sink then v.inspector.body.Text = string.format("Requested %.3f MW\nDelivered %.3f MW\nUnserved %.3f MW\n%s", sink.requestedKW / 1000, sink.deliveredKW / 1000, sink.unmetKW / 1000, if selected == "b" then "East feeder limit: 3 MW" else "North feeder limit: 6 MW") end
			if selected == "sub" then
				local lines = {"National substation · 10 MW"}
				for _, line in {{id = "gs", label = "Gas", capacity = 5}, {id = "ws", label = "Wind", capacity = 2},
					{id = "ps", label = "Peaker", capacity = 2}, {id = "sa", label = "North", capacity = 6}, {id = "sb", label = "East", capacity = 3}} do
					table.insert(lines, string.format("%s: %.3f / %d MW", line.label, math.abs(current.flowsKW[line.id] or 0) / 1000, line.capacity))
				end
				v.inspector.body.Text = table.concat(lines, "\n")
			end
			v.inspector.note.Text = "Completed server results · temporary training country"
		end
	end)
	app.navigate("Infrastructure")
	local beat = game:GetService("RunService").Heartbeat:Connect(function()
		if not destroyed and os.clock() - received >= 3 then app.refresh() end
	end)
	app.view.gui.Destroying:Once(function()
		if not destroyed then intent:FireServer({version = 1, kind = "Exit"}); mounted = nil end
		destroyed = true; connection:Disconnect(); beat:Disconnect()
	end)
	mounted = {app = app, ui = ui, current = function() return current end, entry = entered, send = send}
	return mounted
end
return table.freeze(Client)
