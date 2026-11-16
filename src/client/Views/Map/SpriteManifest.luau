--!strict
-- Local revision-3 descriptors only. No hosted asset is configured or implied.
local Manifest = {}
Manifest.ATLAS_REVISION = 3
Manifest.ATLAS_SHA256 = "e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb"
export type Sprite = { id: string, revision: number, patchId: string, rect: {number}, cell: {number}, world: Vector2, pivot: Vector2, anchor: Vector2, coast: boolean }
local entries: {Sprite} = {
	{ id = "coast-headland", revision = 3, patchId = "art1:0:0:west-cape", rect = {8,8,496,496}, cell = {0,0,512,512}, world = Vector2.new(248,248), pivot = Vector2.new(248,248), anchor = Vector2.new(217.5,362.5), coast = true },
	{ id = "mountain-ridge", revision = 1, patchId = "art1:0:0:highlands", rect = {520,8,496,240}, cell = {512,0,512,256}, world = Vector2.new(248,120), pivot = Vector2.new(248,120), anchor = Vector2.new(587.5,180), coast = false },
	{ id = "forest-cluster", revision = 1, patchId = "art1:0:0:wood-west", rect = {520,264,240,240}, cell = {512,256,256,256}, world = Vector2.new(150,150), pivot = Vector2.new(120,120), anchor = Vector2.new(290,422.5), coast = false },
	{ id = "agriculture", revision = 1, patchId = "art1:0:0:fields", rect = {776,264,240,240}, cell = {768,256,256,256}, world = Vector2.new(160,160), pivot = Vector2.new(120,120), anchor = Vector2.new(772.5,430), coast = false },
	{ id = "settlement", revision = 1, patchId = "art1:0:0:newford", rect = {8,520,240,240}, cell = {0,512,256,256}, world = Vector2.new(150,150), pivot = Vector2.new(120,160), anchor = Vector2.new(755,300), coast = false },
	{ id = "gas-station", revision = 1, patchId = "art1:0:0:industry", rect = {264,520,240,240}, cell = {256,512,256,256}, world = Vector2.new(150,150), pivot = Vector2.new(120,160), anchor = Vector2.new(340,345), coast = false },
}
local function finite(n: number): boolean return n == n and math.abs(n) < math.huge end
function Manifest.position(e: Sprite): Vector2
	return e.anchor - Vector2.new(e.pivot.X * e.world.X / e.rect[3], e.pivot.Y * e.world.Y / e.rect[4])
end
function Manifest.validate(value: {Sprite}, revision: number): boolean
	if revision ~= 3 or #value ~= 6 then return false end
	local ids: {[string]: boolean} = {}
	local patches: {[string]: boolean} = {}
	for i, e in value do
		if type(e) ~= "table" or type(e.id) ~= "string" or type(e.patchId) ~= "string" or ids[e.id] or patches[e.patchId] then return false end
		ids[e.id] = true; patches[e.patchId] = true
		if type(e.rect) ~= "table" or type(e.cell) ~= "table" or #e.rect ~= 4 or #e.cell ~= 4 then return false end
		for _, rect in {e.rect,e.cell} do for _, n in rect do
			if type(n) ~= "number" or not finite(n) or n < 0 or n % 1 ~= 0 then return false end
		end end
		local r, c = e.rect, e.cell
		if r[3] <= 0 or r[4] <= 0 or c[1]+c[3] > 1024 or c[2]+c[4] > 1024 then return false end
		if r[1] ~= c[1]+8 or r[2] ~= c[2]+8 or r[3] ~= c[3]-16 or r[4] ~= c[4]-16 then return false end
		for _, v in {e.world,e.pivot,e.anchor} do
			if typeof(v) ~= "Vector2" or not finite(v.X) or not finite(v.Y) then return false end
		end
		if e.world.X <= 0 or e.world.Y <= 0 or e.pivot.X < 0 or e.pivot.Y < 0 or e.pivot.X > r[3] or e.pivot.Y > r[4] then return false end
		if math.abs(e.world.X/r[3]-e.world.Y/r[4]) > 0.000001 then return false end
		-- This isolated proof accepts only the approved six descriptors, not arbitrary sectors.
		local approved = entries[i]
		if e.id ~= approved.id or e.patchId ~= approved.patchId or e.revision ~= approved.revision or e.coast ~= approved.coast
			or e.world ~= approved.world or e.pivot ~= approved.pivot or e.anchor ~= approved.anchor then return false end
		for j=1,4 do if r[j] ~= approved.rect[j] or c[j] ~= approved.cell[j] then return false end end
		for j=1,i-1 do local b=value[j].cell
			if c[1]<b[1]+b[3] and c[1]+c[3]>b[1] and c[2]<b[2]+b[4] and c[2]+c[4]>b[2] then return false end
		end
	end
	return true
end
for _,e in entries do table.freeze(e.rect); table.freeze(e.cell); table.freeze(e) end
Manifest.entries = table.freeze(entries)
return table.freeze(Manifest)
