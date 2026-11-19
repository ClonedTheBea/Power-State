--!strict
local Catalog = require(script.Parent.IllustratedAtlasCatalog)
local Descriptor = require(script.Parent.IllustratedSectorDescriptor)
local Session = require(script.Parent.IllustratedAtlasSession)
local Client = script.Parent.Parent.Parent.Client
local Geometry = require(Client.Views.Map.MapGeometry)
local Presentation = require(script.Parent.Parent.HybridPresentation)
local Renderer = {}
function Renderer.attach(map: any, preview: any, injected: any?)
	assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
	assert(#map.root:GetDescendants()+Catalog.POOL_SIZE+#preview.nodes*3<=600,"Illustrated pool and badges exceed map budget")
	local descriptor=Descriptor.create(preview.world,preview.nodes,preview.links)
	local images: {ImageLabel}={}
	local probes: {ImageLabel}={}
	for i=1,Catalog.POOL_SIZE do
		local image=Instance.new("ImageLabel")
		image.Name="IllustratedSlot"..i;image.BackgroundTransparency=1;image.BorderSizePixel=0
		image.Active=false;image.Selectable=false;image.Visible=false;image.ZIndex=2
		image.Parent=map.terrain.root
		if i<=Catalog.PROBES then
			image.Name="AtlasReadiness_"..Catalog.order[i];image.Image=Catalog.atlases[Catalog.order[i]]
			-- A fully transparent/offscreen label is culled before IsLoaded becomes
			-- true. Four near-transparent screen-space pixels warm the real textures.
			image.Parent=map.viewport;image.Position=UDim2.fromScale(.5,.5)
			image.Size=UDim2.fromOffset(1,1);image.ImageTransparency=.999;image.Visible=true
			table.insert(probes,image)
		else table.insert(images,image) end
	end
	local session=Session.create(probes,injected)
	local presentation=Presentation.attach(map,#preview.nodes)
	local original=map.terrain.render
	local enabled=false;local destroyed=false
	local labelDeadline=0;local labelFailed=false
	-- Attach to the already-framed camera; enabling art must not require a pan.
	local lastX=(map.root:GetAttribute("CameraX") or 0) :: number
	local lastY=(map.root:GetAttribute("CameraY") or 0) :: number
	local lastZoom=(map.root:GetAttribute("CameraZoom") or 1) :: number
	local lastSize: Vector2=map.viewport.AbsoluteSize
	local activeEntries: {Descriptor.Entry}={}
	local function eligible(entry: Descriptor.Entry): boolean
		if entry.link then return map.linkFrames[entry.link]:GetAttribute("PreviewOnly")~=true end
		if entry.preview then
			for i,link in preview.links do if link.to==entry.node then return map.linkFrames[i]:GetAttribute("PreviewOnly")==false end end
			return false
		end
		return true
	end
	local function visible(entry: Descriptor.Entry): boolean
		local m=Catalog.motifs[entry.art]
		local x=entry.x-m.pivot[1]*m.size/m.rect[3]
		local y=entry.y-m.pivot[2]*m.size/m.rect[4]
		return Geometry.intersects(lastX+x*lastZoom,lastY+y*lastZoom,m.size*lastZoom,m.size*lastZoom,lastSize.X,lastSize.Y,0)
	end
	local function draw()
		if destroyed then return end
		local state=session.state()
		if labelFailed then state="LabelTimedOut" end
		local ready=enabled and state=="Ready"
		local entries: {Descriptor.Entry}={}
		if ready then
			for _,e in descriptor.shores do if visible(e) then table.insert(entries,e) end end
			if #entries>#images then ready=false;state="CoverageFallback"
			else
				for _,group in {descriptor.assets,descriptor.decorations} do for _,e in group do
					if #entries<#images and eligible(e) and visible(e) then table.insert(entries,e) end
				end end
			end
		end
		for i,image in images do
			local e=entries[i]
			if e and ready then
				local m=Catalog.motifs[e.art];local r=m.rect
				image.Image=Catalog.atlases[m.atlas];image.ImageRectOffset=Vector2.new(r[1],r[2]);image.ImageRectSize=Vector2.new(r[3],r[4])
				image.Position=UDim2.fromOffset(e.x-m.pivot[1]*m.size/r[3],e.y-m.pivot[2]*m.size/r[4])
				image.Size=UDim2.fromOffset(m.size,m.size);image.Rotation=0
				image:SetAttribute("ArtId",e.art);image:SetAttribute("EntryId",e.id)
				-- Catalog readiness alone cannot guarantee a newly assigned label is ready.
				if not injected and not image.IsLoaded then state="LabelLoading" end
			end
		end
		if state=="LabelLoading" then
			ready=false
			if labelDeadline==0 then labelDeadline=os.clock()+5 end
			if os.clock()>=labelDeadline then labelFailed=true;state="LabelTimedOut" end
		else labelDeadline=0 end
		for i,image in images do
			image.Visible=i<=#entries and (ready or state=="LabelLoading")
			image.ImageTransparency=if ready then 0 else .999
		end
		activeEntries=if ready then entries else {}
		map.root:SetAttribute("IllustratedMode",if enabled then "Illustrated (Experimental)" else "Native")
		map.root:SetAttribute("IllustratedLoadState",state)
		map.root:SetAttribute("IllustratedActive",ready)
		map.root:SetAttribute("IllustratedVisibleSlots",#activeEntries)
		map.root:SetAttribute("IllustratedShoreCount",#descriptor.shores)
		map.root:SetAttribute("ProofMode",if ready then "Hybrid" else "Native")
		map.root:SetAttribute("ProofLoadState",if ready then "Ready" else state)
	end
	map.terrain.render=function(x: number,y: number,z: number,size: Vector2)
		original(x,y,z,size);lastX=x;lastY=y;lastZoom=z;lastSize=size;draw()
	end
	local connections: {RBXScriptConnection}={}
	-- Readiness wakes rendering without camera movement. No new instances or downloads.
	local beat=game:GetService("RunService").Heartbeat:Connect(function()
		local state=map.root:GetAttribute("IllustratedLoadState")
		if enabled and (state=="Loading" or state=="LabelLoading") then draw() end
	end)
	for _,line in map.linkFrames do table.insert(connections,line:GetAttributeChangedSignal("PreviewOnly"):Connect(draw)) end
	local function destroy()
		if destroyed then return end;destroyed=true
		beat:Disconnect();for _,c in connections do c:Disconnect() end
		map.terrain.render=original;session.destroy();presentation.destroy()
		for _,im in images do im:Destroy() end;for _,im in probes do im:Destroy() end
	end
	table.insert(connections,map.root.Destroying:Connect(destroy))
	draw()
	return {setEnabled=function(value: boolean) enabled=value;if value then session.start() end;draw() end,
		destroy=destroy,descriptor=descriptor,images=images,probes=probes,session=session,
		entries=function() return activeEntries end,redraw=draw}
end
return table.freeze(Renderer)
