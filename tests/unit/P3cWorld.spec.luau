--!strict
return function()
 local S=game.ServerScriptService.Server
 local Project=require(S.Domain.ConstructionProject)
 local Starter=require(S.World.StarterValidator)
 local seen={};local count=0
 local function inspect(world:any)
  local c={recipe={seed=world.seed,countryId=world.countryId,candidate=world.candidate}}
  Project.validateSite(c);seen[world.layout.rotation]=true;count+=1
 end
 require(script.Parent["P2bWorld.spec"])(10000,inspect)
 for r=0,3 do assert(seen[r],"All starter rotations")end
 local fallback={recipe={seed=string.rep("0",32),countryId="safe",candidate=8}}
 Project.validateSite(fallback);assert(Starter.layout(fallback.recipe.seed,"safe",8).rotation==0)
 print(string.format("[Power State P3c world] PASS: %d accepted seed routes/pads, four rotations and safe fallback; retained P2b gates",count))
end
