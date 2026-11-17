--!strict
-- Isolated R3.5 presentation experiment. Original buttons/actions remain the hit targets.
local GuiService = game:GetService("GuiService")
local Client = script.Parent.Parent.Client
local Theme = require(Client.Theme)
type Map = {
	root: Frame, viewport: Frame, markers: {[string]: TextButton},
	render: (number,number,number)->(), setSelected: (string?)->(), setOptions: (boolean,boolean)->(),
}
local Presentation = {}
function Presentation.attach(map: Map)
	assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Test-only presentation")
	local markerCount=0
	for _ in map.markers do markerCount+=1 end
	assert(markerCount==5 and #map.root:GetDescendants()+markerCount*3<=600,"R3.5 fixed presentation budget exceeded")
	local originalRender, originalSelected, originalOptions = map.render, map.setSelected, map.setOptions
	local labels = map.viewport:FindFirstChild("MapLabels") :: Frame
	local records = {}
	local connections: {RBXScriptConnection} = {}
	local hovered: string? = nil
	local destroyed = false
	local function active(): boolean
		return map.root:GetAttribute("CohesionEnabled") ~= false and map.root:GetAttribute("ProofMode") == "Hybrid" and map.root:GetAttribute("ProofLoadState") == "Ready"
	end
	for id,marker in map.markers do
		local art: {GuiObject} = {}
		for _,child in marker:GetChildren() do
			if child:IsA("GuiObject") and child.Name ~= "ClusterCount" then table.insert(art,child) end
		end
		local badge = Instance.new("Frame")
		badge.Name="FloatingBadge"; badge.Size=UDim2.fromOffset(44,44)
		-- Entire 22px badge stays inside the unchanged 44px target, above/right of its ground pivot.
		badge.Position=UDim2.fromOffset(22,0); badge.BackgroundColor3=Theme.panel
		badge.BorderSizePixel=0; badge.Active=false; badge.Selectable=false; badge.Visible=false
		local scale=Instance.new("UIScale"); scale.Scale=0.5; scale.Parent=badge
		local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(1,0); corner.Parent=badge
		badge.Parent=marker
		local label=labels:FindFirstChild("Name_"..id) :: TextLabel
		local stroke=marker:FindFirstChildOfClass("UIStroke") :: UIStroke
		records[id]={marker=marker,badge=badge,art=art,label=label,stroke=stroke,
			background=marker.BackgroundTransparency,strokeTransparency=stroke.Transparency,labelVisible=label.Visible}
	end
	local function apply(capture: boolean?)
		if destroyed then return end
		local enabled=active()
		for id,r in records do
			if capture then r.labelVisible=r.label.Visible end
			r.marker.BackgroundTransparency=if enabled then 1 else r.background
			r.stroke.Transparency=if enabled then 1 else r.strokeTransparency
			r.badge.Visible=enabled
			for _,piece in r.art do piece.Parent=if enabled then r.badge else r.marker end
			local context=r.marker:GetAttribute("Selected")==true or hovered==id or GuiService.SelectedObject==r.marker
			local py=r.marker.Position.Y.Offset
			local fits=r.marker.Visible and map.root:GetAttribute("LabelsVisible")==true and py>52 and py+55<map.viewport.AbsoluteSize.Y-60
			for otherId,other in records do
				if otherId~=id then
					local p=other.marker.Position
					if math.abs(p.X.Offset-r.label.Position.X.Offset)<108 and p.Y.Offset+22>py+27 and p.Y.Offset-22<py+55 then fits=false end
				end
			end
			-- Focus/hover must reveal a name even in the overview zoom band.
			r.label.Visible=if enabled then context and fits else r.labelVisible
		end
		map.root:SetAttribute("CohesionActive",enabled)
	end
	map.render=function(x:number,y:number,z:number) originalRender(x,y,z);apply(true) end
	map.setSelected=function(id:string?) originalSelected(id);apply(true) end
	map.setOptions=function(names:boolean,links:boolean) originalOptions(names,links);apply(true) end
	for id,r in records do
		table.insert(connections,r.marker.MouseEnter:Connect(function() hovered=id;apply() end))
		table.insert(connections,r.marker.MouseLeave:Connect(function() if hovered==id then hovered=nil end;apply() end))
		table.insert(connections,r.marker:GetAttributeChangedSignal("Selected"):Connect(function() apply() end))
	end
	for _,key in {"ProofMode","ProofLoadState","CohesionEnabled"} do
		table.insert(connections,map.root:GetAttributeChangedSignal(key):Connect(function() apply() end))
	end
	table.insert(connections,GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function() apply() end))
	local function destroy()
		if destroyed then return end
		destroyed=true
		for _,connection in connections do connection:Disconnect() end
		map.render=originalRender;map.setSelected=originalSelected;map.setOptions=originalOptions
		for _,r in records do
			for _,piece in r.art do piece.Parent=r.marker end
			r.marker.BackgroundTransparency=r.background;r.stroke.Transparency=r.strokeTransparency
			r.label.Visible=r.labelVisible;r.badge:Destroy()
		end
		map.root:SetAttribute("CohesionActive",nil)
	end
	table.insert(connections,map.root.Destroying:Connect(destroy))
	apply(true)
	return {destroy=destroy,refresh=apply}
end
return Presentation
