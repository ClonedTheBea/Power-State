--!strict
-- Pure renderer contracts, run in Test edit mode or server; no persistence access.
return function()
	assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
	local proof=game.StarterPlayer.StarterPlayerScripts.DevelopmentTests.IllustratedWorld
	local Catalog=require(proof.IllustratedAtlasCatalog)
	local Descriptor=require(proof.IllustratedSectorDescriptor)
	local count=0
	local function check(v: boolean,m: string) assert(v,m);count+=1 end
	local dimensions={main={1024,1024},diagonal={512,256},original={1024,1024},settlements={512,256}}
	for _,m in Catalog.motifs do
		local r=m.rect;local dim=dimensions[m.atlas]
		check(dim~=nil and r[1]>=8 and r[2]>=8 and r[1]+r[3]<=dim[1]-8 and r[2]+r[4]<=dim[2]-8,"Atlas crop and gutters")
		check(m.pivot[1]>=0 and m.pivot[1]<=r[3] and m.pivot[2]>=0 and m.pivot[2]<=r[4],"Content pivot")
	end
	for pattern=0,15 do
		check(Descriptor.pattern(bit32.band(pattern,1)>0,bit32.band(pattern,2)>0,bit32.band(pattern,4)>0,bit32.band(pattern,8)>0)==pattern,"All sixteen occupancy classes")
		check((Catalog.patterns[pattern]~=nil)==(pattern~=0 and pattern~=15),"Fourteen direct shore classes")
	end
	for bits=0,511 do
		local world: any={width=1024,height=1024,generationVersion=1,climateVersion=1,startTemplateVersion=1,samples={}}
		for y=0,16 do for x=0,16 do table.insert(world.samples,{elevationM=if x<3 and y<3 and bit32.band(bits,2^(y*3+x))>0 then 40 else -40}) end end
		local d=Descriptor.create(world,{},{});local unique: {[string]: boolean}={}
		for _,e in d.shores do check(not unique[e.id] and e.x>=64 and e.x<=960 and e.y>=64 and e.y<=960,"Unique known-boundary ownership");unique[e.id]=true end
		check(#d.shores<=9,"Bounded exhaustive small topology")
	end
	local Generator=require(game.ServerScriptService.Server.World.WorldGenerator)
	local Project=require(game.ServerScriptService.Server.Domain.ConstructionProject)
	local fixtures={}
	for i,seed in {"12fee3f76be963c09033cdfd9ccffb36","fe0512aa351b994df1656b88f0d94f1b"} do
		local w=Generator.create(seed,"illustrated-fixture-"..i,1)
		local world=Generator.snapshot(w)
		local nodes={};local links={}
		for _,n in w.network.nodes do table.insert(nodes,{id=n.id,name=n.name,kind=n.kind,x=n.x,y=n.y,description="Server-generated Test fixture"}) end
		for _,l in w.network.lines do table.insert(links,{from=l.from,to=l.to}) end
		local district,line=Project.assets({recipe={seed=seed,countryId=w.countryId,candidate=w.candidate},settlement={name=w.layout.name},network=w.network})
		table.insert(nodes,{id=district.id,name=district.name,kind=district.kind,x=district.x,y=district.y,description="Surveyed district · preview only until saved"})
		table.insert(links,{from=line.from,to=line.to})
		local d=Descriptor.create(world,nodes,links)
		check(#d.shores<=78,"Actual generated corpus coverage")
		if i==2 then check(#d.shores==78,"Maximum-junction fixture") end
		local again=Descriptor.create(world,nodes,links)
		check(game.HttpService:JSONEncode(d)==game.HttpService:JSONEncode(again),"Deterministic descriptor replay")
		table.insert(fixtures,{world=world,nodes=nodes,links=links,metrics={{label="TEST FIXTURE",value=w.layout.name,detail="No financial state"},{label="SEED",value=string.sub(seed,1,8),detail="Generated geometry"},{label="SHORES",value=tostring(#d.shores),detail="Exact Native mask"},{label="ART",value="Experimental",detail="No gameplay changes"}}})
	end
	print(string.format("[Illustrated pure] PASS %d assertions; actual 78-shore fixture",count))
	return fixtures
end
