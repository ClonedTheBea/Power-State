--!strict
-- One writer per profile. Adapter calls may yield indefinitely; their slots are never reused early.
local Codec=require(script.Parent.Parent.Domain.ProfileCodec)
local DefaultSchema=require(script.Parent.Parent.Domain.ProfileSchema)
local DefaultLease=require(script.Parent.Parent.Domain.ProfileLease)
local Service={}
function Service.create(deps:any)
 local Schema=deps.schema or DefaultSchema;local Lease=deps.lease or DefaultLease
 local approvedEconomy=require(script.Parent.Parent.Adapters.Schema2GameplayAdapter).isApproved(deps.adapter)
 local approvedConstruction=require(script.Parent.Parent.Adapters.Schema3ConstructionAdapter).isApproved(deps.adapter)
 if approvedConstruction then
  assert(deps.schema==require(script.Parent.Parent.Domain.ProfileSchema3) and deps.lease==require(script.Parent.Parent.Domain.ProfileLease3),"Bounded construction contract required")
 end
 if approvedEconomy then
  assert(deps.schema==require(script.Parent.Parent.Domain.ProfileSchema2) and deps.lease==require(script.Parent.Parent.Domain.ExistingEconomyLease),"Existing economy contract required")
 end
 assert(not deps.schema or tostring(deps.adapter.mode)=="Fake" or approvedEconomy or approvedConstruction,"Economic profiles are fake-storage only unless explicitly approved")
 local entries:{[number]:any}={};local count=0;local inFlight=0;local closing=false
 local peak=0;local calls=0;local lastUtc=deps.utcMs();local lastMono=deps.mono()
 local function owns(e:any):boolean
  local p=e.profile;local lock=if p then p.lease else nil
  return lock~=nil and lock.ownerSessionId==e.sessionId and lock.fence==e.fence
 end
 local function safe(e:any):boolean
  return owns(e) and deps.mono()<e.safeUntil and deps.utcMs()<e.profile.lease.expiresAtUtcMs-Lease.SAFETY_MS
 end
 local function fail(e:any,reason:string)
  e.status="Suspended";e.reason=reason;e.terminal=true
  if reason=="OwnershipLost" or reason=="OwnershipOrRevisionChanged" or reason=="RevisionConflict" then e.latest=nil end
 end
 local function remove(e:any)
  if entries[e.owner]==e and not e.inFlight then entries[e.owner]=nil;count-=1;e.status="Released"end
 end
 local function operation(e:any,kind:string,snapshot:any?,revision:number?):any
  return {id=deps.id(),owner=e.owner,sessionId=e.sessionId,jobId=deps.jobId,placeId=deps.placeId,
   kind=kind,fence=e.fence,baseRevision=if e.profile then e.profile.profileRevision else 0,
   snapshot=Codec.copy(snapshot),countryRevision=revision,attempts=0,phase="Update",due=deps.mono(),started=deps.mono()}
 end
 local function retry(e:any,op:any,reason:string)
  e.reason=reason;e.status=if e.closing then "Closing" elseif e.acquired then "Delayed" else "Loading"
  if op.attempts>=5 or deps.mono()-op.started>=30 then e.op=nil;fail(e,"SaveUnavailable");return end
  op.due=deps.mono()+deps.random()*math.min(8,2^math.max(0,op.attempts-1))
 end
 local function confirm(e:any,op:any,value:any)
  Schema.validate(value,e.owner,deps.scalar)
  if value.lastCommit.operationId~=op.id then fail(e,"OwnershipOrRevisionChanged");e.op=nil;return end
  e.profile=Codec.copy(value);e.fence=value.sessionEpoch;e.op=nil
  if op.kind=="Build" then e.critical=false end
  if op.kind=="Release" then remove(e);return end
  if not owns(e) or value.lease.expiresAtUtcMs<=deps.utcMs() then fail(e,"OwnershipLost");return end
  e.safeUntil=deps.mono()+(value.lease.expiresAtUtcMs-deps.utcMs()-Lease.SAFETY_MS)/1000
  e.nextSave=deps.mono()+55+deps.random()*10;e.acquired=true
  if e.latest and e.latest.revision<=value.countryRevision then e.latest=nil end
  if not e.terminal then e.reason=nil;e.status=if e.closing then "Closing" elseif e.active then "Live" else "Loading"end
 end
 local function dispatch(e:any,op:any)
  inFlight+=1;peak=math.max(peak,inFlight);calls+=1;e.inFlight=true;op.attempts+=1
  e.status=if e.closing then "Closing" elseif e.active then "Saving" else "Loading"
  deps.spawn(function()
   local rejection:string?=nil;local invalid=false
   local ok,value=pcall(function()
    if op.phase=="Read" then return deps.adapter.read(e.key)end
    return deps.adapter.update(e.key,function(current:any)
     rejection=nil
     if e.cancelled and op.kind=="Acquire" then rejection="Cancelled";return nil end
     local valid,result,why=pcall(Lease.apply,current,op,deps.utcMs(),deps.scalar)
     if not valid then invalid=true;rejection="InvalidProfile";return nil end
     rejection=why;return result
    end)
   end)
   -- Completion is consumed on the coordinator tick, never directly by a yielding callback.
   e.result={ok=ok,value=value,rejection=rejection,invalid=invalid,op=op}
   e.inFlight=false;inFlight-=1
  end)
 end
 local api={}
 function api.reserve(owner:number):any
  Schema.integer(owner,-Schema.MAX_INTEGER,Schema.MAX_INTEGER);assert(owner~=0,"Owner zero")
  if closing or count>=8 or entries[owner] then return nil end
  if deps.adapter.mode=="Real" then assert(owner>0,"Real profiles require positive UserIds")end
  local e:any={owner=owner,key=(if owner<0 then "fake:" else "u:")..tostring(owner),sessionId=deps.id(),commandEpoch=deps.id(),
   status="Loading",reason=nil,acquired=false,active=false,terminal=false,closing=false,cancelled=false,
   inFlight=false,safeUntil=0,fence=0,started=deps.mono(),nextSave=math.huge}
  entries[owner]=e;count+=1;return e
 end
 function api.prepared(e:any,candidate:any)
  if entries[e.owner]~=e or e.cancelled then return end
  assert(not e.op and not e.acquired,"Already prepared")
  -- Candidate data is server-generated; still validate before any adapter dispatch.
  local validateCandidate=deps.prepareCountry or Schema.country
  validateCandidate(candidate);Codec.encode(candidate,deps.scalar)
  e.op=operation(e,"Acquire",nil,nil);e.op.candidate=Codec.copy(candidate)
 end
 function api.activate(e:any)
  assert(entries[e.owner]==e and e.acquired and not e.closing and not e.terminal and safe(e),"Cannot activate profile")
  e.active=true;e.status="Live"
 end
 function api.canMutate(e:any):boolean
  if entries[e.owner]~=e or not e.active or e.closing or e.terminal or e.critical then return false end
  if not safe(e) then fail(e,"LeaseSafetySuspension");return false end
  return true
 end
 function api.stage(e:any,country:any,revision:number)
  assert(api.canMutate(e),"Profile suspended")
  Schema.integer(revision,e.profile.countryRevision,Schema.MAX_INTEGER)
  if e.latest then assert(revision>=e.latest.revision,"Pending revision regression")end
  local candidate=Codec.copy(e.profile);candidate.country=Codec.copy(country);candidate.countryRevision=revision
  candidate.lastCommit.countryRevision=revision
  local size,soft=Schema.validate(candidate,e.owner,deps.scalar)
  e.latest={country=candidate.country,revision=revision};e.bytes=size;e.soft=soft
 end
 function api.checkpoint(e:any)
  if entries[e.owner]~=e or not e.acquired or e.op or e.inFlight or e.closing or e.terminal then return end
  if not safe(e) then fail(e,"LeaseSafetySuspension");return end
  e.op=operation(e,if e.latest then "Checkpoint" else "Renew",if e.latest then e.latest.country else nil,if e.latest then e.latest.revision else nil)
 end
 -- The real capability is private, exact-Test/account and disabled during preparation.
 function api.build(e:any,operationId:string):(boolean,string?)
  assert((deps.adapter.mode=="Fake" or approvedConstruction) and Schema==require(script.Parent.Parent.Domain.ProfileSchema3)
   and Lease==require(script.Parent.Parent.Domain.ProfileLease3),"Construction requires fake storage or explicitly approved bounded capability")
  if not api.canMutate(e) then return false,"Unavailable"end
  if e.op or e.inFlight or e.result then return false,"DrainingSave"end
  local before=if e.latest then e.latest.country else e.profile.country
  local revision=if e.latest then e.latest.revision else e.profile.countryRevision
  if before.construction.receipt then return false,"AlreadyBuilt"end
  if before.bank.balanceMinor<125000 then return false,"InsufficientCredits"end
  local Project=require(script.Parent.Parent.Domain.ConstructionProject)
  local snapshot=Project.build(before,operationId,revision+1,e.profile.profileRevision+1)
  local op=operation(e,"Build",snapshot,revision+1)
  op.id=operationId;op.before=Codec.copy(before);op.beforeRevision=revision
  local candidate,why=Lease.apply(e.profile,op,deps.utcMs(),deps.scalar)
  if not candidate then return false,why end
  e.critical=true;e.op=op;e.status="Saving"
  return true,nil
 end
 function api.close(e:any)
  if entries[e.owner]~=e then return end
  e.closing=true;e.cancelled=true;e.status="Closing";e.closeAt=e.closeAt or deps.mono()
 end
 function api.unavailable(e:any,reason:string)
  if entries[e.owner]~=e then return end
  fail(e,reason);api.close(e)
 end
 function api.tick()
  local utc=deps.utcMs();local mono=deps.mono()
  if utc<lastUtc-1000 or mono<lastMono then for _,e in entries do fail(e,"ClockAnomaly")end end
  lastUtc=utc;lastMono=mono
  for _,e in entries do
   if e.active and not e.closing and not safe(e) then fail(e,"LeaseSafetySuspension")end
   if e.op and mono-e.op.started>=30 then fail(e,"OperationDeadline")end
   local result=e.result
   if result then
    e.result=nil;local op=result.op
    if result.invalid then e.op=nil;fail(e,"InvalidProfile")
    elseif result.ok and result.value~=nil then
     local ok=pcall(function()
      if op.phase=="Read" and result.value.lastCommit and result.value.lastCommit.operationId~=op.id then
       Schema.validate(result.value,e.owner,deps.scalar)
       if op.kind~="Acquire" and (not result.value.lease or result.value.lease.ownerSessionId~=e.sessionId or result.value.lease.fence~=e.fence) then
        e.op=nil;e.latest=nil;fail(e,"OwnershipLost");return
       end
       -- A read only resolves uncertainty. Any retry still rechecks the current fence/revision atomically.
       op.phase="Update";retry(e,op,"UnconfirmedWrite")
      else confirm(e,op,result.value)end
     end)
     if not ok then e.op=nil;fail(e,"InvalidProfile")end
    elseif result.ok and op.phase=="Update" then
     if result.rejection=="InUse" then retry(e,op,"CountryInUse")
     elseif result.rejection=="Cancelled" then e.op=nil
     else e.op=nil;fail(e,result.rejection or "Rejected")end
    elseif result.ok then op.phase="Update";retry(e,op,"UnconfirmedWrite")
    else op.phase="Read";retry(e,op,"SaveUnavailable")end
   end
   if entries[e.owner]~=e then continue end
   if e.closing then
    if mono-e.closeAt>=20 then
     e.terminal=true;e.latest=nil
     if not e.inFlight then e.op=nil;remove(e)end
    elseif not e.op and not e.inFlight then
     if e.critical then
      -- An unresolved critical debit must never be overwritten by an old release snapshot.
      e.terminal=true
     elseif owns(e) and e.profile.lease.expiresAtUtcMs>utc then
      e.op=operation(e,"Release",if e.latest then e.latest.country else nil,if e.latest then e.latest.revision else nil)
     else remove(e)end
    end
   elseif not e.acquired and not e.op and mono-e.started>=60 then fail(e,"LoadUnavailable")
   elseif e.active and mono>=e.nextSave then api.checkpoint(e)end
  end
  -- Closing profiles first, then other work; one queued operation per admitted profile.
  for _,priority in {true,false} do
   for _,e in entries do
    local op=e.op
    if e.closing==priority and op and not e.inFlight and not e.result and op.due<=mono and inFlight<4 and deps.adapter.budget() then
     if not e.terminal or e.closing then dispatch(e,op)end
    end
   end
  end
 end
 function api.profile(e:any):any return if e.acquired then Codec.copy(e.profile) else nil end
 function api.status(e:any):any
  return {state=e.status,reason=e.reason,storage=deps.adapter.mode,lastSavedAtUtc=if e.profile then e.profile.lastSavedAtUtc else nil,
   savedRevision=if e.profile then e.profile.countryRevision else nil,softLimit=e.soft==true,
   savedBankMinor=if e.profile and e.profile.schemaVersion>=2 then e.profile.country.bank.balanceMinor else nil,
   savedStep=if e.profile and e.profile.schemaVersion>=2 then e.profile.country.simulation.step else nil}
 end
 function api.shutdown()closing=true;for _,e in entries do api.close(e)end end
 function api.stats():any return {profiles=count,inFlight=inFlight,peakInFlight=peak,calls=calls}end
 return api
end
return table.freeze(Service)
