--!strict
-- Keep virtual layout dimensions intact while testing real engine focus.
local RunService=game:GetService("RunService")
local Target={}
function Target.onScreen(gui:ScreenGui,button:GuiObject):boolean
	local p,s=button.AbsolutePosition,button.AbsoluteSize
	local a,b=gui.AbsolutePosition,gui.AbsoluteSize
	return gui.Enabled and button:IsDescendantOf(gui) and p.X>=a.X and p.Y>=a.Y and p.X+s.X<=a.X+b.X and p.Y+s.Y<=a.Y+b.Y
end
function Target.reveal(app:any,marker:TextButton)
	local viewport=app.view.map.viewport
	local deadline=os.clock()+2
	-- AbsolutePosition is committed by the layout pass after a camera draw.
	RunService.RenderStepped:Wait()
	repeat
		local a,b=viewport.AbsolutePosition,viewport.AbsoluteSize
		local c,d=app.view.gui.AbsolutePosition,app.view.gui.AbsoluteSize
		local left,top=math.max(a.X,c.X),math.max(a.Y,c.Y)
		local right,bottom=math.min(a.X+b.X,c.X+d.X),math.min(a.Y+b.Y,c.Y+d.Y)
		assert(right-left>=44 and bottom-top>=44,"Host viewport cannot contain the unchanged 44px focus target")
		if Target.onScreen(app.view.gui,marker) and app.keyboard.valid(marker) then return end
		local centre=marker.AbsolutePosition+marker.AbsoluteSize/2
		app.mapController.pan((left+right)/2-centre.X,(top+bottom)/2-centre.Y)
		RunService.RenderStepped:Wait()
		-- When the country fits the virtual viewport the camera deliberately
		-- clamps panning. Use normal bounded zoom controls to make pan possible.
		if not Target.onScreen(app.view.gui,marker) and (marker.AbsolutePosition+marker.AbsoluteSize/2-centre).Magnitude<1 then
			app.mapController.changeZoom(.15)
			RunService.RenderStepped:Wait()
		end
	until os.clock()>=deadline
	assert(Target.onScreen(app.view.gui,marker) and app.keyboard.valid(marker),"Marker did not become an on-screen eligible focus target: "..tostring(marker.AbsolutePosition).." visible="..tostring(marker.Visible).." eligible="..tostring(app.keyboard.valid(marker)))
end
return table.freeze(Target)
