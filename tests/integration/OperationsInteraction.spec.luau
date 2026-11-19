--!strict
-- Engine layout/action checks, not synthetic proof of a physical swipe.
return function()
	local Operations = require(script.Parent.Parent.Client.Simulation.OperationsClient)
	local Scroll = require(script.Parent.Parent.Client.Controllers.ScrollNavigation)
	local R = game:GetService("RunService")
	local G = game:GetService("GuiService")
	local t = Operations.active(); assert(t and t.app, "Mounted Training")
	local app, ui = t.app, t.ui
	local count = 0
	local function check(ok: boolean, why: string) assert(ok, why); count += 1 end
	local function layout() R.RenderStepped:Wait(); R.RenderStepped:Wait() end
	local function paging(scroll: ScrollingFrame)
		local maxY = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
		check(maxY > 0, "Fixture genuinely overflows")
		local before = scroll.CanvasPosition.Y
		check(app.keyboard.scrollPage(1), "Visible panel found")
		layout()
		check(scroll.CanvasPosition.Y > before, "Page advances content")
		for _ = 1, 40 do app.keyboard.scrollPage(1) end
		layout()
		check(math.abs(scroll.CanvasPosition.Y - maxY) <= 1, "Bottom clamp reaches final content")
		for _ = 1, 40 do app.keyboard.scrollPage(-1) end
		layout()
		check(scroll.CanvasPosition.Y <= 1, "Top clamp")
	end
	local originalSize = app.view.root.Size
	local originalScale = app.view.root:GetAttribute("TextScale")
	for _, size in {Vector2.new(390,640), Vector2.new(844,390), Vector2.new(1024,720), Vector2.new(1366,704)} do
		app.view.root.Size = UDim2.fromOffset(size.X,size.Y); app.navigate("Infrastructure"); layout()
		G.SelectedObject = nil
		ui.panel.CanvasPosition = Vector2.zero; layout()
		check(Scroll.target(app.view.root,nil) == ui.panel, "Fleet is active overflow target")
		paging(ui.panel)
		app.keyboard.focus(ui.fleet.peak.toggle); layout()
		check(G.SelectedObject == ui.fleet.peak.toggle, "Offscreen fleet control scrolled into focus")
		local top = ui.fleet.peak.toggle.AbsolutePosition.Y - ui.panel.AbsolutePosition.Y
		check(top >= -1 and top + 44 <= ui.panel.AbsoluteWindowSize.Y + 1, "Focus target inside fleet viewport")
		app.keyboard.scrollPage(-1); layout()
		check(G.SelectedObject == nil, "Paging does not leave hidden button armed")
		app.actions[app.view.navigation.bottom.More](); layout()
		local drawer = app.view.drawer.root:FindFirstChild("Items") :: ScrollingFrame
		local fleetY = ui.panel.CanvasPosition.Y
		paging(drawer)
		check(ui.panel.CanvasPosition.Y == fleetY, "Modal paging does not scroll background fleet")
		app.keyboard.focus(app.view.drawer.buttons.Overview); layout()
		check(G.SelectedObject == app.view.drawer.buttons.Overview, "Drawer Bank reachable by focus")
		app.keyboard.activate(); layout()
		check(app.view.feedback.root.Visible, "Bank action opens modal")
		app.view.root:SetAttribute("TextScale",1.5); layout()
		local bank = app.view.feedback.root:FindFirstChild("Message") :: ScrollingFrame
		paging(bank)
		check(G.SelectedObject == app.view.feedback.close, "Text paging retains safe close focus")
		app.keyboard.activate(); layout()
		check(not app.view.feedback.root.Visible, "Close remains accessible after paging")
		app.view.root:SetAttribute("TextScale",originalScale); layout()
		check(#app.view.map.root:GetDescendants() <= 600, "Map instance bound")
	end
	app.view.root.Size = originalSize; app.refresh(); layout()
	app.navigate("Map"); app.state.mapFocus = true; app.refresh()
	check(not app.keyboard.scrollPage(1), "Map focus preserves shoulder zoom ownership")
	app.state.mapFocus = false; app.navigate("Infrastructure"); layout()
	print("[Operations v1.2 interaction] PASS: " .. count .. " engine paging/focus assertions (not physical swipe)")
end
