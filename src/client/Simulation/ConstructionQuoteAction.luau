--!strict
-- Presentation only. Server expiry, ownership, funds and durable Build remain authoritative.
local Action={}
function Action.resolve(snapshot:any,healthy:boolean,age:number):string
 local q=snapshot.construction
 if not healthy or snapshot.suspended or snapshot.built or q.state=="Saving" or q.state=="Unavailable" then return "Disabled"end
 if q.state=="QuoteExpired" or q.state=="DrainingSave" then return "Quote"end
 if q.state=="Available" or q.state=="InsufficientCredits" then
  if not q.quoteId or q.expiresIn<=math.max(0,age) then return "Quote"end
  if q.state=="InsufficientCredits" and snapshot.bankMinor>=125000 then return "Quote"end
  if q.state=="Available" and snapshot.bankMinor>=125000 then return "Confirm"end
 end
 return "Disabled"
end
return table.freeze(Action)
