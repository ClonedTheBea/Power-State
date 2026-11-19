--!strict
-- Cosmetic occupancy only: the NW sample owns each Native 64-unit cell.
local Catalog = require(script.Parent.IllustratedAtlasCatalog)
local Descriptor = {}
export type Entry = {id: string, art: string, x: number, y: number, node: string?, link: number?, preview: boolean?}
function Descriptor.pattern(a: boolean, b: boolean, c: boolean, d: boolean): number
	return (if a then 1 else 0)+(if b then 2 else 0)+(if c then 4 else 0)+(if d then 8 else 0)
end
function Descriptor.create(world: any, nodes: {any}, links: {any})
	assert(world.width == 1024 and world.height == 1024 and #world.samples == 289, "Illustrated sector bounds")
	assert(world.generationVersion==1 and world.climateVersion==1 and world.startTemplateVersion==1,"Unknown illustrated geography version")
	assert(#nodes <= 32 and #links <= 64, "Illustrated infrastructure bounds")
	for _, sample in world.samples do
		assert(type(sample.elevationM) == "number" and sample.elevationM == sample.elevationM and math.abs(sample.elevationM) < math.huge, "Invalid terrain")
	end
	local function land(x: number, y: number): boolean
		return x >= 0 and x < 16 and y >= 0 and y < 16 and world.samples[y*17+x+1].elevationM > 0
	end
	local shores: {Entry} = {}
	-- Unknown adjacent sectors are never fabricated as ocean. Only known interior junctions.
	for y = 1, 15 do for x = 1, 15 do
		local pattern = Descriptor.pattern(land(x-1,y-1),land(x,y-1),land(x-1,y),land(x,y))
		local art = Catalog.patterns[pattern]
		if art then table.insert(shores, {id="shore:"..x..":"..y,art=art,x=x*64,y=y*64}) end
	end end
	local assets: {Entry} = {}
	local byId: {[string]: any} = {}
	for _, node in nodes do
		assert(type(node.id) == "string" and not byId[node.id] and type(node.x) == "number" and type(node.y) == "number"
			and node.x >= 0 and node.x <= 1024 and node.y >= 0 and node.y <= 1024, "Invalid cosmetic anchor")
		byId[node.id] = node
		local preview = string.find(node.description or "", "preview only until saved", 1, true) ~= nil
		local art = if node.kind == "Substation" then "substation" elseif node.kind == "Settlement" then (if preview then "village" else "town")
			elseif node.kind == "Generator" and node.id ~= "wind" and node.id ~= "peak" then "gas" else nil
		if art then table.insert(assets,{id="asset:"..node.id,art=art,x=node.x,y=node.y+24,node=node.id,preview=preview}) end
	end
	-- Pylons are interior points of actual displayed connections, never their crossings.
	for i, link in links do
		local a,b = byId[link.from],byId[link.to]
		assert(a and b, "Unknown cosmetic endpoint")
		local x,y = a.x*.65+b.x*.35,a.y*.65+b.y*.35
		local nearOther = false
		for j, other in links do if i ~= j then
			local c,d = byId[other.from],byId[other.to]
			local dx,dy = d.x-c.x,d.y-c.y
			local t = math.clamp(((x-c.x)*dx+(y-c.y)*dy)/math.max(1,dx*dx+dy*dy),0,1)
			if (x-c.x-t*dx)^2+(y-c.y-t*dy)^2 < 32^2 then nearOther = true end
		end end
		if not nearOther and land(math.floor(x/64),math.floor(y/64)) then
			table.insert(assets,{id="pylon:"..i,art="pylon",x=x,y=y,link=i})
		end
	end
	local decorations: {Entry} = {}
	-- Fixed sparse lattice; whole footprint must be land. Never seed/gameplay generation.
	for y = 2, 14, 3 do for x = 2, 14, 3 do
		local clear = true
		for dy=-1,1 do for dx=-1,1 do if not land(x+dx,y+dy) then clear=false end end end
		local wx,wy=x*64+32,y*64+32
		for _, n in nodes do if math.abs(n.x-wx)<140 and math.abs(n.y-wy)<140 then clear=false end end
		if clear then
			local elevation=world.samples[y*17+x+1].elevationM
			local art=if elevation>75 then (if (x+y)%2==0 then "hill-low-a" else "hill-low-b") elseif (x+y)%2==0 then "forest" else "fields"
			table.insert(decorations,{id="land:"..x..":"..y,art=art,x=wx,y=wy})
		end
	end end
	return {shores=shores,assets=assets,decorations=decorations}
end
return table.freeze(Descriptor)
