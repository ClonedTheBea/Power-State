--!strict
-- Exact financial meter alongside (never replacing) the existing physical MWh history.
local Codec=require(script.Parent.ProfileCodec)
local V1=require(script.Parent.ProfileSchema)
local E={DENOMINATOR=60000,SALE=12000,VARIABLE=8000,FIXED=1000,CAP=1000000000000000}
local function fields(t:any,names:string,optional:string?)
 assert(type(t)=="table","Financial record required")
 local allowed={};for k in names:gmatch("%S+")do allowed[k]=true;assert(t[k]~=nil,"Missing finance field "..k)end
 for k in (optional or ""):gmatch("%S+")do allowed[k]=true end
 for k in t do assert(allowed[k],"Unknown finance field "..tostring(k))end
end
local function integer(n:any,lo:number,hi:number)V1.integer(n,lo,hi)end
local function near(a:number,b:number):boolean return math.abs(a-b)<=1e-6+1e-9*math.max(math.abs(a),math.abs(b))end
local function amount(meter:number,rate:number):(number,number)
 local small=(meter%60000)*rate
 return math.floor(meter/60000)*rate+math.floor(small/60000),small%60000
end
local function pair(t:any,posted:string,remainder:string,meter:number,rate:number)
 local whole,part=amount(meter,rate)
 integer(t[posted],0,E.CAP);integer(t[remainder],0,59999)
 assert(t[posted]==whole and t[remainder]==part,"Financial meter/rounding mismatch")
