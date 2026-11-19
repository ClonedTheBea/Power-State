--!strict
return function(playerGui: PlayerGui)
	local Atlas = require(script.Parent.RealAtlas)
	Atlas.assertEnvironment()
	local Proof = require(script.Parent.HybridProof)
	local RunService = game:GetService("RunService")
	local Stats = game:GetService("Stats")
	local count = 0
	local function check(value: boolean, message: string) assert(value,message); count += 1 end
	local function settle() for _=1,4 do RunService.RenderStepped:Wait() end end
	local function textureMemory(): number?
		local ok,value=pcall(function() return Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.GraphicsTexture) end)
		return if ok then value else nil
	end
	local existing=playerGui:FindFirstChild("PowerStateShell"); if existing then existing:Destroy() end
	-- Approved dashboard revisions add pooled detail rows outside the map. Check
	-- the exact six-sprite delta against the current Native shell, not the old chrome.
	local native=require(script.Parent.Parent.Client.Controllers.AppController).mount(playerGui)
	local nativeShellCount=#native.view.gui:GetDescendants()
	check(#native.view.map.root:GetDescendants()==574,"Unchanged Native map baseline")
	native.destroy()
	local memoryBefore=textureMemory()
	local mounted=Proof.mount(playerGui,"real",false)
	local app,proof=mounted.app,mounted.proof
	local map=app.view.map
	local ok,problem=xpcall(function()
		settle()
		check(map.root:GetAttribute("ProofMode")=="Native","Default stays Native")
		local started=os.clock();proof.setMode("Hybrid")
		while proof.state()=="Loading" and os.clock()-started<6 do RunService.RenderStepped:Wait() end
		proof.refresh()
		print(string.format("[R3.4 REAL readiness] state=%s elapsed=%.3f ms; GraphicsTexture before=%s after=%s MiB (whole client, not atlas-only)",proof.state(),(os.clock()-started)*1000,tostring(memoryBefore),tostring(textureMemory())))
		check(proof.state()=="Ready","Approved Restricted atlas unavailable: stop, do not change permissions")
		check(map.root:GetAttribute("ProofSynthetic")==false,"Actual texture is not labelled synthetic")
		for _,image in proof.images do
			check(image.IsLoaded and image.Image==Atlas.URI,"Each real sprite image ready")
			check(image.BackgroundTransparency==1 and not image.Active and not image.Selectable,"Transparent noninteractive art")
		end
		local pool=#app.view.gui:GetDescendants()
		check(#proof.images==6 and #map.root:GetDescendants()==580 and pool==nativeShellCount+6,"Exact six-image addition; unchanged map bound")
		for _,size in {{360,580},{640,300},{768,960},{1024,708},{1366,704},{1920,1020}} do
			app.view.root.Size=UDim2.fromOffset(size[1],size[2]);settle()
			app.mapController.recenter();app.selectAsset("station");settle()
			local x,y,z=map.root:GetAttribute("CameraX"),map.root:GetAttribute("CameraY"),map.root:GetAttribute("CameraZoom")
			local inspector=app.state.inspectorStage
			for _,mode in {"Native","Hybrid"} do
				proof.setMode(mode)
				check(map.root:GetAttribute("CameraX")==x and map.root:GetAttribute("CameraY")==y and map.root:GetAttribute("CameraZoom")==z,"Real mode switch preserves camera")
				check(app.state.selectedId=="station" and app.state.inspectorStage==inspector,"Real mode switch preserves inspector")
			end
			for _,zoom in {.55,.72,1,1.2,1.8} do map.render(-50,-80,zoom);settle()
				for _,image in proof.images do check(image.IsLoaded,"Texture retained at supported zoom") end
			end
			map.setOptions(false,false);proof.setMode("Native");proof.setMode("Hybrid")
			check(map.root:GetAttribute("LabelsVisible")==false and map.root:GetAttribute("LinksVisible")==false,"Layer state retained")
			map.setOptions(true,true)
			check(#app.view.gui:GetDescendants()==pool,"Real resize does not grow pool")
		end
		-- Local readiness loss, without another URI or a permission change.
		local first=proof.images[1]; first.Image=""; proof.refresh()
		check(map.root:GetAttribute("ProofLoadState")=="ImageUnavailable","Readiness loss restores fallback")
		for _,image in proof.images do check(image.ZIndex==0,"Readiness loss puts all sprites beneath native fallback") end
		first.Image=Atlas.URI
		local recovery=os.clock()
		while not first.IsLoaded and os.clock()-recovery<5 do RunService.RenderStepped:Wait() end
		proof.refresh();check(map.root:GetAttribute("ProofLoadState")=="Ready","Approved cached atlas recovers")
		for _,size in {{360,580},{768,960},{1366,704}} do
			app.view.root.Size=UDim2.fromOffset(size[1],size[2]);settle()
			for pass=1,3 do for _,mode in {"Native","Hybrid"} do
				app.mapController.recenter();proof.setMode(mode);settle()
				local times: {number}={}
				for i=1,360 do local start=os.clock();map.render(-(i%350),-(i%150),.55+(i%125)/100);table.insert(times,(os.clock()-start)*1000) end
				table.sort(times)
				app.mapController.recenter();settle()
				local frames: {number}={}
				for i=1,120 do app.mapController.pan(if i%2==0 then 15 else -15,0);app.mapController.changeZoom(if i%2==0 then .03 else -.03);table.insert(frames,RunService.RenderStepped:Wait()*1000) end
				table.sort(frames)
				print(string.format("[R3.4 REAL benchmark] %s %dx%d pass %d draw p50/p95 %.3f/%.3f ms; frame %.2f/%.2f ms",mode,size[1],size[2],pass,times[180],times[342],frames[60],frames[114]))
				check(#app.view.gui:GetDescendants()==pool,"Benchmark stable pool")
			end end
		end
		local soakStart=os.clock();local cycles=0
		while os.clock()-soakStart<600 do
			cycles+=1
			local sizes={{360,580},{640,300},{768,960},{1024,708},{1366,704},{1920,1020}}
			local size=sizes[(cycles-1)%#sizes+1]
			app.view.root.Size=UDim2.fromOffset(size[1],size[2])
			app.selectAsset(if cycles%2==0 then "station" else "capital")
			app.mapController.changeZoom(if cycles%2==0 then .15 else -.15)
			app.mapController.pan(if cycles%2==0 then 60 else -60,20)
			proof.setMode(if cycles%4==0 then "Native" else "Hybrid")
			task.wait(1)
			assert(#app.view.gui:GetDescendants()==pool and proof.state()=="Ready","Real soak pool/readiness changed")
			assert(app.state.selectedId~=nil,"Real soak lost selection")
			if cycles%60==0 then print("[R3.4 REAL soak] "..cycles.." cycles; pool/readiness stable") end
		end
		print(string.format("[R3.4 REAL soak] PASS %.1f seconds / %d cycles / %d descendants",os.clock()-soakStart,cycles,pool))
	end,function(message: unknown): string return debug.traceback(tostring(message)) end)
	mounted.destroy()
	if not ok then
		-- A validation failure must not leave the test player with a blank GUI.
		require(script.Parent.Parent.Client.Controllers.AppController).mount(playerGui)
	end
	assert(ok,tostring(problem))
	-- Remount exercises fresh load lifecycle; leave a usable comparison shell for review.
	local review=Proof.mount(playerGui,"real")
	review.proof.setMode("Hybrid");local retry=os.clock()
	while review.proof.state()=="Loading" and os.clock()-retry<6 do RunService.RenderStepped:Wait() end
	check(review.proof.state()=="Ready","Real remount loads safely")
	review.proof.setMode("Native")
	print(string.format("[Power State R3.4] PASS: %d real-texture assertions",count))
	return count
end
