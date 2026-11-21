--!strict
-- Non-writing representation study. Not a new schema or permitted migration.
return function(f:any)
 local D=game.ServerScriptService.Server.Domain;local C=require(D.ProfileCodec)
 local H=game:GetService("HttpService");local scalar=function(v:any):string return H:JSONEncode(v)end
 for _,source in {f.funded,f.built,f.post}do
  local p=C.copy(source);local rings={p.country.simulation.history,p.country.fleet.baseline.legacySimulation.history}
  local rows=0
  for _,ring in rings do for i,row in ring do ring[i]={row.requested,row.delivered};rows+=1 end end
  local before=#C.encode(source,scalar);local packed=#C.encode(p,scalar)
  assert(before-packed==rows*24,"Exact key-only saving without quantization")
  -- JSON round trip before expansion; retain original index, aggregate and order.
  local restored=H:JSONDecode(H:JSONEncode(p))
  for _,ring in {restored.country.simulation.history,restored.country.fleet.baseline.legacySimulation.history}do
   for i,row in ring do ring[i]={requested=row[1],delivered=row[2]}end
  end
  assert(C.encode(restored,scalar)==C.encode(source,scalar),"Lossless complete original canonical restoration")
  require(D.ProfileSchema4).validate(restored,source.ownerUserId,scalar)
  print("FLEET11_STORAGE_STUDY",H:JSONEncode({beforeBytes=before,proposedBytes=packed,savedBytes=before-packed,
   rows=rows,originalSchemaValidatedAfterExpansion=true,warning="proposal only; not a schema4 encoded profile or migration"}))
 end
 print("[Fleet11 storage study] PASS 9 exact size/round-trip/schema checks; no storage-format implementation")
end
