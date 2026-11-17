--!strict
-- Test-only frozen cosmetic profiles; the approved original manifest stays untouched.
local Original = require(script.Parent.Parent.Client.Views.Map.SpriteManifest)
type Sprite = Original.Sprite
local Profiles = {}
Profiles.ORIGINAL_URI = "rbxassetid://86222383311104"
Profiles.SETTLEMENT_URI = "rbxassetid://90608851718773"
Profiles.UPLOAD_DECAL_ID = 138420314032574
local south: Sprite = {id="southbank",revision=1,patchId="art1:0:0:southbank",rect={8,8,240,240},cell={0,0,256,256},world=Vector2.new(130,130),pivot=Vector2.new(150,182),anchor=Vector2.new(685,590),coast=false}
local east: Sprite = {id="eastmere",revision=1,patchId="art1:0:0:eastmere",rect={264,8,240,240},cell={256,0,256,256},world=Vector2.new(140,140),pivot=Vector2.new(120,160),anchor=Vector2.new(945,510),coast=false}
for _,e in {south,east} do table.freeze(e.rect);table.freeze(e.cell);table.freeze(e) end
local settlement = table.freeze({Original.entries[1],Original.entries[2],south,east,Original.entries[5],Original.entries[6]})
function Profiles.get(name: string): {Sprite}
	assert(name=="Original" or name=="Settlements","Unknown isolated art profile")
	return if name=="Original" then Original.entries else settlement
end
function Profiles.uri(name: string,index: number): string
	assert(index>=1 and index<=6 and index%1==0,"Invalid sprite slot")
	Profiles.get(name)
	return if name=="Settlements" and (index==3 or index==4) then Profiles.SETTLEMENT_URI else Profiles.ORIGINAL_URI
end
return table.freeze(Profiles)
