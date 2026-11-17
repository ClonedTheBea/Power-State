--!strict
return function(playerGui: PlayerGui)
	local Proof=require(script.Parent.HybridProof)
	local RunService=game:GetService("RunService")
	local GuiService=game:GetService("GuiService")
	local count=0
	local function check(value:boolean,message:string) assert(value,message);count+=1 end
	local existing=playerGui:FindFirstChild("PowerStateShell");if existing then existing:Destroy() end
	local mounted=Proof.mount(playerGui,"real")
	local app,proof=mounted.app,mounted.proof
	local map=app.view.map
	local function settle() for _=1,4 do RunService.RenderStepped:Wait() end end
	local ok,problem=xpcall(function()
		settle();proof.setMode("Hybrid")
		local start=os.clock()
		while proof.state()=="Loading" and os.clock()-start<6 do RunService.RenderStepped:Wait() end
		proof.refresh();settle()
		check(map.root:GetAttribute("CohesionActive")==true,"Real ready activates cohesion")
		local pool=#map.root:GetDescendants()
		check(pool==595,"Bounded 15 additional presentation descendants, below 600")
		app.view.root.Size=UDim2.fromOffset(1366,704);settle();map.render(0,0,0.55)
		local stationName=(map.viewport:FindFirstChild("MapLabels") :: Frame):FindFirstChild("Name_station") :: TextLabel
		check(not stationName.Visible,"Observe mode avoids permanent label wall")
		GuiService.SelectedObject=map.markers.station
		check(stationName.Visible,"Focus reveals contextual name at overview zoom")
		GuiService.SelectedObject=nil
		check(not stationName.Visible,"Focus departure restores quiet observe mode")
		for _,size in {{1366,704},{360,580},{640,300},{768,960}} do
			app.view.root.Size=UDim2.fromOffset(size[1],size[2]);settle();app.mapController.recenter()
			app.selectAsset("station");settle()
			local positions={}
			for id,marker in map.markers do
				positions[id]=marker.Position
				check(marker.Size==UDim2.fromOffset(44,44) and marker.Selectable,"Original accessible hit target")
				check(marker.BackgroundTransparency==1,"Ground artwork unobscured by marker box")
				check(marker.SelectionImageObject~=nil and marker:GetAttribute("AccessibleLabel")~=nil,"Focus and accessible name retained")
				check(app.mapController.actions[marker]~=nil,"Original input action retained")
			end
			local x,y,z=map.root:GetAttribute("CameraX"),map.root:GetAttribute("CameraY"),map.root:GetAttribute("CameraZoom")
			for _,mode in {"Native","Hybrid"} do
				proof.setMode(mode)
				for id,marker in map.markers do
					check(marker.Position==positions[id],"Mode never moves electrical anchor/target")
					check(marker.BackgroundTransparency==(if mode=="Hybrid" then 1 else 0),"Native restoration")
				end
				check(app.state.selectedId=="station","Selection preserved")
				check(map.root:GetAttribute("CameraX")==x and map.root:GetAttribute("CameraY")==y and map.root:GetAttribute("CameraZoom")==z,"Camera preserved")
			end
			map.setOptions(false,true)
			for _,label in (map.viewport:FindFirstChild("MapLabels") :: Frame):GetChildren() do
				if label:IsA("TextLabel") then check(not label.Visible,"Labels toggle respected") end
			end
			map.setOptions(true,true)
			GuiService.SelectedObject=map.markers.station;settle()
			check(GuiService.SelectedObject==map.markers.station,"Existing focus object retained")
			for _=1,60 do app.mapController.pan(2,-1);app.mapController.changeZoom(0.01) end
			check(#map.root:GetDescendants()==pool,"Repeated pan/zoom has no instance growth")
		end
		map.root:SetAttribute("CohesionEnabled",false)
		check(not map.root:GetAttribute("CohesionActive"),"R3.4 comparison switch")
		map.root:SetAttribute("CohesionEnabled",true)
		local image=proof.images[1];local uri=image.Image;image.Image="";proof.refresh()
		check(not map.root:GetAttribute("CohesionActive"),"Missing image restores baseline presentation")
		for _,marker in map.markers do check(marker.BackgroundTransparency==0,"Fallback marker restored") end
		image.Image=uri
	end,function(message:unknown):string return debug.traceback(tostring(message)) end)
	GuiService.SelectedObject=nil;mounted.destroy()
	check(playerGui:FindFirstChild("PowerStateShell")==nil,"Cohesion cleanup removes shell")
	require(script.Parent.Parent.Client.Controllers.AppController).mount(playerGui)
	assert(ok,tostring(problem))
	print(string.format("[Power State R3.5] PASS: %d presentation assertions",count))
	return count
end
