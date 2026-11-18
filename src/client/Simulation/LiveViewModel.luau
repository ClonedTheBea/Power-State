--!strict

local Types=require(game:GetService("ReplicatedStorage").Shared.Types.ShellTypes)

local ViewModel={}

function ViewModel.create(snapshot:any):Types.Preview

 local nodes:{Types.MapNode}={};local links:{Types.MapLink}={}

 for _,n in snapshot.nodes do table.insert(nodes,{id=n.id,name=n.name,kind=n.kind,x=n.x,y=n.y,description="Server-owned "..(snapshot.profile or "P2a").." test asset"}) end

 for _,l in snapshot.lines do table.insert(links,{from=l.from,to=l.to}) end

 return {nodes=nodes,links=links,world=snapshot.world,metrics={

 {label=if snapshot.profile=="P3b" then "BANK · LIVE" elseif snapshot.profile=="P3a" then "BANK · NONSPENDABLE" else "BANK · PREVIEW",
  value=if snapshot.profile=="P3b" then require(script.Parent.BankPresentation).compact(snapshot) elseif snapshot.profile=="P3a" then "0 Credits" else "100,000 Credits",
  currencyMinor=if snapshot.profile=="P3b" then snapshot.bankMinor elseif snapshot.profile=="P3a" then 0 else 10000000,detail=if snapshot.profile=="P3b" then "Live; checkpoint status in Bank" else "Not spendable"},

 {label="DELIVERED / DEMAND",value="Waiting",detail="Server MW"},

 {label="SERVICE HISTORY",value="Unknown",detail="Observed simulation interval"},

 {label="POPULATION · FIXED",value="1,000",detail="Fixture only; no growth"}}}

end

return table.freeze(ViewModel)

