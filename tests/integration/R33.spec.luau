--!strict
return function(playerGui: PlayerGui)
	local Client=script.Parent.Parent.Client
	local App=require(Client.Controllers.AppController)
	local Manifest=require(Client.Views.Map.SpriteManifest)
	local Loader=require(Client.Views.Map.SpriteAtlasLoader)
	local Renderer=require(Client.Views.Map.SpriteTerrainRenderer)
	local Preview=require(Client.PreviewData)
	local RunService=game:GetService("RunService")
	local count=0
	local function check(value: boolean, message: string) assert(value,message);count+=1 end
	local function settle() for _=1,4 do RunService.RenderStepped:Wait() end end
	local function copy()
		local result={}
		for _,e in Manifest.entries do local clone=table.clone(e);clone.rect=table.clone(e.rect);clone.cell=table.clone(e.cell);table.insert(result,clone) end
		return result
	end
	check(Manifest.validate(Manifest.entries,3),"Approved atlas descriptors valid")
	for _,kind in {"zero","bounds","overlap","pivot","nan","identity","revision","aspect","gutter"} do
		local bad=copy()
		if kind=="zero" then bad[1].rect[3]=0
		elseif kind=="bounds" then bad[1].cell[1]=1024
		elseif kind=="overlap" then bad[2].cell=table.clone(bad[1].cell)
		elseif kind=="pivot" then bad[1].pivot=Vector2.new(497,248)
		elseif kind=="nan" then bad[1].anchor=Vector2.new(0/0,0)
		elseif kind=="identity" then bad[2].id=bad[1].id
		elseif kind=="revision" then bad[1].revision=99
		elseif kind=="aspect" then bad[1].world=Vector2.new(200,248)
		else bad[1].rect[1]=0 end
		check(not Manifest.validate(bad,3),"Reject "..kind)
	end
	check(not Manifest.validate(Manifest.entries,4),"Unknown atlas revision rejected")
	for _,z in {.55,.72,1,1.2,1.8} do for _,e in Manifest.entries do
		local p=Manifest.position(e)
		local pivot=Vector2.new(e.pivot.X*e.world.X/e.rect[3],e.pivot.Y*e.world.Y/e.rect[4])
		check(((p+pivot)*z-e.anchor*z).Magnitude<.001,"World pivot round-trip")
	end end
	-- Deterministic synthetic fault injection. No network request or image ID.
	for _,scenario in {"ready","failed","denied","delayed","timeout","cancel","destroy","throw"} do
		local time=0;local calls=0;local releases=0
		local callback: ((boolean)->())?=nil
		local loader=Loader.new(function(done)
			calls+=1;callback=done
			if scenario=="throw" then error("Injected fetch error") end
			return function() releases+=1 end
		end,function() return time end)
		loader.start();loader.start()
		check(calls==1,"One attempt per mount")
		local complete=callback;assert(complete)
		if scenario=="timeout" then time=6;check(loader.state()=="TimedOut","Timeout retains fallback");complete(true)
		elseif scenario=="cancel" then loader.cancelPending();complete(true)
		elseif scenario=="destroy" then loader.destroy();complete(true)
		elseif scenario=="throw" then complete(true)
		else if scenario=="delayed" then time=2;check(loader.state()=="Loading","Delayed remains native") end
			complete(scenario=="ready" or scenario=="delayed")
		end
		local expected=if scenario=="timeout" then "TimedOut" elseif scenario=="cancel" then "Cancelled" elseif scenario=="destroy" then "Destroyed" elseif scenario=="ready" or scenario=="delayed" then "Ready" else "Failed"
		check(loader.state()==expected,"Safe terminal state: "..scenario)
		loader.destroy();loader.destroy()
		check(releases==(if scenario=="throw" then 0 else 1),"Request cleanup exactly once")
	end
	local missing=Loader.new(nil);missing.start();check(missing.state()=="Unconfigured","No hosted atlas means unconfigured");missing.destroy()
	local existing=playerGui:FindFirstChild("PowerStateShell");if existing then existing:Destroy() end
	local app=App.mount(playerGui)
	-- Retain cleanup across assertion failures.
	local cleanup: (() -> ())?=nil
	local ok,problem=xpcall(function()
		settle()
		local map=app.view.map
		local baseline=#map.root:GetDescendants()
		local originalRender=map.terrain.render
		local function mount(request: Loader.Request?)
			local instance=Renderer.attach(map.root,map.terrain,request)
			cleanup=instance.destroy
			return instance
		end
		local unconfigured=mount(nil);unconfigured.setMode("Hybrid")
		check(map.root:GetAttribute("ProofLoadState")=="Unconfigured","Unconfigured proof retains native")
		for _,image in unconfigured.images do check(not image.Visible and image.Image=="","No unrelated texture") end
		unconfigured.destroy()
		local now=0
		local late: ((boolean)->())?=nil
		local pending=Renderer.attach(map.root,map.terrain,function(done) late=done;return function() end end,function() return now end)
		cleanup=pending.destroy;pending.setMode("Hybrid")
		check(map.root:GetAttribute("ProofLoadState")=="Loading","Loading renders native immediately")
		for _,image in pending.images do check(not image.Visible,"No blank replacement while loading") end
		now=6;pending.refresh()
		check(map.root:GetAttribute("ProofLoadState")=="TimedOut","Renderer timeout keeps native")
		local resolve=late;assert(resolve);resolve(true);pending.refresh()
		check(map.root:GetAttribute("ProofLoadState")=="TimedOut","Late ready cannot hide fallback")
		pending.destroy();resolve(true)
		check(#map.root:GetDescendants()==baseline,"Late completion after destroy allocates nothing")
		for _,result in {false,true} do
			local test=mount(function(done) done(result);return function() end end)
			test.setMode("Hybrid")
			check(map.root:GetAttribute("ProofLoadState")== (if result then "Ready" else "Failed"),"Synchronous loader terminal state")
			for _,entry in ipairs(map.terrain.entries) do if entry.patch.id==Manifest.entries[1].patchId then
				if result then check(not entry.root.Visible,"Hybrid suppresses meadow bundle") end
			end end
			test.destroy()
		end
		local test=mount(function(done) done(true);return function() end end)
		check(#test.images==6 and #map.root:GetDescendants()==baseline+6,"Exactly six pooled instances")
		check(#map.root:GetDescendants()<=600,"Hybrid remains below hard map budget")
		print(string.format("[R3.3 SYNTHETIC counts] native %d / proof %d map descendants; shell %d",baseline,#map.root:GetDescendants(),#app.view.gui:GetDescendants()))
		check(map.root:GetAttribute("ProofMode")=="Native","Native remains default")
		for _,entry in ipairs(map.terrain.entries) do check(entry.root.ZIndex>test.images[1].ZIndex,"Coast beneath every native meadow") end
		for _,shore in ipairs(map.terrain.shores) do check(shore.root.ZIndex<test.images[1].ZIndex,"Coast in shore/base pass") end
		for _,image in test.images do check(not image.Active and not image.Selectable and image.Image=="","Noninteractive synthetic bounds, no texture") end
		local pool=#app.view.gui:GetDescendants()
		for _,dimensions in {{360,580},{640,300},{768,960},{1024,708},{1366,704},{1920,1020}} do
			app.view.root.Size=UDim2.fromOffset(dimensions[1],dimensions[2]);settle()
			app.mapController.recenter();app.selectAsset("station");settle()
			local x,y,z=map.root:GetAttribute("CameraX"),map.root:GetAttribute("CameraY"),map.root:GetAttribute("CameraZoom")
			local inspector=app.state.inspectorStage
			for _,mode in {"Hybrid","Native","Hybrid"} do
				test.setMode(mode)
				check(map.root:GetAttribute("CameraX")==x and map.root:GetAttribute("CameraY")==y and map.root:GetAttribute("CameraZoom")==z,"Mode switch preserves camera")
				check(app.state.selectedId=="station" and app.state.inspectorStage==inspector,"Mode switch preserves selection/inspector")
			end
			for _,zoom in {.55,.72,1,1.2,1.8} do
				map.render(-50,-80,zoom)
				for i,image in test.images do local e=Manifest.entries[i];local p=Manifest.position(e)
					check(math.abs(image.Position.X.Scale*1200-p.X)<.001 and math.abs(image.Position.Y.Scale*800-p.Y)<.001,"Stable subpixel world sprite position")
					check(image.Size.X.Offset==e.world.X and image.Size.Y.Offset==e.world.Y,"World sprite dimensions")
				end
				local scale=map.terrain.root:FindFirstChildOfClass("UIScale");assert(scale)
				check(math.abs(scale.Scale-zoom)<.000001,"One shared scale, no double zoom (float property tolerance)")
				for _,node in Preview.nodes do local marker=map.markers[node.id]
					check(math.abs(marker.Position.X.Offset-(-50+node.x*zoom))<1.01 and marker.Size.X.Offset==44,"Native asset coordinate and hit target unchanged (integer offset rounding)")
				end
			end
			map.setOptions(false,false);test.setMode("Native");test.setMode("Hybrid")
			check(map.root:GetAttribute("LabelsVisible")==false and map.root:GetAttribute("LinksVisible")==false,"Layer toggles retained")
			map.setOptions(true,true)
			check(#app.view.gui:GetDescendants()==pool,"Resize/render/mode switches allocate nothing")
		end
		map.render(-5000,-5000,1)
		for _,image in test.images do check(not image.Visible,"Full sprite bounds culled") end
		test.setMode("Native");check(map.terrain.root:GetAttribute("VisiblePatches")==0,"Fallback respects culling")
		-- Three matched warm CPU property-update passes; no texture/GPU/memory claim.
		for _,dimensions in {{360,580},{1366,704}} do
			app.view.root.Size=UDim2.fromOffset(dimensions[1],dimensions[2]);settle()
			for pass=1,3 do for _,mode in {"Native","Hybrid"} do
				test.setMode(mode);local times: {number}={}
				for i=1,360 do local start=os.clock();map.render(-(i%350),-(i%150),.55+(i%125)/100);table.insert(times,(os.clock()-start)*1000) end
				table.sort(times)
				local frames: {number}={}
				for i=1,120 do app.mapController.pan(if i%2==0 then 15 else -15,0);app.mapController.changeZoom(if i%2==0 then .03 else -.03);table.insert(frames,RunService.RenderStepped:Wait()*1000) end
				table.sort(frames)
				print(string.format("[R3.3 SYNTHETIC] %s %dx%d pass %d draw p50/p95 %.3f/%.3f ms; frame %.2f/%.2f ms",mode,dimensions[1],dimensions[2],pass,times[180],times[342],frames[60],frames[114]))
				check(#app.view.gui:GetDescendants()==pool,"Benchmark no instance growth")
			end end
		end
		test.destroy();test.destroy()
		check(#map.root:GetDescendants()==baseline and map.terrain.render==originalRender,"Destroy restores pool and render function")
		for _=1,3 do local remount=mount(nil);remount.destroy();check(#map.root:GetDescendants()==baseline,"Repeated remount releases instances") end
		local bad=copy();bad[1].rect[3]=0
		local invalid=Renderer.attach(map.root,map.terrain,nil,nil,bad);cleanup=invalid.destroy;invalid.setMode("Hybrid")
		check(#invalid.images==0 and map.root:GetAttribute("ProofLoadState")=="InvalidManifest","Invalid manifest fails closed without allocation")
		invalid.destroy()
	end,function(message: unknown): string return debug.traceback(tostring(message)) end)
	if cleanup then cleanup() end
	app.destroy();App.mount(playerGui)
	assert(ok,tostring(problem))
	print(string.format("[Power State R3.3] PASS: %d synthetic assertions; no atlas fetched",count))
	return count
end
