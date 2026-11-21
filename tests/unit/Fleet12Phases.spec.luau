--!strict
return function(f:any)
 local S=game.ServerScriptService.Server;local D=S.Domain;local H=game:GetService("HttpService")
 local scalar=function(v:any):string return H:JSONEncode(v)end
 local C=require(D.ProfileCodec);local F=require(D.FleetStorageFormat);local R=require(D.FleetRecord)
 local V=require(D.ProfileSchema4);local L=require(D.ProfileLease4)
 local frozen=R.snapshot(f.built);local packed=F.pack(f.built,149564436,scalar)
 local heap=gcinfo();local start=os.clock()
 local function measure(label:string,fn:()->())
  local times={}
  for i=1,20 do local at=os.clock();fn();table.insert(times,(os.clock()-at)*1000);if i%4==0 then task.wait()end end
  table.sort(times);print("FLEET12_PHASE",label,H:JSONEncode({p50=times[10],p95=times[19],peak=times[20]}))
 end
 measure("canonicalWarmImmutable",function()C.encode(frozen,scalar)end)
 measure("canonicalColdCopyFreezeEncode",function()C.encode(R.snapshot(C.copy(f.built)),scalar)end)
 measure("canonicalMutableValidation",function()V.validate(f.built,149564436,scalar)end)
 measure("compactPackFullValidation",function()F.pack(f.built,149564436,scalar)end)
 measure("compactReadFullValidation",function()F.read(packed,149564436,scalar)end)
 local now=2000000000000
 local op={kind="Acquire",owner=149564436,id=H:GenerateGUID(false),sessionId=H:GenerateGUID(false),jobId="Fleet12PhaseFake",placeId=1}
 local acquired=L.apply(f.built,op,now,scalar)
 local checkpoint={kind="Checkpoint",owner=149564436,id=H:GenerateGUID(false),sessionId=op.sessionId,jobId=op.jobId,placeId=1,
  fence=acquired.sessionEpoch,baseRevision=acquired.profileRevision,snapshot=acquired.country,countryRevision=acquired.countryRevision}
 local before=C.encode(acquired,scalar);local snapshot=C.encode(checkpoint.snapshot,scalar)
 measure("pureLeaseCheckpoint",function()L.apply(acquired,checkpoint,now+1,scalar)end)
 assert(C.encode(acquired,scalar)==before and C.encode(checkpoint.snapshot,scalar)==snapshot,"Shallow projections never mutate input")
 local fake=require(S.Adapters.FakeDataStoreAdapter).create({["u:149564436"]=f.built})
 measure("fakeCopyAndCommitOnly",function()fake.update("u:149564436",function(p)return p end)end)
 print("FLEET12_PHASE_RESOURCES",os.clock()-start,"elapsed seconds; heap delta KiB",gcinfo()-heap,"shared heap, not isolated allocation or GC pause")
end
