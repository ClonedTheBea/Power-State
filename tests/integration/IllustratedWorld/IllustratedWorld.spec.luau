--!strict
return function(playerGui: PlayerGui, fixtures: {any})
	local Client=script.Parent.Parent.Parent.Client
	local App=require(Client.Controllers.AppController)
	local Renderer=require(script.Parent.IllustratedSectorRenderer)
	local Catalog=require(script.Parent.IllustratedAtlasCatalog)
	local Geometry=require(Client.Views.Map.MapGeometry)
	local Run=game:GetService("RunService")
	local Gui=game:GetService("GuiService")
	local Focus=require(script.Parent.Parent.FocusTarget)
	local count=0
	local function check(v: boolean,m: string) assert(v,m);count+=1 end
	local function settle() for _=1,4 do Run.RenderStepped:Wait() end end
	local function ready(map: any)
		local start=os.clock()
		while map.root:GetAttribute("IllustratedActive")~=true and os.clock()-start<6 do Run.RenderStepped:Wait() end
		check(map.root:GetAttribute("IllustratedActive")==true,"Real illustrated readiness: "..tostring(map.root:GetAttribute("IllustratedLoadState")))
	end
	local function memory(): number?
		local ok,n=pcall(function()return game:GetService("Stats"):GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.GraphicsTexture)end)
		return if ok then n else nil
	end
	local function mount(fixture: any)
		local existing=playerGui:FindFirstChild("PowerStateShell");if existing then existing:Destroy() end
		local app=App.mount(playerGui,fixture);settle()
		for i,line in app.view.map.linkFrames do line:SetAttribute("PreviewOnly",i==3) end
		return app
	end
	local results={}
	for fi,fixture in fixtures do
		local app=mount(fixture);local map=app.view.map
		local before=#map.root:GetDescendants();local mem=memory()
		local renderer=Renderer.attach(map,fixture)
		local pool=#map.root:GetDescendants()
		check(pool==before+96+#fixture.nodes*3 and pool<=600,"Fixed 96-image pool, reused badges and 600 map limit")
		check(map.root:GetAttribute("IllustratedActive")==false,"Native default")
		local cold=os.clock();renderer.setEnabled(true);ready(map)
		check(#renderer.entries()>0,"Initial activation draws at the existing camera without movement")
		print(string.format("[Illustrated real load] fixture=%d elapsed=%.3fms session=%s fetches=%d map=%d textureBefore=%s after=%s MiB; whole-client/cache unknown",fi,(os.clock()-cold)*1000,tostring(renderer.session.milliseconds()),renderer.session.fetchCount(),pool,tostring(mem),tostring(memory())))
		for _,probe in renderer.probes do check(probe.IsLoaded,"Actual approved probe loaded") end
		for _,image in renderer.images do if image.Visible then check(image.IsLoaded and image.BackgroundTransparency==1 and not image.Active and not image.Selectable,"Real decorative image ready/noninteractive") end end
		local function village(): boolean for _,e in renderer.entries() do if e.art=="village" then return true end end;return false end
		check(not village(),"No district houses before authoritative built flag")
		local district=fixture.nodes[4]
		map.linkFrames[3]:SetAttribute("PreviewOnly",false);app.mapController.locate(district.x,district.y);settle();ready(map)
		check(village(),"Built district uses existing settlement atlas")
		map.linkFrames[3]:SetAttribute("PreviewOnly",true);check(not village(),"Unbuilt fallback removes houses immediately")
		for _,size in {{1366,704},{768,960},{360,580},{640,300}} do
			app.view.root.Size=UDim2.fromOffset(size[1],size[2]);settle();app.mapController.recenter();settle()
			local id=fixture.nodes[1].id;app.selectAsset(id);app.mapController.locate(fixture.nodes[1].x,fixture.nodes[1].y);settle()
			local marker=map.markers[id]
			-- The mobile inspector is modal: preserve its close control, not an
			-- intentionally ineligible map button behind the sheet.
			local focus=if app.keyboard.valid(marker) then marker else app.view.inspector.close
			if focus==marker then Focus.reveal(app,marker) end
			check(app.keyboard.valid(focus),"Eligible focus in active responsive scope")
			Gui.SelectedObject=focus;settle()
			local x,y,z=map.root:GetAttribute("CameraX"),map.root:GetAttribute("CameraY"),map.root:GetAttribute("CameraZoom")
			local selected,inspector=app.state.selectedId,app.state.inspectorStage
			for _,mode in {false,true,false,true} do
				renderer.setEnabled(mode)
				check(map.root:GetAttribute("CameraX")==x and map.root:GetAttribute("CameraY")==y and map.root:GetAttribute("CameraZoom")==z,"Mode preserves camera")
				check(app.state.selectedId==selected and app.state.inspectorStage==inspector and Gui.SelectedObject==focus,"Mode preserves selection/inspector/focus")
			end
			for _,zoom in {.55,.72,1,1.2,1.8} do
				map.render(-50,-80,zoom);settle();ready(map)
				local expected,actual=0,0
				for _,e in renderer.descriptor.shores do
					if Geometry.intersects(-50+(e.x-32)*zoom,-80+(e.y-32)*zoom,64*zoom,64*zoom,map.viewport.AbsoluteSize.X,map.viewport.AbsoluteSize.Y,0) then expected+=1 end
				end
				for _,e in renderer.entries() do if string.sub(e.id,1,6)=="shore:" then actual+=1 end end
				check(actual==expected,"Complete visible shoreline; no omitted isolated pieces")
				for _,image in renderer.images do if image.Visible then
					local m=Catalog.motifs[image:GetAttribute("ArtId") :: string]
					check(math.abs(image.AbsoluteSize.X-m.size*zoom)<=1,"Single camera scale, no double zoom")
					check(image.Rotation==0 and image.ImageRectSize==Vector2.new(m.rect[3],m.rect[4]),"Unrotated atlas crop")
				end end
				check(marker.Size==UDim2.fromOffset(44,44),"44px hit target unchanged")
			end
			app.mapController.recenter();app.mapController.pan(25,-17);app.mapController.changeZoom(.15)
			check(#map.root:GetDescendants()==pool,"Resize/pan/zoom has no instance growth")
		end
		app.view.root.Size=UDim2.fromOffset(1366,704);settle();app.mapController.recenter();settle()
		for _,enabled in {false,true} do
			renderer.setEnabled(enabled);if enabled then ready(map) end
			local cpu,frames={},{}
			for i=1,180 do
				local t=os.clock();map.render(100+math.sin(i*.06)*80,-100+math.cos(i*.04)*50,.72);table.insert(cpu,(os.clock()-t)*1000)
				table.insert(frames,Run.RenderStepped:Wait()*1000)
			end
			table.sort(cpu);table.sort(frames)
			local record={fixture=fi,mode=if enabled then "Illustrated" else "Native",cpuP50=cpu[90],cpuP95=cpu[171],cpuWorst=cpu[180],frameP50=frames[90],frameP95=frames[171],frameWorst=frames[180],descendants=pool}
			table.insert(results,record);print("[Illustrated performance] "..game.HttpService:JSONEncode(record))
		end
		local old=renderer.images[1];renderer.destroy();check(old.Parent==nil and #map.root:GetDescendants()==before,"Pool cleanup")
		local failed=Renderer.attach(map,fixture,function(done: (boolean)->()) done(false);return function()end end)
		failed.setEnabled(true);check(map.root:GetAttribute("IllustratedActive")==false and map.root:GetAttribute("IllustratedLoadState")=="Failed","Synthetic denied/failed loader keeps Native")
		failed.destroy()
		local late: any=nil
		local delayed=Renderer.attach(map,fixture,function(done: (boolean)->())late=done;return function()end end)
		delayed.setEnabled(true);delayed.destroy();late(true)
		check(#map.root:GetDescendants()==before,"Late synthetic callback cannot resurrect a destroyed pool")
		if fi==1 then
			local timeout=Renderer.attach(map,fixture,function(done: (boolean)->())late=done;return function()end end)
			timeout.setEnabled(true);local deadline=os.clock()+6
			while timeout.session.state()=="Loading" and os.clock()<deadline do Run.RenderStepped:Wait() end
			timeout.redraw();late(true)
			check(timeout.session.state()=="TimedOut" and map.root:GetAttribute("IllustratedActive")==false,"Five-second synthetic timeout; late success rejected")
			timeout.destroy()
			local overloaded=game.HttpService:JSONDecode(game.HttpService:JSONEncode(fixture))
			for i,p in overloaded.world.samples do p.elevationM=if ((i-1)%17+math.floor((i-1)/17))%2==0 then 40 else -40 end
			local overflow=Renderer.attach(map,overloaded,function(done: (boolean)->())done(true);return function()end end)
			overflow.setEnabled(true);map.render(0,0,.55)
			check(map.root:GetAttribute("IllustratedLoadState")=="CoverageFallback" and #overflow.entries()==0,"Whole visible sector Native when shore pool overflows")
			overflow.destroy()
		end
		app.destroy()
	end
	print(string.format("[Illustrated engine] PASS %d assertions; actual four-atlas readiness and synthetic fault cases separately",count))
	return results
end
