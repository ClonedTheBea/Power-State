--!strict
return function(playerGui:PlayerGui)
	local RunService=game:GetService("RunService")
	local GuiService=game:GetService("GuiService")
	local Proof=require(script.Parent.SettlementProof)
	local Profiles=require(script.Parent.SettlementProfiles)
	local Manifest=require(script.Parent.Parent.Client.Views.Map.SpriteManifest)
	local Fixture=require(script.Parent.Parent.Client.Views.Map.MapFixture)
	local Geometry=require(script.Parent.Parent.Client.Views.Map.MapGeometry)
	local App=require(script.Parent.Parent.Client.Controllers.AppController)
	local Renderer=require(script.Parent.SettlementRenderer)
	local count=0
	local function check(ok:boolean,message:string) assert(ok,message);count+=1 end
	local function settle() for _=1,4 do RunService.RenderStepped:Wait() end end
	local existing=playerGui:FindFirstChild("PowerStateShell");if existing then existing:Destroy() end
	local mounted=Proof.mount(playerGui)
	local app,proof=mounted.app,mounted.proof
	local map=app.view.map
	local function waitReady()
		local start=os.clock()
		while proof.state()=="Loading" and os.clock()-start<6 do RunService.RenderStepped:Wait() end
		proof.refresh();settle()
		check(map.root:GetAttribute("ProofLoadState")=="Ready","Real profile readiness")
	end
	local ok,problem=xpcall(function()
		settle();proof.setMode("Hybrid");waitReady()
		local pool=#map.root:GetDescendants()
		check(pool==595 and #proof.images==6,"Exactly six reusable labels; 595 descendants")
		check(proof.fetchCount()==1,"Original atlas is preloaded once")
		local identities=table.clone(proof.images)
		check(not pcall(Profiles.get,"Unknown"),"Unknown profile rejected")
		for _,size in {{1366,704},{360,580},{640,300},{768,960}} do
			app.view.root.Size=UDim2.fromOffset(size[1],size[2]);settle();app.mapController.recenter()
			for _,name in {"Settlements","Original","Settlements"} do
				app.selectAsset("south");settle()
				local x,y,z=map.root:GetAttribute("CameraX"),map.root:GetAttribute("CameraY"),map.root:GetAttribute("CameraZoom")
				local inspector=app.state.inspectorStage
				proof.setProfile(name);waitReady()
				check(app.state.selectedId=="south" and app.state.inspectorStage==inspector,"Profile preserves selected asset/inspector")
				check(map.root:GetAttribute("CameraX")==x and map.root:GetAttribute("CameraY")==y and map.root:GetAttribute("CameraZoom")==z,"Profile preserves camera")
				for i,image in proof.images do
					check(image==identities[i] and image.IsLoaded and image.Image==Profiles.uri(name,i),"Same live label / correct atlas")
				end
				for _,zoom in {.55,.72,1,1.2,1.8} do
					map.render(-40,-50,zoom);settle()
					for i,e in Profiles.get(name) do
						local image=proof.images[i];local p=Manifest.position(e)
						check(math.abs(image.Position.X.Scale*1200-p.X)<.001 and math.abs(image.Position.Y.Scale*800-p.Y)<.001,"Stable world pivot")
						check(image.ImageRectOffset==Vector2.new(e.rect[1],e.rect[2]) and image.ImageRectSize==Vector2.new(e.rect[3],e.rect[4]),"Approved atlas rectangle")
						check(math.abs(image.AbsoluteSize.X-e.world.X*zoom)<2,"Single camera scale")
					end
				end
				for _,entry in ipairs(map.terrain.entries) do
					local id=entry.patch.id
					if id=="art1:0:0:wood-west" or id=="art1:0:0:fields" then
						local p=entry.patch :: Fixture.Patch
						local visible=Geometry.intersects(-40+p.x*1.8,-50+p.y*1.8,p.width*1.8,p.height*1.8,map.viewport.AbsoluteSize.X,map.viewport.AbsoluteSize.Y,64*1.8)
						check(entry.root.Visible==(name=="Settlements" and visible),"Displaced forest/fields restore native with culling")
					end
					if id=="art1:0:0:southbank" or id=="art1:0:0:eastmere" then
						if name=="Settlements" then check(not entry.root.Visible,"Settlement replaces native bundle") end
					end
				end
				for _,id in {"south","east"} do
					app.selectAsset(id);settle();app.actions[app.view.inspector.locate]();settle()
					local marker=map.markers[id]
					check(marker.Visible and marker.Size==UDim2.fromOffset(44,44) and marker.Selectable,"Locate retains accessible 44px target")
					check(app.state.selectedId==id and app.mapController.actions[marker]~=nil,"Existing selection/input binding")
					-- A mobile inspector sheet intentionally owns focus while covering the map.
					app.actions[app.view.inspector.close]();settle()
					app.mapController.locate(if id=="south" then 665 else 930,if id=="south" then 535 else 455);settle()
					local p,s=marker.AbsolutePosition,marker.AbsoluteSize
					local physical=app.view.gui.AbsoluteSize
					if app.keyboard.valid(marker) and p.X>=0 and p.Y>=0 and p.X+s.X<=physical.X and p.Y+s.Y<=physical.Y then
						GuiService.SelectedObject=marker;settle()
						check(GuiService.SelectedObject==marker,"Original on-screen focus target")
					else
						-- A virtual 960px safe root can extend below the real Studio viewport.
						-- Do not pretend offscreen engine focus is an emulator/hardware result.
						check(marker.Selectable and marker.SelectionImageObject~=nil and marker:GetAttribute("AccessibleLabel")~=nil,"Virtual-size accessible target contract")
					end
				end
				GuiService.SelectedObject=nil
				proof.setMode("Native");check(not map.root:GetAttribute("CohesionActive"),"Native badges restored")
				proof.setMode("Hybrid");waitReady()
				check(app.state.selectedId=="east","Mode preserves selection")
				app.mapController.recenter();check(app.state.selectedId=="east","Recenter preserves selection")
			end
			check(#map.root:GetDescendants()==pool,"Resize/profile switches have no instance growth")
			check(proof.fetchCount()==2,"Profile changes reuse at most two atlas preload operations")
		end
		app.view.root.Size=UDim2.fromOffset(1366,704);settle();map.render(0,0,.55)
		settle()
		local focusTarget=require(script.Parent.FocusTarget)
		local south=map.markers.south
		print("[R37 focus before] marker="..tostring(south.AbsolutePosition).." gui="..tostring(app.view.gui.AbsoluteSize).." mounted="..tostring(south:IsDescendantOf(playerGui)))
		if not focusTarget.onScreen(app.view.gui,south) then
			-- Retain minimum zoom: this direct-render label probe may translate
			-- its fixture into the actual host screen, not outside engine bounds.
			map.render(0,app.view.gui.AbsoluteSize.Y/2-south.AbsolutePosition.Y,.55);settle()
		end
		check(focusTarget.onScreen(app.view.gui,south) and app.keyboard.valid(south),"Minimum-zoom focus target is actually on screen")
		GuiService.SelectedObject=map.markers.south;settle()
		check(GuiService.SelectedObject==south,"Minimum-zoom engine focus retained")
		print("[R37 focus after] marker="..tostring(south.AbsolutePosition).." same="..tostring(south==map.markers.south).." focused="..tostring(GuiService.SelectedObject==south))
		local label=(map.viewport:FindFirstChild("MapLabels") :: Frame):FindFirstChild("Name_south") :: TextLabel
		check(label.Visible,"Contextual focus name at minimum zoom")
		map.setOptions(false,true);check(not label.Visible,"Label toggle survives profiles");map.setOptions(true,true)
		GuiService.SelectedObject=nil
		map.render(-5000,-5000,1)
		for _,image in proof.images do check(not image.Visible,"Offscreen sprites culled") end
		app.mapController.recenter()
		local uri=proof.images[3].Image;proof.images[3].Image="";proof.refresh()
		check(map.root:GetAttribute("ProofLoadState")=="ImageUnavailable" and not map.root:GetAttribute("CohesionActive"),"Real label readiness loss restores native")
		for _,image in proof.images do check(image.ZIndex==0,"Failed artwork stays beneath native") end
		proof.images[3].Image=uri
		local recovery=os.clock();while not proof.images[3].IsLoaded and os.clock()-recovery<5 do RunService.RenderStepped:Wait() end
		proof.refresh();waitReady()
		for _,size in {{360,580},{1366,704}} do
			app.view.root.Size=UDim2.fromOffset(size[1],size[2]);settle()
			for _,variant in {"Native","Original","Settlements"} do
				if variant=="Native" then proof.setMode("Native") else proof.setProfile(variant);proof.setMode("Hybrid");waitReady() end
				local times:{number}={};local frames:{number}={}
				for i=1,360 do local start=os.clock();map.render(-(i%350),-(i%150),.55+(i%125)/100);table.insert(times,(os.clock()-start)*1000) end
				app.mapController.recenter()
				for i=1,120 do app.mapController.pan(if i%2==0 then 15 else -15,0);app.mapController.changeZoom(if i%2==0 then .03 else -.03);table.insert(frames,RunService.RenderStepped:Wait()*1000) end
				table.sort(times);table.sort(frames)
				print(string.format("[R3.7 benchmark] %s %dx%d draw p50/p95 %.3f/%.3f ms; frame %.2f/%.2f ms; map %d",variant,size[1],size[2],times[180],times[342],frames[60],frames[114],#map.root:GetDescendants()))
				check(#map.root:GetDescendants()==pool,"Movement stable pool")
			end
		end
		local start=os.clock();local cycles=0
		while os.clock()-start<600 do
			cycles+=1
			app.view.root.Size=if cycles%2==0 then UDim2.fromOffset(360,580) else UDim2.fromOffset(1366,704)
			app.selectAsset(if cycles%2==0 then "south" else "east")
			app.mapController.pan(if cycles%2==0 then 35 else -35,10)
			app.mapController.changeZoom(if cycles%2==0 then .04 else -.04)
			if cycles%30==0 then proof.setProfile(if cycles%60==0 then "Settlements" else "Original");waitReady() end
			if cycles%10==0 then proof.setMode("Native");proof.setMode("Hybrid") end
			task.wait(1)
			assert(#map.root:GetDescendants()==pool and map.root:GetAttribute("ProofLoadState")=="Ready","Soak pool/readiness changed")
			assert(app.state.selectedId~=nil,"Soak lost selection")
			if cycles%60==0 then print("[R3.7 soak] "..cycles.." cycles / stable 595") end
		end
		print(string.format("[R3.7 soak] PASS %.1f seconds / %d cycles / %d map descendants",os.clock()-start,cycles,pool))
	end,function(message:unknown):string return debug.traceback(tostring(message)) end)
	GuiService.SelectedObject=nil;mounted.destroy()
	check(not playerGui:FindFirstChild("PowerStateShell"),"Shell cleanup")
	if not ok then App.mount(playerGui);error(tostring(problem)) end
	-- Synthetic fault/cancellation checks, using no invented image URI.
	local app2=App.mount(playerGui)
	local late:((boolean)->())?=nil
	local cancelled=0
	local fake=Renderer.attach(app2.view.map.root,app2.view.map.terrain,function(_images, _profile)
		return function(done) late=done;return function() cancelled+=1 end end
	end)
	fake.setMode("Hybrid");local old=late;fake.setProfile("Settlements")
	if old then old(true) end
	check(fake.state()=="Loading" and cancelled==1,"Late old-profile callback ignored")
	local deny=late;if deny then deny(false) end
	fake.refresh();check(app2.view.map.root:GetAttribute("ProofLoadState")=="Failed","Synthetic denial retains native")
	fake.setProfile("Original");local deadline=os.clock()
	while fake.state()=="Loading" and os.clock()-deadline<6 do RunService.RenderStepped:Wait() end
	check(fake.state()=="TimedOut","Synthetic delay is bounded")
	fake.destroy();local stale=late;if stale then stale(true) end
	check(#app2.view.map.root:GetDescendants()==574,"Renderer cleanup returns native count")
	app2.destroy()
	local review=Proof.mount(playerGui);review.proof.setProfile("Settlements");review.proof.setMode("Hybrid")
	local retry=os.clock();while review.proof.state()=="Loading" and os.clock()-retry<6 do RunService.RenderStepped:Wait() end
	check(review.proof.state()=="Ready","Real remount readiness")
	review.destroy();App.mount(playerGui)
	print(string.format("[Power State R3.7] PASS: %d assertions (real profile plus labelled synthetic faults)",count))
	return count
end
