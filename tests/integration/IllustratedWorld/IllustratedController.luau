--!strict
local Renderer = require(script.Parent.IllustratedSectorRenderer)
local Controller = {}
local mounted: {[Instance]: any} = setmetatable({}, {__mode="k"}) :: any
function Controller.active(gui: Instance): any return mounted[gui] end
function Controller.attach(app: any, preview: any)
	assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Experimental Test only")
	if mounted[app.view.gui] then return mounted[app.view.gui] end
	local button=app.view.drawer.buttons.Geography
	local oldAction=app.actions[button];local oldText=button.Text
	local renderer: any=nil
	local requested=false
	local function update()
		local state=app.view.map.root:GetAttribute("IllustratedLoadState")
		button.Text=if requested then "Illustrated (Experimental) · "..tostring(state).."\nSelect Native" else "Native · selected\nSelect Illustrated (Experimental)"
		button:SetAttribute("AccessibleLabel",button.Text)
	end
	local function setEnabled(value: boolean)
		if not renderer and value then
			local ok,result=pcall(Renderer.attach,app.view.map,preview)
			if not ok then
				warn("[Illustrated World] Native retained: "..tostring(result));button.Text="Native · illustration unavailable";return
			end
			renderer=result
		end
		requested=value
		if renderer then renderer.setEnabled(value) end
		update()
	end
	-- Reuse a mounted 44+ px control and the shell's keyboard/gamepad action router.
	app.actions[button]=function() setEnabled(not requested) end
	button.TextWrapped=true;update()
	local change=app.view.map.root:GetAttributeChangedSignal("IllustratedLoadState"):Connect(update)
	local destroyed=false
	local function destroy()
		if destroyed then return end;destroyed=true
		change:Disconnect();if renderer then renderer.destroy() end
		app.actions[button]=oldAction;button.Text=oldText;mounted[app.view.gui]=nil
	end
	app.view.gui.Destroying:Once(destroy)
	local result={setEnabled=setEnabled,renderer=function() return renderer end,destroy=destroy}
	mounted[app.view.gui]=result
	return result
end
return table.freeze(Controller)
