--!strict
-- Isolated two-atlas proof. Never mounted alongside the original six-label renderer.
local RunService=game:GetService("RunService")
local Client=script.Parent.Parent.Client
local Manifest=require(Client.Views.Map.SpriteManifest)
local Geometry=require(Client.Views.Map.MapGeometry)
local Loader=require(Client.Views.Map.SpriteAtlasLoader)
local Fixture=require(Client.Views.Map.MapFixture)
local Profiles=require(script.Parent.SettlementProfiles)
local Atlas=require(script.Parent.SettlementAtlas)
type Native={root:Frame,entries:{{root:Frame,detail:Frame,patch:Fixture.Patch}},setReplacements:({[string]:boolean})->(),render:(number,number,number,Vector2)->()}
local Renderer={}
function Renderer.attach(mapRoot:Frame,terrain:Native,requestOverride: (({ImageLabel},string)->Loader.Request)?)
	assert(RunService:IsStudio() and RunService:IsClient() and game.GameId==10776833313,"Test client only")
	assert(not terrain.root:GetAttribute("HybridProofAttached"),"A renderer already owns terrain")
	terrain.root:SetAttribute("HybridProofAttached",true)
	local images:{ImageLabel}={}
	local originalZ:{[Frame]:number}={}
	for _,entry in terrain.entries do originalZ[entry.root]=entry.root.ZIndex;entry.root.ZIndex=3 end
	for i=1,6 do
		local image=Instance.new("ImageLabel")
		image.Name="ProfileSprite_"..i;image.BackgroundTransparency=1
		image.Active=false;image.Selectable=false;image.Visible=false;image.Parent=terrain.root
		table.insert(images,image)
	end
	local originalRender=terrain.render
	local mode,profile="Native","Original"
	local source=Profiles.get(profile)
	local replacements:{[string]:boolean}={}
	local empty:{[string]:boolean}={}
	local x=(mapRoot:GetAttribute("CameraX") :: number?) or 0
	local y=(mapRoot:GetAttribute("CameraY") :: number?) or 0
	local zoom=(mapRoot:GetAttribute("CameraZoom") :: number?) or 1
	local size=(terrain.root.Parent :: GuiObject).AbsoluteSize
	local destroyed,lastReady=false,false
	local loader=Loader.new(nil)
	local atlas=Atlas.create()
	local function configure()
		loader.destroy() -- cancels observers and invalidates late callbacks before slot reassignment
		terrain.setReplacements(empty)
		source=Profiles.get(profile);replacements={}
		for i,e in source do
			local image=images[i]
			image.Visible=false;image.Image=Profiles.uri(profile,i)
			image.ImageRectOffset=Vector2.new(e.rect[1],e.rect[2]);image.ImageRectSize=Vector2.new(e.rect[3],e.rect[4])
			local p=Manifest.position(e)
			image.Position=UDim2.fromScale(p.X/1200,p.Y/800);image.Size=UDim2.fromOffset(e.world.X,e.world.Y)
			image:SetAttribute("ArtId",e.id);replacements[e.patchId]=true
		end
		local requestFactory: ({ImageLabel},string)->Loader.Request = requestOverride or atlas.request
		loader=Loader.new(requestFactory(images,profile))
		if mode=="Hybrid" then loader.start() end
	end
	local function ready():boolean
		for i,image in images do if image.Image~=Profiles.uri(profile,i) or not image.IsLoaded then return false end end
		return true
	end
	local function draw(nx:number,ny:number,nz:number,ns:Vector2)
		if destroyed then return end
		x,y,zoom,size=nx,ny,nz,ns
		local state=loader.state();lastReady=ready()
		if state=="Ready" and not lastReady then state="ImageUnavailable" end
		local active=mode=="Hybrid" and state=="Ready"
		terrain.setReplacements(if active then replacements else empty)
		originalRender(x,y,zoom,size)
		for i,image in images do
			local e=source[i];local p=Manifest.position(e)
			local warm=mode=="Hybrid" and (state=="Loading" or state=="ImageUnavailable")
			image.ZIndex=if warm then 0 elseif e.coast then 2 else 3
			image.Visible=warm or (active and Geometry.intersects(x+p.X*zoom,y+p.Y*zoom,e.world.X*zoom,e.world.Y*zoom,size.X,size.Y,0))
		end
		mapRoot:SetAttribute("ProofMode",mode);mapRoot:SetAttribute("ProofLoadState",state)
		mapRoot:SetAttribute("ProofProfile",profile);mapRoot:SetAttribute("ProofSynthetic",requestOverride~=nil)
	end
	terrain.render=draw
	local function refresh() draw(x,y,zoom,size) end
	configure();refresh()
	local heartbeat=RunService.Heartbeat:Connect(function()
		if (mapRoot:GetAttribute("ProofLoadState")=="Loading" and loader.state()~="Loading") or (loader.state()=="Ready" and ready()~=lastReady) then refresh() end
	end)
	local destroying:RBXScriptConnection?=nil
	local function destroy()
		if destroyed then return end
		destroyed=true;loader.destroy();atlas.destroy();heartbeat:Disconnect()
		if destroying then destroying:Disconnect() end
		terrain.render=originalRender;terrain.setReplacements(empty)
		for _,image in images do image:Destroy() end
		for object,z in originalZ do object.ZIndex=z end
		terrain.root:SetAttribute("HybridProofAttached",nil)
		for _,key in {"ProofMode","ProofLoadState","ProofProfile","ProofSynthetic"} do mapRoot:SetAttribute(key,nil) end
		if terrain.root.Parent then originalRender(x,y,zoom,size) end
	end
	destroying=mapRoot.Destroying:Connect(destroy)
	return {images=images,refresh=refresh,destroy=destroy,fetchCount=atlas.fetchCount,state=function() return loader.state() end,
		setMode=function(value:string)
			assert(value=="Native" or value=="Hybrid","Unknown art mode")
			if destroyed then return end
			mode=value
			if mode=="Native" then loader.cancelPending()
			elseif loader.state()=="Cancelled" then configure()
			else loader.start() end
			refresh()
		end,
		setProfile=function(value:string)
			Profiles.get(value)
			if destroyed or value==profile then return end
			profile=value;configure();refresh()
		end}
end
return table.freeze(Renderer)