end
function E.open(country:any,operationId:string):(any,any)
 assert(type(operationId)=="string" and #operationId==36,"Activation operation identity")
 local s=country.simulation
 local bank={currency="Credits",minorUnitsPerCredit=100,ledgerVersion=2,balanceMinor=100000,earnedMinor=0,spentMinor=0,
  openingGrantMinor=100000,openingGrantId="P3bOpeningV1:"..country.recipe.countryId,operatingBufferMinor=25000}
 local econ={economyVersion=1,balanceVersion=1,activationStep=s.step,lastSettledStep=s.step,activationOperationId=operationId,fromSchema=1,
  baselineRequestedMWh=s.requestedMWh,baselineDeliveredMWh=s.deliveredMWh,
  deliveredKwMinutes=0,generatedKwMinutes=0,onlineSteps=0,baseSalesMinor=0,bonusSalesMinor=0,variableExpenseMinor=0,fixedExpenseMinor=0,
  baseSalesRemainder=0,bonusSalesRemainder=0,variableExpenseRemainder=0,fixedExpenseRemainder=0,statements={}}
 return bank,econ
end
function E.reservation(e:any,maxKW:number):number
 integer(maxKW,0,5000)
 return math.floor((e.variableExpenseRemainder+maxKW*8000)/60000)+math.floor((e.fixedExpenseRemainder+1000000)/60000)
end
function E.validate(bank:any,e:any,s:any,countryId:string)
 fields(bank,"currency minorUnitsPerCredit ledgerVersion balanceMinor earnedMinor spentMinor openingGrantMinor openingGrantId operatingBufferMinor")
 assert(bank.currency=="Credits" and bank.minorUnitsPerCredit==100 and bank.ledgerVersion==2,"Bank version")
 assert(bank.openingGrantMinor==100000 and bank.openingGrantId=="P3bOpeningV1:"..countryId and bank.operatingBufferMinor==25000,"Opening grant/buffer")
 fields(e,"economyVersion balanceVersion activationStep lastSettledStep activationOperationId fromSchema baselineRequestedMWh baselineDeliveredMWh deliveredKwMinutes generatedKwMinutes onlineSteps baseSalesMinor bonusSalesMinor variableExpenseMinor fixedExpenseMinor baseSalesRemainder bonusSalesRemainder variableExpenseRemainder fixedExpenseRemainder statements","fundingReason fundingStep")
 assert(e.economyVersion==1 and e.balanceVersion==1 and e.fromSchema==1,"Economy version")
 assert(type(e.activationOperationId)=="string" and #e.activationOperationId==36 and e.activationOperationId:match("^[%x]+%-[%x]+%-[%x]+%-[%x]+%-[%x]+$"),"Activation ID")
 integer(e.activationStep,0,s.step);assert(e.lastSettledStep==s.step,"Settlement cursor")
 local elapsed=s.step-e.activationStep
 integer(e.onlineSteps,0,elapsed);integer(e.deliveredKwMinutes,0,elapsed*5000);integer(e.generatedKwMinutes,0,e.onlineSteps*5000)
 assert(e.deliveredKwMinutes==e.generatedKwMinutes,"P3b lossless supply only")
 for _,key in {"baselineRequestedMWh","baselineDeliveredMWh"}do local v=e[key];assert(type(v)=="number" and v==v and v>=0 and v<math.huge,"Activation energy")end
 assert(e.baselineDeliveredMWh<=e.baselineRequestedMWh+1e-6 and e.baselineRequestedMWh<=e.activationStep*10/60+1e-6,"Activation bounds")
 assert(e.baselineDeliveredMWh<=e.activationStep*5/60+1e-6 and s.requestedMWh>=e.baselineRequestedMWh-1e-6,"Activation conservation")
 assert(near(s.deliveredMWh-e.baselineDeliveredMWh,e.deliveredKwMinutes/60000),"Paid meter differs from physical energy")
 pair(e,"baseSalesMinor","baseSalesRemainder",e.deliveredKwMinutes,12000)
 pair(e,"variableExpenseMinor","variableExpenseRemainder",e.generatedKwMinutes,8000)
 pair(e,"fixedExpenseMinor","fixedExpenseRemainder",e.onlineSteps*1000,1000)
 assert(e.bonusSalesMinor==0 and e.bonusSalesRemainder==0,"No P3b entitlement")
 for _,key in {"balanceMinor","earnedMinor","spentMinor"}do integer(bank[key],0,E.CAP)end
 assert(bank.earnedMinor==e.baseSalesMinor and bank.spentMinor==e.variableExpenseMinor+e.fixedExpenseMinor,"Bank categories")
 assert(bank.balanceMinor==100000+bank.earnedMinor-bank.spentMinor,"Bank conservation")
 if e.fundingReason then
  assert(e.fundingReason=="InsufficientOperatingFunds" and not s.online,"Funding status")
  integer(e.fundingStep,e.activationStep,s.step)
 else assert(e.fundingStep==nil,"Orphan funding step")end
 assert(type(e.statements)=="table" and #e.statements<=25,"Bounded financial statements")
 local count=0;for k in e.statements do integer(k,1,#e.statements);count+=1 end;assert(count==#e.statements,"Sparse statements")
 local meters:{[string]:number}={deliveredKwMinutes=0,generatedKwMinutes=0,onlineSteps=0}
 local totals:{[string]:number}={baseSalesMinor=0,variableExpenseMinor=0,fixedExpenseMinor=0}
 local priorEnd:number?=nil
 for _,row in e.statements do
  fields(row,"startStep endStep deliveredKwMinutes generatedKwMinutes onlineSteps baseSalesMinor variableExpenseMinor fixedExpenseMinor")
  integer(row.startStep,e.activationStep,s.step);integer(row.endStep,row.startStep+1,s.step)
  assert(math.floor(row.startStep/60)==math.floor((row.endStep-1)/60),"Statement hour")
  if priorEnd then assert(priorEnd==row.startStep,"Statement gap")end;priorEnd=row.endStep
  integer(row.onlineSteps,0,row.endStep-row.startStep)
  integer(row.deliveredKwMinutes,0,row.onlineSteps*5000);assert(row.generatedKwMinutes==row.deliveredKwMinutes,"Statement energy")
  for key in meters do meters[key]+=row[key]end
  for key in totals do integer(row[key],0,E.CAP);totals[key]+=row[key]end
 end
 if elapsed==0 then assert(#e.statements==0,"No historical billing")
 else
  assert(priorEnd==s.step and #e.statements>0,"Latest statement")
  assert(#e.statements<=24 or e.statements[#e.statements].endStep%60~=0,"24 completed hours plus partial")
  local expectedStart=math.max(e.activationStep,(math.floor(s.step/60)-24)*60)
  assert(e.statements[1].startStep==expectedStart,"Statement eviction boundary")
 end
 -- Validate every retained category from cumulative exact meters, including its start carry.
 local before:{[string]:number}={}
 for key,v in meters do assert(v<=e[key],"Statement meter excess");before[key]=e[key]-v end
 for _,row in e.statements do
  for _,def in {{meter="deliveredKwMinutes",category="baseSalesMinor",rate=12000},{meter="generatedKwMinutes",category="variableExpenseMinor",rate=8000},{meter="onlineSteps",category="fixedExpenseMinor",rate=1000000}}do
   local meter,category,rate=def.meter,def.category,def.rate
   local a=amount(before[meter],rate);before[meter]+=row[meter];local b=amount(before[meter],rate)
   assert(row[category]==b-a,"Statement category mismatch")
  end
 end
end
local function kw(mw:number):number
 assert(type(mw)=="number" and mw==mw and mw>=0 and mw<=5,"Billable power bounds")
 local n=math.floor(mw*1000+.5);assert(math.abs(mw*1000-n)<=1e-6,"Unsupported fractional dispatch")
 return n
end
function E.settle(bank:any,e:any,startStep:number,report:any,online:boolean):(any,any)
 assert(startStep==e.lastSettledStep and startStep<1000000000,"Duplicate/gapped/expired billing interval")
 local delivered=kw(report.deliveredMW);local generated=kw(report.outputMW)
 assert(delivered==generated and (online or generated==0),"P3b flow accounting")
 if online then assert(bank.balanceMinor>=E.reservation(e,5000),"Unfunded interval")end
 local b=table.clone(bank);local n=Codec.copy(e)
 n.lastSettledStep=startStep+1;n.deliveredKwMinutes+=delivered;n.generatedKwMinutes+=generated;n.onlineSteps+=if online then 1 else 0
 local row=n.statements[#n.statements]
 if not row or math.floor(row.startStep/60)~=math.floor(startStep/60)then
  row={startStep=startStep,endStep=startStep,deliveredKwMinutes=0,generatedKwMinutes=0,onlineSteps=0,baseSalesMinor=0,variableExpenseMinor=0,fixedExpenseMinor=0}
  table.insert(n.statements,row)
 end
 row.endStep=startStep+1;row.deliveredKwMinutes+=delivered;row.generatedKwMinutes+=generated;row.onlineSteps+=if online then 1 else 0
 for _,def in {{total="baseSalesMinor",carry="baseSalesRemainder",numerator=delivered*12000},{total="variableExpenseMinor",carry="variableExpenseRemainder",numerator=generated*8000},{total="fixedExpenseMinor",carry="fixedExpenseRemainder",numerator=if online then 1000000 else 0}}do
  local total,carry,numerator=def.total,def.carry,def.numerator;local value=n[carry]+numerator;local posted=math.floor(value/60000)
  n[carry]=value%60000;n[total]+=posted;row[total]+=posted;integer(n[total],0,E.CAP)
 end
 while #n.statements>(if n.lastSettledStep%60==0 then 24 else 25)do table.remove(n.statements,1)end
 b.earnedMinor=n.baseSalesMinor;b.spentMinor=n.variableExpenseMinor+n.fixedExpenseMinor;b.balanceMinor=100000+b.earnedMinor-b.spentMinor
 for _,key in {"balanceMinor","earnedMinor","spentMinor"}do integer(b[key],0,E.CAP)end
 return b,n
end
function E.transition(old:any,new:any,scalar:(any)->string)
 for _,key in {"recipe","settlement","network","ownedSectors","deltas"}do assert(Codec.encode(old[key],scalar)==Codec.encode(new[key],scalar),"Immutable country mutation")end
 local a,b=old.economy,new.economy
 for _,key in {"activationStep","activationOperationId","fromSchema","baselineRequestedMWh","baselineDeliveredMWh","economyVersion","balanceVersion"}do assert(a[key]==b[key],"Immutable activation boundary")end
 local steps=b.lastSettledStep-a.lastSettledStep;assert(steps>=0,"Financial cursor regression")
 for _,key in {"deliveredKwMinutes","generatedKwMinutes","onlineSteps","baseSalesMinor","variableExpenseMinor","fixedExpenseMinor"}do assert(b[key]>=a[key],"Cumulative finance regression")end
 assert(b.onlineSteps-a.onlineSteps<=steps and b.generatedKwMinutes-a.generatedKwMinutes<=(b.onlineSteps-a.onlineSteps)*5000,"Interval funding meters")
 if steps==0 then
  for _,key in {"deliveredKwMinutes","generatedKwMinutes","onlineSteps","baseSalesMinor","variableExpenseMinor","fixedExpenseMinor"}do assert(a[key]==b[key],"Command changed cumulative billing")end
  for _,key in {"bank","simulation"}do
   if key=="bank" then assert(Codec.encode(old.bank,scalar)==Codec.encode(new.bank,scalar),"Command cannot pay")end
  end
  for _,key in {"baseSalesRemainder","variableExpenseRemainder","fixedExpenseRemainder","statements"}do assert(Codec.encode(a[key],scalar)==Codec.encode(b[key],scalar),"Command changed billing")end
 end
end
return table.freeze(E)
