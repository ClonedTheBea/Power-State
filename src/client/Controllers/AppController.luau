--!strict
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local DashboardView = require(script.Parent.Parent.Views.DashboardView)
local Preview = require(script.Parent.Parent.PreviewData)
local Navigation = require(script.Parent.Parent.Navigation)
local Theme = require(script.Parent.Parent.Theme)
local Scope = require(script.Parent.Parent.Util.Scope)
local MapController = require(script.Parent.MapController)
local KeyboardController = require(script.Parent.KeyboardController)
local MapInputController = require(script.Parent.MapInputController)
local Shared = game:GetService("ReplicatedStorage").Shared
local Layout = require(Shared.Util.Layout)
local ShellState = require(Shared.Util.ShellState)
local CurrencyFormat = require(Shared.Util.CurrencyFormat)
local AppController = {}
function AppController.mount(playerGui: PlayerGui, data: typeof(Preview)?)
	local preview = data or Preview
	local presenter: (() -> ())? = nil
	local layoutAdapter: ((Layout.Result, string) -> boolean?)? = nil
	local scope = Scope.new()
	local previousOrientation = playerGui.ScreenOrientation
	playerGui.ScreenOrientation = Enum.ScreenOrientation.Sensor
	local view = DashboardView.create(playerGui, preview)
	local state = ShellState.new()
	local actions: { [TextButton]: () -> () } = {}
	local invoker: GuiObject? = nil
	local destroyed = false
	local focusRevision = 0
	local function focusControl(target: GuiObject?)
		focusRevision += 1
		local revision = focusRevision
		if not target then GuiService.SelectedObject = nil; return end
		-- Resolve visibility after layout, and discard focus requests superseded by another action.
		task.spawn(function()
			-- Device Simulator updates safe insets and the native selection overlay
			-- across successive frames when rotating; wait for both layout passes.
			for _ = 1, 2 do game:GetService("RunService").RenderStepped:Wait() end
			if destroyed or revision ~= focusRevision or not target.Parent then return end
			local ancestor: Instance? = target
			while ancestor and ancestor ~= view.gui do
				if ancestor:IsA("GuiObject") and not ancestor.Visible then return end
				ancestor = ancestor.Parent
			end
			local p, s = target.AbsolutePosition, target.AbsoluteSize
			local a, b = view.gui.AbsolutePosition, view.gui.AbsoluteSize
			if p.X + s.X <= a.X or p.Y + s.Y <= a.Y or p.X >= a.X + b.X or p.Y >= a.Y + b.Y then return end
			GuiService.SelectedObject = target
		end)
	end
	local function bind(button: TextButton, action: () -> ())
		actions[button] = action
		scope.add(button.Activated:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Keyboard and not string.find(input.UserInputType.Name, "Gamepad", 1, true) then actions[button]() end
		end))
	end
	local function refresh()
		local isMap = state.route == "Map" or state.route == "Build"
		view.page.Visible = not isMap
		view.inspector.root.Visible = isMap and state.inspectorStage ~= "closed"
		local layout = Layout.resolve(view.root.AbsoluteSize.X, view.root.AbsoluteSize.Y, {
			railExpanded = state.railExpanded,
			inspectorStage = if view.inspector.root.Visible then state.inspectorStage else "closed",
			textScale = view.root:GetAttribute("TextScale") :: number,
		})
		local mapVisible = if layoutAdapter then layoutAdapter(layout, state.route) else nil
		view.map.root.Visible = if mapVisible ~= nil then mapVisible else isMap
		view.applyLayout(layout, state.route, state.inspectorStage)
		view.blocker.Visible = view.drawer.root.Visible or view.feedback.root.Visible
		view.mapFocus.Text = if state.mapFocus then "UI focus" else "Map focus"
		view.focusHint.Visible = state.mapFocus
		view.mapFocus:SetAttribute("AccessibleLabel", "Map focus: arrows / stick pan, +/- or shoulders zoom, Home recenter, A assets, B back")
		view.root:SetAttribute("SelectedAsset", state.selectedId)
		view.root:SetAttribute("Route", state.route)
		view.root:SetAttribute("InspectorStage", state.inspectorStage)
		view.map.setSelected(state.selectedId)
		view.inspector.locate.Visible = state.selectedId ~= nil
		for id, marker in view.map.markers do
			local selected = id == state.selectedId
			marker.BackgroundColor3 = if selected then Theme.accent else Theme.raised
			marker.TextColor3 = if selected then Theme.onAccent else Theme.accent
			marker:SetAttribute("Selected", selected)
			if Theme.visualRedesign then local stroke=marker:FindFirstChildOfClass("UIStroke");if stroke then stroke.Color=if selected then Theme.grid else Theme.borderInteractive;stroke.Thickness=if selected then 2 else 1 end end
		end
		if presenter then presenter() end
	end
	local function restoreFocus()
		local target = invoker
		local visible = target ~= nil and target.Parent ~= nil
		local ancestor: Instance? = target
		while ancestor and ancestor ~= view.root.Parent do
			if ancestor:IsA("GuiObject") and not ancestor.Visible then visible = false end
			ancestor = ancestor.Parent
		end
		focusControl(if visible then target else view.header.overview)
		invoker = nil
	end
	local function closeModal()
		if view.feedback.root.Visible then view.feedback.root.Visible = false
		elseif view.drawer.root.Visible then view.drawer.root.Visible = false end
		refresh(); restoreFocus()
	end
	local function showFeedback(title: string, body: string, source: GuiObject?, kind: string?)
		invoker = source or GuiService.SelectedObject
		state.mapFocus = false
		view.drawer.root.Visible = false
		view.feedback.show(kind or "notice", title, body)
		refresh()
		focusControl(view.feedback.close)
	end
	local function showDrawer(mode: string, source: GuiObject?)
		invoker = source or GuiService.SelectedObject
		state.mapFocus = false
		view.feedback.root.Visible = false
		view.drawer.show(mode)
		refresh()
		focusControl(view.drawer.close)
	end
	local function showSelection()
		if presenter then presenter(); return end
		for _, button in view.inspector.demos do button.Visible = false end
		local selected = state.selectedId
		for _, node in preview.nodes do
			if node.id == selected then
				view.inspector.set(node.name, node.kind .. " · Illustrative asset", node.name .. "\n\n" .. node.description)
				view.inspector.note.Text = "Operating status and history: unavailable. No live grid, construction or saving is connected."
				return
			end
		end
		view.inspector.set("National overview", "Illustrative grid", "No asset selected. Use Assets or a map marker to inspect the authored country.")
		view.inspector.note.Text = "All values are samples. The Overview header opens exact Bank, supply, reliability and population details."
	end
	local function selectAsset(id: string)
		ShellState.select(state, id)
		view.drawer.root.Visible = false
		state.mapFocus = false
		showSelection(); refresh()
		focusControl(view.inspector.close)
	end
	local function navigate(id: string)
		for _, destination in Navigation do
			if destination.id == id then
				ShellState.navigate(state, id)
				view.drawer.root.Visible = false
				view.feedback.root.Visible = false
				view.pageTitle.Text = destination.label
				view.pageTag.Text = "Later · " .. destination.phase .. " · Not implemented"
				view.pageBody.Text = destination.description
				refresh()
				if id == "Build" then showFeedback("Build · later in P3", destination.description, view.navigation.bottom.Build) end
				return
			end
		end
	end
	local function overview(source: GuiObject)
		showFeedback("Westhaven · illustrative overview",
			"Bank: " .. CurrencyFormat.format(10000000) .. "\nSupply / demand: 7 / 9 MW (sample only).\nReliability: 92% (illustrative; no observation period exists yet).\nPopulation: 10,000 (sample).\n\nGrid status and simulated date: unavailable. No simulation or saving is connected.", source)
	end
	local function back()
		if view.feedback.root.Visible or view.drawer.root.Visible then closeModal()
		elseif state.mapFocus then state.mapFocus = false; refresh(); focusControl(view.mapFocus)
		elseif state.inspectorStage ~= "closed" then ShellState.closeInspector(state); refresh(); focusControl(view.details)
		elseif state.route ~= "Map" then navigate("Map"); focusControl(view.header.overview) end
	end
	local function mapEnabled(): boolean
		return view.map.root.Visible and not view.blocker.Visible and not GuiService.MenuIsOpen
	end
	local mapController = MapController.attach(view.map, selectAsset, mapEnabled, function() showDrawer("Assets", view.assetList) end)
	for button, action in mapController.actions do actions[button] = action end
	for id, button in view.navigation.buttons do bind(button, function() navigate(id) end) end
	for id, button in view.navigation.bottom do
		bind(button, function() if id == "More" then showDrawer("More", button) else navigate(id) end end)
	end
	bind(view.navigation.collapse, function()
		if view.root.AbsoluteSize.X < 1100 then showDrawer("More", view.navigation.collapse); return end
		local layout = Layout.resolve(view.root.AbsoluteSize.X, view.root.AbsoluteSize.Y, { railExpanded = state.railExpanded })
		state.railExpanded = not layout.railExpanded
		refresh()
	end)
	for _, destination in Navigation do
		bind(view.drawer.buttons[destination.id], function() navigate(destination.id) end)
	end
	for _, node in preview.nodes do bind(view.drawer.buttons["Asset_" .. node.id], function() selectAsset(node.id) end) end
	bind(view.header.overview, function() overview(view.header.overview) end)
	bind(view.drawer.buttons.Overview, function() overview(view.drawer.buttons.Overview) end)
	bind(view.assetList, function() showDrawer("Assets", view.assetList) end)
	bind(view.layers, function() showDrawer("Layers", view.layers) end)
	bind(view.drawer.buttons.Geography, function() closeModal() end)
	for _, option in { "Labels", "Links" } do
		local button = view.drawer.buttons[option]
		bind(button, function()
			local attribute = option .. "Visible"
			local enabled = view.map.root:GetAttribute(attribute) ~= true
			view.map.setOptions(if option == "Labels" then enabled else view.map.root:GetAttribute("LabelsVisible") == true,
				if option == "Links" then enabled else view.map.root:GetAttribute("LinksVisible") == true)
			button.Text = (if option == "Labels" then "Labels" else "Sample connections") .. (if enabled then " · on" else " · off")
		end)
	end
	for _, name in { "Power flow", "Electricity demand", "Infrastructure condition", "National development", "Weather", "Seasonal events" } do
		bind(view.drawer.buttons["Layer_" .. name], function()
			showFeedback(name .. " · unavailable", "This layer requires future server-owned gameplay data. R3 provides Geography and explicitly illustrative connections only. No readings, faults, weather or events are inferred from the artwork.", view.layers)
		end)
	end
	bind(view.inspector.locate, function()
		for _, node in preview.nodes do if node.id == state.selectedId then
			ShellState.closeInspector(state); refresh()
			task.defer(function() if not destroyed then mapController.locate(node.x, node.y) end end)
			focusControl(view.details)
		end end
	end)
	bind(view.drawer.buttons.Assets, function() showDrawer("Assets", view.drawer.buttons.Assets) end)
	bind(view.details, function()
		if state.inspectorStage == "closed" then state.inspectorStage = "half"; showSelection() else ShellState.closeInspector(state) end
		refresh()
	end)
	bind(view.inspector.close, function() ShellState.closeInspector(state); refresh(); focusControl(view.details) end)
	bind(view.inspector.expand, function() ShellState.cycleInspector(state); refresh() end)
	bind(view.mapFocus, function()
		state.mapFocus = not state.mapFocus
		refresh()
		focusControl(if state.mapFocus then nil else view.mapFocus)
	end)
	local function utility(id: string, button: TextButton)
		if id == "Settings" then showDrawer("Settings", button)
		elseif id == "Help" then
			invoker = button
			view.drawer.root.Visible = false
			state.inspectorStage = "expanded"
			navigate("Map")
			view.inspector.set("Shell help", "R2 · Presentation preview", "Map focus: arrows / left stick pan; +/- or shoulders zoom; Home or Recenter resets. A opens Assets; B returns to UI focus. Tab / D-pad moves focus; Enter / A activates. Escape / B closes the top local panel. M returns to Grid.")
			view.inspector.note.Text = "Touch: drag the map, tap an asset, use zoom buttons. Details keeps your selection when closed. All readings are illustrative."
			for _, demo in view.inspector.demos do demo.Visible = true end
			refresh(); focusControl(view.inspector.close)
		elseif id == "Alerts" then showFeedback("Alerts · unavailable", "No live alert service is connected. The illustrative map does not report real outages. Alert and ticker components are a later R4 task.", button)
		else showFeedback("Profile · later in P9", "Company and player profiles are not connected. No account information is loaded or changed.", button) end
	end
	for id, button in view.header.buttons do bind(button, function() utility(id, button) end) end
	for _, id in { "Settings", "Profile", "Help", "Alerts" } do
		local button = view.drawer.buttons[id]; bind(button, function() utility(id, button) end)
	end
	for _, percent in { 100, 125, 150 } do
		bind(view.drawer.buttons["Text" .. percent], function() view.root:SetAttribute("TextScale", percent / 100) end)
	end
	for index, button in view.kpis.buttons do bind(button, function()
		local metric = preview.metrics[index]
		local message = if index == 1 then CurrencyFormat.format(metric.currencyMinor) .. "\n\nIllustrative balance, not live money. Finance and income benefits are unavailable."
			elseif index == 2 then "7 / 9 MW · illustrative supply / demand. These are authored samples, not a dispatch calculation. Delivered power and unmet regional demand require P2."
			elseif index == 3 then "92% · illustrative reliability. There is no live observation period or outage history yet."
			else "10,000 · illustrative population. National development is not simulated."
		showFeedback(metric.label .. " · preview", message, button)
	end) end
	for kind, button in view.inspector.demos do bind(button, function()
		showFeedback("Sample " .. kind, "Development component preview only. No operation was attempted, no country data changed, and no service request is running.", button, kind)
	end) end
	bind(view.feedback.close, closeModal); bind(view.drawer.close, closeModal)
	bind(view.pageBack, function() navigate("Map"); focusControl(view.header.overview) end)
	local mapInput = MapInputController.attach(mapController, function() return state.mapFocus and mapEnabled() end,
		function() state.mapFocus = false; refresh(); focusControl(view.mapFocus) end,
		function() showDrawer("Assets", view.mapFocus) end)
	local keyboard = KeyboardController.attach(view.root, actions, function()
		if view.feedback.root.Visible then return view.feedback.root end
		if view.drawer.root.Visible then return view.drawer.root end
		return view.root
	end, function() return state.mapFocus end, back, mapInput.gamepadBegin,
		function() return if view.inspector.root.Visible then view.inspector.root else nil end)
	scope.add(UserInputService.InputBegan:Connect(function(input, processed)
		if UserInputService:GetFocusedTextBox() then return end
		if input.KeyCode == Enum.KeyCode.Escape then back()
		elseif not processed and not GuiService.MenuIsOpen and input.KeyCode == Enum.KeyCode.M then navigate("Map")
		elseif input.KeyCode == Enum.KeyCode.Tab and state.mapFocus then state.mapFocus = false; refresh() end
	end))
	scope.add(view.root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local focused = GuiService.SelectedObject
		refresh()
		if focused and focused:IsDescendantOf(view.root) then
			-- Rotation can move a focused control beneath a sheet. Rebind after layout
			-- so native selection art cannot remain at its previous screen position.
			focusControl(nil)
			focusControl(if view.feedback.root.Visible then view.feedback.close
				elseif view.drawer.root.Visible then view.drawer.close
				elseif view.inspector.root.Visible then view.inspector.close else focused)
		end
	end))
	scope.add(view.root:GetAttributeChangedSignal("TextScale"):Connect(refresh))
	local function cleanup()
		if destroyed then return end
		destroyed = true
		mapInput.destroy(); keyboard.destroy(); mapController.destroy(); scope.destroy()
		playerGui.ScreenOrientation = previousOrientation
	end
	scope.add(view.gui.Destroying:Connect(cleanup))
	showSelection(); refresh()
	task.defer(function()
		-- Initial AbsoluteSize events can describe the constructor's temporary rectangles.
		-- Frame the country only after the responsive shell has committed its geometry.
		RunService.RenderStepped:Wait(); RunService.RenderStepped:Wait()
		if not destroyed then mapController.recenter() end
	end)
	return { view = view, state = state, actions = actions, navigate = navigate, selectAsset = selectAsset,
		refresh = refresh, present = function() if presenter then presenter() end end, bind = bind, showFeedback = showFeedback, setPresenter = function(callback: () -> ()) presenter = callback; refresh() end, keyboard = keyboard, mapController = mapController, back = back,
		setLayoutAdapter = function(callback: (Layout.Result, string) -> boolean?) layoutAdapter = callback; refresh() end,
		destroy = function() cleanup(); view.gui:Destroy() end }
end
return AppController
