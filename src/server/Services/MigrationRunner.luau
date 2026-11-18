--!strict
-- Sequential bounded proof, never a live profile/simulation coordinator.
local Guard=require(script.Parent.Parent.Domain.ReviewedMigration)
local Runner={}
function Runner.run(deps:any):any
 local guard=Guard.create(deps.review,deps.identity,deps.scalar)
 local acquired=guard.prepare(deps.utcMs())
 deps.validateCandidate(acquired)
 local records={}
 local function verifyRead(verify:(any)->(),label:string):any
  local started=deps.mono()
  for attempt=1,3 do
   local ok,value=pcall(deps.read)
   if ok then verify(value);return value end -- Invalid successful reads are never retried.
   if attempt==3 or deps.mono()-started>=30 then error(label.." read unavailable; stop")end
   deps.wait(1)
  end
  error("Unreachable")
 end
 local began=deps.mono()
 local ok=pcall(function()
  deps.update("MigrateAcquire",function(current:any)
   assert(deps.mono()-began<30,"Migration request deadline")
   return guard.acquire(current,deps.utcMs())
  end)
 end)
 -- Read/receipt reconciliation even on a lost response. Never blindly repeat the write.
 local confirmed=verifyRead(guard.verifyAcquired,"Migration")
 table.insert(records,{kind="MigrateAcquire",responseReceived=ok,reconciled=not ok})
 guard.prepareRelease(confirmed,deps.utcMs())
 began=deps.mono()
 local releaseOk=pcall(function()
  deps.update("Release",function(current:any)
   assert(deps.mono()-began<30,"Release request deadline")
   return guard.release(current,deps.utcMs())
  end)
 end)
 local final=verifyRead(guard.verifyReleased,"Release")
 table.insert(records,{kind="Release",responseReceived=releaseOk,reconciled=not releaseOk})
 return {profile=final,operations=records}
end
return table.freeze(Runner)
