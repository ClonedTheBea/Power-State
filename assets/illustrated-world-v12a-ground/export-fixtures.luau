--!strict
-- Reproducibility record: run manually in Test edit Command Bar only.
-- Not mapped by Rojo, no service startup, persistence, purchase or asset upload.
assert(game.GameId==10776833313 and not game:GetService("RunService"):IsRunning())
local fixtures=require(game.ServerScriptService.DevelopmentTests.unit["IllustratedWorld.spec"])()
local proof=game.StarterPlayer.StarterPlayerScripts.DevelopmentTests.IllustratedWorld:Clone()
local descriptor=require(proof.IllustratedSectorDescriptor)
for _,fixture in fixtures do
    fixture.composition=descriptor.create(fixture.world,fixture.nodes,fixture.links,2)
end
local encoded=game.HttpService:JSONEncode(fixtures)
-- Studio log truncates large print lines; keep each bounded below that limit.
for i=1,#encoded,700 do
    print("IW12A_DATA:"..math.floor((i-1)/700+1)..":"..string.sub(encoded,i,i+699))
end
print("IW12A_DATA_END",#encoded)
proof:Destroy()
