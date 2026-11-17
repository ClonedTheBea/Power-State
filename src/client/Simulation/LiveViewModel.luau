--!strict

local Types=require(game:GetService("ReplicatedStorage").Shared.Types.ShellTypes)

local ViewModel={}

function ViewModel.create(snapshot:any):Types.Preview

 local nodes:{Types.MapNode}={};local links:{Types.MapLink}={}

 for _,n in snapshot.nodes do table.insert(nodes,{id=n.id,name=n.name,kind=n.kind,x=n.x,y=n.y,description="Server-owned "..(snapshot.profile or "P2a").." test asset"}) end

 for _,l in snapshot.lines do table.insert(links,{from=l.from,to=l.to}) end

 return {nodes=nodes,links=links,world=snapshot.world,metrics={

 {label="BANK · PREVIEW",value="100,000 Credits",currencyMinor=10000000,detail="Not spendable"},

 {label="DELIVERED / DEMAND",value="Waiting",detail="Server MW"},

 {label="SERVICE HISTORY",value="Unknown",detail="Observed simulation interval"},

 {label="POPULATION · FIXED",value="1,000",detail="Fixture only; no growth"}}}

end

return table.freeze(ViewModel)

