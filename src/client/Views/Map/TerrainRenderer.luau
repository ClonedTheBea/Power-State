--!strict
local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Parent.Theme)
local Art = require(script.Parent.MapArt)
local Fixture = require(script.Parent.MapFixture)
local Geometry = require(script.Parent.MapGeometry)
local Terrain = {}
Terrain.MAX_PATCHES = 24
local function paint(root: Frame, patch: Fixture.Patch, detail: Frame): boolean
	local w, h, kind = patch.width, patch.height, patch.kind
	if kind == "land" then
		Art.patch(root, "Meadow", 0, 0, w, h, T.land, (patch.radius or math.min(w, h) / 2))
	elseif kind == "hills" or kind == "mountains" then
		for i = 0, 2 do
			local px, py = i * 55, if i == 1 then -12 else 25
			if kind == "mountains" then
				Art.peak(root, px + 8, py + 18, 100, T.stoneShadow)
				Art.peak(root, px, py, if i == 1 then 125 else 100, T.stone, T.stoneShadow)
				Art.peak(root, px + (if i == 1 then 40 else 30), py, if i == 1 then 45 else 40, T.snow, T.stone)
			else
				Art.patch(root, "SlopeShade", px + 6, py + 12, 82, 65, T.landShadow, 40, -18)
				local slope = Art.patch(root, "LitSlope", px, py, 82, 65, T.hill, 40, -18)
				Art.shade(slope, T.hill, T.land)
			end
		end
	elseif kind == "forest" then
		Art.patch(root, "WoodlandMass", 0, 10, w, h - 10, T.forest, 35, -8)
		for i = 0, 7 do Art.tree(if i % 2 == 0 then root else detail, 6 + (i % 4) * 27, math.floor(i / 4) * 32) end
	elseif kind == "fields" then
		for i = 0, 2 do
			Art.patch(root, "Field", i * w / 3, 0, w / 3 - 5, h, if i % 2 == 0 then T.field else T.hill, 3, -8)
			Art.patch(root, "Hedgerow", i * w / 3, h - 2, w / 3 - 5, 3, T.forestLight, nil, -8)
			for j = 1, 3 do Art.patch(detail, "Furrow", i * w / 3 + 8, j * h / 4, w / 3 - 18, 2, T.fieldLight, nil, -8) end
		end
	elseif kind == "substation" then
		Art.patch(root, "Switchyard", 0, 0, w, h, T.stoneShadow, 4)
		Art.ribbon(root, "Bus", 10, 13, 65, 13, 3, T.stone)
		for i = 0, 2 do
			Art.patch(root, "Transformer", 10 + i * 23, 22, 14, 20, T.stone)
			Art.patch(root, "Insulator", 14 + i * 23, 15, 5, 11, T.snow)
		end
	elseif kind == "lake" then
		Art.patch(root, "LakeBank", -3, -3, w + 6, h + 6, T.coast, 30, -12)
		Art.patch(root, "Lake", 0, 0, w, h, T.river, 30, -12)
		Art.ribbon(detail, "Reflection", 15, 25, 55, 20, 2, T.snow)
	elseif kind == "river" then
		local points = { Vector2.new(5, 0), Vector2.new(50, 70), Vector2.new(20, 140), Vector2.new(105, 205), Vector2.new(90, 275), Vector2.new(130, 345) }
		for i = 1, #points - 1 do
			local a, b = points[i], points[i + 1]
			Art.ribbon(root, "RiverBank", a.X, a.Y, b.X, b.Y, 14, T.coast)
			Art.ribbon(root, "River", a.X, a.Y, b.X, b.Y, 9, T.river)
		end
	elseif kind == "routes" then
		-- Cosmetic access roads and pylons: no route legality or network inference.
		for _, road in { {40,100,170,150}, {170,150,290,180}, {290,180,365,290}, {290,180,455,45} } do
			Art.ribbon(root, "AccessRoad", road[1], road[2], road[3], road[4], 5, T.road)
		end
		for _, p in { {150,83}, {365,48}, {320,190} } do
			local px, py = p[1], p[2]
			Art.patch(root, "PylonLeg", px - 5, py - 11, 2, 24, T.stoneShadow, nil, 16)
			Art.patch(root, "PylonLeg", px + 5, py - 11, 2, 24, T.stoneShadow, nil, -16)
			Art.patch(root, "CrossArm", px - 11, py - 9, 24, 3, T.snow)
			Art.patch(root, "Brace", px - 6, py, 14, 2, T.stone, nil, 30)
		end
	elseif kind == "town" or kind == "village" or kind == "industry" then
		Art.patch(root, "District", 0, 4, w, h, T.landShadow, 18, -8)
		Art.ribbon(root, "MainStreet", 0, h / 2, w, h / 2 - 12, 9, T.road)
		local count = if kind == "town" then 6 elseif kind == "industry" then 2 else 4
		for i = 0, count - 1 do
			local height = if kind == "town" then 18 + (i % 3) * 8 else 14
			Art.building(root, 8 + (i % 3) * 30, 12 + math.floor(i / 3) * 36,
				if kind == "industry" then 42 else 19, height, kind == "industry")
		end
		if kind == "industry" then
			-- Gas station: turbine halls and twin exhaust stacks, not nuclear cooling towers.
			for _, x in { 20, 48 } do
				Art.patch(root, "ExhaustShadow", x + 6, -15, 9, 43, T.stoneShadow)
				Art.patch(root, "ExhaustStack", x, -20, 10, 43, T.stone)
				Art.patch(root, "ExhaustRim", x - 2, -20, 14, 5, T.snow)
				Art.patch(root, "StackBand", x, -9, 10, 5, T.roof)
			end
			Art.patch(root, "FuelVessel", 80, 64, 29, 19, T.stone, 9)
		elseif kind == "town" then
			Art.building(root, 43, -22, 22, 36)
			Art.patch(root, "Clock", 50, -4, 7, 7, T.snow, 4)
		elseif string.find(patch.id, "eastmere", 1, true) then
			Art.ribbon(root, "CoastalPier", 70, 44, 112, 72, 9, T.road)
			Art.ribbon(root, "PierHead", 100, 60, 120, 62, 7, T.roof)
		else
			Art.patch(root, "KitchenGardens", 4, 64, 48, 15, T.field, 3)
			Art.ribbon(detail, "GardenRows", 10, 69, 46, 69, 2, T.fieldLight)
		end
	else return false end
	return true
