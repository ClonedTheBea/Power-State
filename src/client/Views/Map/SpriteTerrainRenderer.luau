--!strict
local RunService = game:GetService("RunService")
local Manifest = require(script.Parent.SpriteManifest)
local Loader = require(script.Parent.SpriteAtlasLoader)
local Geometry = require(script.Parent.MapGeometry)
local Fixture = require(script.Parent.MapFixture)
local Theme = require(script.Parent.Parent.Parent.Theme)
local Renderer = {}
type Native = {
	root: Frame,
	entries: {{root: Frame, detail: Frame, patch: Fixture.Patch}},
	shores: {{root: Frame, patch: Fixture.Patch}},
	setReplacements: ({[string]: boolean}) -> (),
	render: (number, number, number, Vector2) -> (),
}
function Renderer.attach(mapRoot: Frame, terrain: Native, request: Loader.Request?, clock: (() -> number)?, descriptors: {Manifest.Sprite}?)
	assert(RunService:IsStudio(), "R3.3 isolated Studio proof only")
	assert(not terrain.root:GetAttribute("HybridProofAttached"), "Destroy the existing proof before remounting")
	local source = descriptors or Manifest.entries
	local validated, valid = pcall(Manifest.validate, source, Manifest.ATLAS_REVISION)
	valid = validated and valid
	-- Validation accepts only this frozen revision; never retain caller-mutable descriptors.
	if valid then source = Manifest.entries end
	local loader = Loader.new(if valid then request else nil, clock)
	local images: {ImageLabel} = {}
	local replacements: {[string]: boolean} = {}
	local empty: {[string]: boolean} = {}
	local originalZ: {[Frame]: number} = {}
	local originalRender = terrain.render
	local mode = "Native"
	local destroyed = false
	local x = (mapRoot:GetAttribute("CameraX") :: number?) or 0
	local y = (mapRoot:GetAttribute("CameraY") :: number?) or 0
	local zoom = (mapRoot:GetAttribute("CameraZoom") :: number?) or 1
	local viewport = terrain.root.Parent :: GuiObject
	local size = viewport.AbsoluteSize
	local connections: {RBXScriptConnection} = {}
	terrain.root:SetAttribute("HybridProofAttached", true)
	if valid then
		for _,entry in terrain.entries do originalZ[entry.root] = entry.root.ZIndex; entry.root.ZIndex = 3 end
		for _,e in source do
			local image = Instance.new("ImageLabel")
			image.Name = "ProofSprite_"..e.id
			image.Image = "" -- Intentionally no texture or fabricated asset ID.
			image.ImageRectOffset = Vector2.new(e.rect[1],e.rect[2])
			image.ImageRectSize = Vector2.new(e.rect[3],e.rect[4])
			local position = Manifest.position(e)
			-- Offset components are integer pixels. Scale within the fixed world canvas
			-- preserves approved half-world-unit origins before the shared UIScale.
			image.Position = UDim2.fromScale(position.X/1200,position.Y/800)
			image.Size = UDim2.fromOffset(e.world.X,e.world.Y)
			image.BackgroundColor3 = Theme.accent
			image.BackgroundTransparency = 0.82 -- Explicit synthetic footprint, never presented as artwork.
			image.Active = false; image.Selectable = false; image.Visible = false
			image.ZIndex = if e.coast then 2 else 3
			image:SetAttribute("Synthetic", true); image:SetAttribute("ArtRevision", e.revision)
			image.Parent = terrain.root
			table.insert(images,image); replacements[e.patchId] = true
		end
	end
	local function draw(nextX: number, nextY: number, nextZoom: number, nextSize: Vector2)
		if destroyed then return end
		x,y,zoom,size = nextX,nextY,nextZoom,nextSize
		local state = if valid then loader.state() else "InvalidManifest"
		local active = mode == "Hybrid" and state == "Ready"
		terrain.setReplacements(if active then replacements else empty)
		originalRender(x,y,zoom,size)
		for i,image in images do
			local p,e = Manifest.position(source[i]),source[i]
			image.Visible = active and Geometry.intersects(x+p.X*zoom,y+p.Y*zoom,e.world.X*zoom,e.world.Y*zoom,size.X,size.Y,0)
		end
		mapRoot:SetAttribute("ProofMode",mode)
		mapRoot:SetAttribute("ProofLoadState",state)
		mapRoot:SetAttribute("ProofSynthetic",request ~= nil)
	end
	terrain.render = draw
	local function refresh() draw(x,y,zoom,size) end
	local function destroy()
		if destroyed then return end
		destroyed = true; loader.destroy()
		for _,connection in connections do connection:Disconnect() end
		table.clear(connections)
		terrain.render = originalRender; terrain.setReplacements(empty)
		for _,image in images do image:Destroy() end
		for object,z in originalZ do object.ZIndex = z end
		terrain.root:SetAttribute("HybridProofAttached",nil)
		for _,key in {"ProofMode","ProofLoadState","ProofSynthetic"} do mapRoot:SetAttribute(key,nil) end
		if terrain.root.Parent then originalRender(x,y,zoom,size) end
	end
	table.insert(connections,mapRoot.Destroying:Connect(destroy))
	table.insert(connections,RunService.Heartbeat:Connect(function()
		if mapRoot:GetAttribute("ProofLoadState") == "Loading" and loader.state() ~= "Loading" then refresh() end
	end))
	refresh()
	return {images=images, refresh=refresh, destroy=destroy, state=loader.state,
		setMode=function(value: string)
			if destroyed then return end
			assert(value == "Native" or value == "Hybrid", "Unknown proof mode")
			mode = value
			if value == "Hybrid" then loader.start() else loader.cancelPending() end
			refresh()
		end,
	}
end
return table.freeze(Renderer)
