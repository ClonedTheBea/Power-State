--!strict
-- Owner identity and session are injected by the server, never accepted as payload truth.
local Project=require(script.Parent.Parent.Domain.ConstructionProject)
local Quotes={}
function Quotes.create(deps:any)
 local quote:any=nil;local pending=false;local outcome="Available";local sequence=0
 local buckets:any={};local acceptedId:string?=nil;local suspendedAt=0;local suspension=0
 local api={}
 local function gate(actor:number,payload:any):boolean
  if actor~=deps.owner or type(payload)~="table" then return false end
  local count=0
  for k in payload do count+=1;if count>5 or not table.find({"version","epoch","sequence","command","quoteId"},k)then return false end end
  if count>5 or payload.version~=1 or payload.epoch~=deps.epoch then return false end
  local n=payload.sequence
  if type(n)~="number" or n~=n or n%1~=0 or n<=sequence or n>1000000000 then return false end
  if not table.find({"Quote","Confirm","Status"},payload.command)then return false end
  if payload.quoteId~=nil and (type(payload.quoteId)~="string" or #payload.quoteId~=36)then return false end
  local now=deps.now();local b=buckets[payload.command] or {tokens=2,at=now}
  b.tokens=math.min(2,b.tokens+math.max(0,now-b.at));b.at=now;buckets[payload.command]=b
  if b.tokens<1 then return false end
  b.tokens-=1;sequence=n;return true
 end
 function api.status():any
  local c=deps.country()
  if quote and not pending and deps.now()>=quote.expires then outcome="QuoteExpired"end
  return {state=if pending then "Saving" elseif c.construction.receipt then (if outcome=="Built" then "Built" else "AlreadyBuilt") else outcome,
   quoteId=if quote then quote.id else nil,expiresIn=if quote then math.max(0,quote.expires-deps.now()) else 0,
   priceMinor=Project.PRICE,bufferMinor=Project.BUFFER,bankMinor=c.bank.balanceMinor,
   nextSequence=sequence+1,suspensionSeconds=suspension}
 end
 function api.handle(actor:number,payload:any):any
  if not gate(actor,payload)then return {state="Rejected",nextSequence=sequence+1}end
  if payload.command=="Status"then return api.status()end
  if pending then return api.status()end
  local c=deps.country()
  if c.construction.receipt then outcome="AlreadyBuilt";return api.status()end
  if payload.command=="Quote"then
   Project.validateSite(c)
   quote={id=deps.id(),operationId=deps.id(),expires=deps.now()+30,topology=c.construction.topologyRevision}
   outcome=if c.bank.balanceMinor>=125000 then "Available"else "InsufficientCredits"
  elseif not quote or payload.quoteId~=quote.id or deps.now()>=quote.expires then outcome="QuoteExpired"
  elseif quote.topology~=c.construction.topologyRevision then outcome="Unavailable"
  else
   local ok,why=deps.build(quote.operationId)
   if ok then pending=true;acceptedId=quote.operationId;suspendedAt=deps.now();outcome="Saving";quote=nil
   else outcome=why or "Unavailable"end
  end
  return api.status()
 end
 function api.tick()
  if not pending then return end
  local status=deps.saveStatus();local p=deps.profile()
  if p and p.country.construction.receipt and p.country.construction.receipt.operationId==acceptedId and deps.canResume()then
   deps.install(p);suspension=deps.now()-suspendedAt;pending=false;outcome="Built"
  elseif status.state=="Suspended" or status.state=="Released" then
   pending=false;outcome="Unavailable";quote=nil
  end
 end
 return api
end
return table.freeze(Quotes)