end
function Terrain.create(parent: Instance, descriptors: { Fixture.Patch }?)
	local source = descriptors or Fixture
	assert(#source <= Terrain.MAX_PATCHES, "Illustrated patch budget exceeded")
	local root = C.frame(parent, "TerrainArtwork")
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromOffset(1200, 800)
	local scale = Instance.new("UIScale"); scale.Parent = root
	-- Draw every coast rim before every meadow so adjacent patches form one island,
	-- not separate outlined tiles. This fixed pool is reused for every camera draw.
	local shores: { { root: Frame, patch: Fixture.Patch } } = {}
	for _, patch in source do if patch.kind == "land" then
		local shore = C.frame(root, patch.id .. ":shore")
		shore.BackgroundTransparency = 1; shore.Position = UDim2.fromOffset(patch.x, patch.y)
		shore.Size = UDim2.fromOffset(patch.width, patch.height)
		local w, h = patch.width, patch.height
		Art.patch(shore, "Shallows", -12, -7, w + 24, h + 24, T.shallows, (patch.radius or math.min(w, h) / 2))
		Art.patch(shore, "Cliff", -3, 8, w + 6, h + 10, T.landShadow, (patch.radius or math.min(w, h) / 2))
		Art.patch(shore, "Shore", -4, -4, w + 8, h + 8, T.coast, (patch.radius or math.min(w, h) / 2))
		table.insert(shores, { root = shore, patch = patch })
	end end
	local entries: { { root: Frame, detail: Frame, patch: Fixture.Patch } } = {}
	for _, patch in source do
		local chunk = C.frame(root, patch.id)
		chunk.BackgroundTransparency = 1
		chunk.Position = UDim2.fromOffset(patch.x, patch.y)
		chunk.Size = UDim2.fromOffset(patch.width, patch.height)
		chunk:SetAttribute("ArtRevision", 2)
		local detail = C.frame(chunk, "Detail")
		detail.BackgroundTransparency = 1; detail.Size = UDim2.fromScale(1, 1); detail.ZIndex = 2
		if not paint(chunk, patch, detail) then
			Art.patch(chunk, "MissingArtFallback", 0, 0, patch.width, patch.height, T.land, 8)
			local label = C.label(chunk, "Terrain art unavailable", 14)
			label.BackgroundTransparency = 0; label.BackgroundColor3 = T.panel
			label.Size = UDim2.new(1, 0, 0, 32); label.ZIndex = 3
			chunk:SetAttribute("Fallback", true)
		end
		table.insert(entries, { root = chunk, detail = detail, patch = patch })
	end
	local band = "regional"
	-- Optional cosmetic ownership; native remains the default with an empty set.
	local replacements: { [string]: boolean } = {}
	return { root = root, entries = entries, shores = shores,
		setReplacements = function(value: { [string]: boolean }) replacements = value end,
		render = function(x: number, y: number, zoom: number, size: Vector2)
		root.Position = UDim2.fromOffset(x, y); scale.Scale = zoom
		band = Geometry.band(band, zoom)
		root:SetAttribute("ZoomBand", band)
		local visible = 0
		for _, entry in shores do
			local p = entry.patch
			entry.root.Visible = not replacements[p.id] and Geometry.intersects(x + p.x * zoom, y + p.y * zoom, p.width * zoom, p.height * zoom, size.X, size.Y, 64 * zoom)
		end
		for _, entry in entries do
			local p = entry.patch
			-- One bounded 64-world-unit margin covers relief/shore overhang.
			entry.root.Visible = not replacements[p.id] and Geometry.intersects(x + p.x * zoom, y + p.y * zoom, p.width * zoom, p.height * zoom, size.X, size.Y, 64 * zoom)
			entry.detail.Visible = band ~= "overview"
			if entry.root.Visible then visible += 1 end
		end
		root:SetAttribute("VisiblePatches", visible)
	end }
end
return Terrain
