--!strict
local V1=require(script.Parent.ProfileSchema)
local V3=require(script.Parent.ProfileSchema3)
local Codec=require(script.Parent.ProfileCodec)
local R=require(script.Parent.FleetRecord)
local Seed=require(script.Parent.CountryFleetSeed)
local District=require(script.Parent.ConstructionProject)
local Wind=require(script.Parent.WindProject)
local Statements=require(script.Parent.FleetStatements)
local Schema={MAX_INTEGER=V1.MAX_INTEGER,integer=V1.integer}
-- Weak immutable-baseline proofs avoid revalidating the same 1,440 historic
-- rows on every live interval. Mutable/loaded input always takes the full path.
local baselineProofs:any=setmetatable({},{__mode="k"})
local function scalarDefault(v:any):string return game.HttpService:JSONEncode(v)end
local function emptyDeltas():any
 return {builtNodes={},builtLines={},generatedOverrides={},tombstones={},constructionOrders={},nextBuiltAssetSerial=1}
end
function Schema.baselineCountry(c:any):any
 local n={recipe=Codec.copy(c.recipe),settlement=Codec.copy(c.settlement),network=Codec.copy(c.network),ownedSectors=Codec.copy(c.ownedSectors)}::any
 local b=c.fleet.baseline
 n.bank=Codec.copy(b.legacyBank);n.economy=Codec.copy(b.legacyEconomy)
 n.construction=Codec.copy(b.legacyConstruction);n.simulation=Codec.copy(b.legacySimulation);n.deltas=emptyDeltas()
 if n.construction.receipt then
  local node,line=District.assets(n);n.deltas.builtNodes={node};n.deltas.builtLines={line};n.deltas.nextBuiltAssetSerial=3
 end
 return n
end
-- Structural/current-history validation only, never a writable downgrade.
function Schema.structural(c:any):any
 local n={recipe=c.recipe,settlement=c.settlement,network=c.network,ownedSectors=c.ownedSectors,simulation=c.simulation,deltas=emptyDeltas()}::any
 n.bank={currency="Credits",minorUnitsPerCredit=100,ledgerVersion=1,balanceMinor=0,earnedMinor=0,spentMinor=0}
 return n
end
local function unit(u:any,capacity:number,rate:number,fixed:number,maxSteps:number)
 R.fields(u,"costVersion on capKW generatedKwMinutes onlineSteps variableExpenseMinor fixedExpenseMinor variableExpenseRemainder fixedExpenseRemainder")
 assert(u.costVersion==1 and type(u.on)=="boolean","Pinned fleet cost/state")
 R.integer(u.capKW,0,capacity);assert(u.capKW%100==0,"100 kW cap steps")
 R.integer(u.onlineSteps,0,maxSteps);R.integer(u.generatedKwMinutes,0,u.onlineSteps*capacity)
 for _,v in {{posted="variableExpenseMinor",remainder="variableExpenseRemainder",meter=u.generatedKwMinutes,rate=rate},
  {posted="fixedExpenseMinor",remainder="fixedExpenseRemainder",meter=u.onlineSteps*1000,rate=fixed}}do
  local whole,carry=R.amount(v.meter,v.rate);assert(u[v.posted]==whole and u[v.remainder]==carry,"Exact per-unit financial carry")
 end
end
local function finance(c:any,base:any,scalar:(any)->string)
 local b,e,f,s=c.bank,c.economy,c.fleet,c.simulation;local old=base.economy
 R.fields(b,"currency minorUnitsPerCredit ledgerVersion balanceMinor earnedMinor spentMinor openingGrantMinor openingGrantId operatingBufferMinor constructionSpentMinor windConstructionSpentMinor")
 assert(b.ledgerVersion==4 and b.currency=="Credits" and b.minorUnitsPerCredit==100,"Fleet Bank version")
 for _,k in {"openingGrantMinor","openingGrantId","operatingBufferMinor"}do assert(b[k]==base.bank[k],"Preserved grant/buffer")end
 R.fields(e,"economyVersion balanceVersion activationStep lastSettledStep activationOperationId fromSchema baselineRequestedMWh baselineDeliveredMWh deliveredKwMinutes generatedKwMinutes onlineSteps baseSalesMinor bonusSalesMinor variableExpenseMinor fixedExpenseMinor baseSalesRemainder bonusSalesRemainder variableExpenseRemainder fixedExpenseRemainder statements","fundingReason fundingStep")
 assert(e.economyVersion==2 and e.lastSettledStep==s.step,"Fleet financial cursor/version")
 for _,k in {"balanceVersion","activationStep","activationOperationId","fromSchema","baselineRequestedMWh","baselineDeliveredMWh"}do assert(e[k]==old[k],"Frozen economy activation")end
 local generated,variable,fixed,count=0,0,0,0
 local gas=f.units[c.network.generatorId];assert(gas,"Original gas required")
 if not f.windReceipt then assert(gas.capKW==5000,"Legacy solver retains its fixed capacity")end
 assert(gas.on==s.online and e.onlineSteps==gas.onlineSteps,"Legacy gas state/count mirror")
 local windNode=Wind.assets(c);local windId=windNode.id
 for id,u in f.units do
  assert(id==c.network.generatorId or (f.windReceipt and id==windId),"Unexpected owned generator")
  local isGas=id==c.network.generatorId
  unit(u,if isGas then 5000 else 2000,if isGas then 8000 else 0,if isGas then 1000 else 600,
   s.step-(if isGas then e.activationStep else f.windReceipt.step))
  if not isGas then assert(u.generatedKwMinutes<=u.onlineSteps*1600,"Wind v1 historical maximum potential")end
  generated+=u.generatedKwMinutes;variable+=u.variableExpenseMinor;fixed+=u.fixedExpenseMinor;count+=1
 end
 assert(count==(if f.windReceipt then 2 else 1),"Exact fleet membership")
 assert(e.generatedKwMinutes==generated and e.deliveredKwMinutes==generated,"National lossless paid meter")
 assert(e.variableExpenseMinor==variable and e.fixedExpenseMinor==fixed,"Sum posted unit expenses without rerounding")
 assert(e.variableExpenseRemainder==gas.variableExpenseRemainder and e.fixedExpenseRemainder==gas.fixedExpenseRemainder,"Gas carry compatibility")
 local sales,carry=R.amount(generated,12000)
 assert(e.baseSalesMinor==sales and e.baseSalesRemainder==carry and e.bonusSalesMinor==0 and e.bonusSalesRemainder==0,"Once-only national sales")
 assert(R.near(s.deliveredMWh-e.baselineDeliveredMWh,generated/60000),"Fleet paid/physical energy")
 assert(b.earnedMinor==sales and b.spentMinor==variable+fixed+b.constructionSpentMinor+b.windConstructionSpentMinor,"Fleet categories")
 assert(b.balanceMinor==b.openingGrantMinor+b.earnedMinor-b.spentMinor,"Fleet Bank conservation")
 for _,k in {"balanceMinor","earnedMinor","spentMinor"}do R.integer(b[k],0,R.LIMIT)end
 for _,k in {"deliveredKwMinutes","generatedKwMinutes","onlineSteps","baseSalesMinor","variableExpenseMinor","fixedExpenseMinor"}do
  R.integer(e[k],old[k],R.LIMIT)
 end
 assert(e.deliveredKwMinutes-old.deliveredKwMinutes<=(s.step-f.cutoverStep)*5000,"Bounded live service since cutover")
 for _,k in {"generatedKwMinutes","onlineSteps","variableExpenseMinor","fixedExpenseMinor"}do assert(gas[k]>=old[k],"Preserve legacy gas meters")end
 if e.fundingReason then
  assert(e.fundingReason=="InsufficientOperatingFunds","Funding reason");R.integer(e.fundingStep,e.activationStep,s.step)
 else assert(e.fundingStep==nil,"Orphan funding marker")end
 assert(type(e.statements)=="table" and #e.statements<=25,"Bounded fleet statements")
 local previous:number?=nil;local rows=0
 for k,row in e.statements do
  R.integer(k,1,#e.statements);rows+=1
  R.fields(row,"startStep endStep deliveredKwMinutes generatedKwMinutes onlineSteps baseSalesMinor variableExpenseMinor fixedExpenseMinor")
  R.integer(row.startStep,e.activationStep,s.step);R.integer(row.endStep,row.startStep+1,s.step)
  assert(math.floor(row.startStep/60)==math.floor((row.endStep-1)/60),"Statement hour")
  if previous then assert(previous==row.startStep,"Statement gap")end;previous=row.endStep
  R.integer(row.onlineSteps,0,row.endStep-row.startStep)
  R.integer(row.generatedKwMinutes,0,(row.endStep-row.startStep)*5000)
  assert(row.deliveredKwMinutes==row.generatedKwMinutes,"Statement delivered energy")
  for _,key in {"baseSalesMinor","variableExpenseMinor","fixedExpenseMinor"}do R.integer(row[key],0,e[key])end
 end
 assert(rows==#e.statements,"Dense statement array")
 if s.step==e.activationStep then assert(rows==0,"No retroactive statements")else
  assert(rows>0 and previous==s.step,"Latest statement")
  assert(e.statements[1].startStep==math.max(e.activationStep,(math.floor(s.step/60)-24)*60),"Statement window")
 end
 if s.step==f.cutoverStep and not f.windReceipt then
  local restored=Codec.copy(e);restored.economyVersion=1;restored.fundingReason=nil;restored.fundingStep=nil
  local original=Codec.copy(old);original.fundingReason=nil;original.fundingStep=nil;R.equal(restored,original,scalar)
 end
 Statements.validate(c)
end
function Schema.country(c:any,scalar:((any)->string)?)
 local encode=scalar or scalarDefault
 R.fields(c,"recipe settlement network ownedSectors simulation bank deltas economy construction fleet")
 local f=c.fleet
 R.fields(f,"version compositionVersion cutoverStep windVersion windSeed windRegion investmentSerial units baseline","windReceipt windState")
 assert(f.version==1 and f.compositionVersion==1 and f.windVersion==1,"Fleet versions")
 R.integer(f.cutoverStep,0,c.simulation.step)
 assert(f.windSeed==Seed.fromCountry(c.recipe.seed) and f.windRegion==Seed.REGION,"Pinned country wind recipe")
 R.fields(f.baseline,"legacyEconomy legacyBank legacyConstruction legacySimulation migrationOperationId")
 R.guid(f.baseline.migrationOperationId)
 local baseline=f.baseline
 local geometry=Codec.encode({recipe=c.recipe,settlement=c.settlement,network=c.network,ownedSectors=c.ownedSectors},encode)
 local proof=if table.isfrozen(baseline)then baselineProofs[baseline]else nil
 local base:any
 if proof and proof.geometry==geometry then base=proof.country
 else
  base=Schema.baselineCountry(c);V3.country(base,encode)
  -- Only deep immutability permits reuse; a shallow freeze is insufficient.
  local function deeplyFrozen(v:any):boolean
   if type(v)~="table"then return true end
   if not table.isfrozen(v)then return false end
   for _,item in v do if not deeplyFrozen(item)then return false end end
   return true
  end
  if deeplyFrozen(baseline)then baselineProofs[baseline]={geometry=geometry,country=R.freeze(base)}end
 end
 assert(base.simulation.step==f.cutoverStep and base.economy.lastSettledStep==f.cutoverStep,"Exact baseline cutover")
 V1.country(Schema.structural(c))
 assert(c.simulation.requestedMWh>=base.simulation.requestedMWh and c.simulation.deliveredMWh>=base.simulation.deliveredMWh,"Physical history regression")
 local district=c.construction.receipt
 -- A later district may be funded after cutover; validate its exact record/assets
 -- below instead of fabricating historical funds in the baseline projection.
 if base.construction.receipt then R.equal(base.construction,c.construction,encode)end
 local expected=emptyDeltas()
 if district then
  R.fields(c.construction,"constructionVersion constructionDemandVersion compositionVersion topologyRevision receipt")
  assert(c.construction.constructionVersion==1 and c.construction.constructionDemandVersion==1 and c.construction.compositionVersion==2 and c.construction.topologyRevision==1,"District versions")
  R.fields(district,"projectId definitionVersion operationId priceMinor terminalId lineId step beforeBankMinor afterBankMinor countryRevision profileRevision")
  R.guid(district.operationId)
  local node,line=District.assets(c)
  assert(district.projectId==District.ID and district.definitionVersion==1 and district.priceMinor==District.PRICE and district.terminalId==node.id and district.lineId==line.id,"Preserved district receipt")
  assert(district.beforeBankMinor-district.afterBankMinor==District.PRICE and district.afterBankMinor>=District.BUFFER,"District debit")
  R.integer(district.step,0,c.simulation.step)
  R.integer(district.beforeBankMinor,District.PRICE+District.BUFFER,R.LIMIT)
  R.integer(district.afterBankMinor,District.BUFFER,R.LIMIT)
  for _,key in {"countryRevision","profileRevision"}do R.integer(district[key],1,Schema.MAX_INTEGER)end
  expected.builtNodes={node};expected.builtLines={line};expected.nextBuiltAssetSerial=3
  assert(c.bank.constructionSpentMinor==District.PRICE,"District capital")
 else R.equal(c.construction,District.empty(),encode);assert(c.bank.constructionSpentMinor==0,"Empty district capital")end
 if f.windReceipt then
  local receipt=f.windReceipt
  local price=Wind.price(receipt.definitionVersion)
  assert(district and f.investmentSerial==1 and c.bank.windConstructionSpentMinor==price,"Wind prerequisite/serial/capital")
  R.fields(receipt,"projectId definitionVersion operationId priceMinor generatorId lineId step beforeBankMinor afterBankMinor countryRevision profileRevision")
  R.guid(receipt.operationId);local node,line=Wind.assets(c)
  assert(receipt.projectId==Wind.ID and receipt.priceMinor==price and receipt.generatorId==node.id and receipt.lineId==line.id,"Wind semantic receipt")
  R.integer(receipt.step,math.max(f.cutoverStep,district.step),c.simulation.step)
  R.integer(receipt.beforeBankMinor,price+Wind.BUFFER,R.LIMIT);R.integer(receipt.afterBankMinor,Wind.BUFFER,R.LIMIT)
  assert(receipt.beforeBankMinor-receipt.afterBankMinor==price,"One capital debit")
  for _,key in {"countryRevision","profileRevision"}do R.integer(receipt[key],1,Schema.MAX_INTEGER)end
  table.insert(expected.builtNodes,node);table.insert(expected.builtLines,line)
  R.fields(f.windState,"on capKW");local u=f.units[node.id]
  assert(u and f.windState.on==u.on and f.windState.capKW==u.capKW,"Wind control mirror")
 else
  assert(f.investmentSerial==0 and f.windState==nil and c.bank.windConstructionSpentMinor==0,"Migration does not build wind")
 end
 R.equal(c.deltas,expected,encode)
 finance(c,base,encode)
end
function Schema.validate(p:any,owner:number,scalar:(any)->string):(number,boolean)
 local encoded=Codec.encode(p,scalar);assert(p.schemaVersion==4,"Schema 4 required")
 local structural=table.clone(p);structural.lastCommit=table.clone(p.lastCommit);structural.schemaVersion=1;structural.country=Schema.structural(p.country)
 if table.find({"MigrateAcquire","Build","BuildWind"},structural.lastCommit.kind)then structural.lastCommit.kind="Checkpoint"end
 V1.validate(structural,owner,scalar);Schema.country(p.country,scalar)
 for _,receipt in {p.country.construction.receipt,p.country.fleet.windReceipt}do
  if receipt then assert(receipt.profileRevision<=p.profileRevision and receipt.countryRevision<=p.countryRevision,"Future investment receipt")end
 end
 return #encoded,#encoded>196608
end
function Schema.transition(a:any,b:any,scalar:(any)->string)
 Schema.country(b,scalar)
 for _,key in {"recipe","settlement","network","ownedSectors","construction","deltas"}do R.equal(a[key],b[key],scalar)end
 for _,key in {"version","compositionVersion","cutoverStep","windVersion","windSeed","windRegion","investmentSerial","baseline","windReceipt"}do
  assert((a.fleet[key]==nil)==(b.fleet[key]==nil),"Fleet field removal")
  if a.fleet[key]~=nil then R.equal(a.fleet[key],b.fleet[key],scalar)end
 end
 assert(a.bank.constructionSpentMinor==b.bank.constructionSpentMinor and a.bank.windConstructionSpentMinor==b.bank.windConstructionSpentMinor,"Capital requires atomic Build")
 local steps=b.simulation.step-a.simulation.step;R.integer(steps,0,1000000000)
 for id,old in a.fleet.units do
  local new=b.fleet.units[id];assert(new,"Lost owned unit")
  local online=new.onlineSteps-old.onlineSteps;R.integer(online,0,steps)
  R.integer(new.generatedKwMinutes-old.generatedKwMinutes,0,online*(if id==a.network.generatorId then 5000 else 1600))
 end
 if steps==0 then
  R.equal(a.bank,b.bank,scalar)
  local oldE,newE=Codec.copy(a.economy),Codec.copy(b.economy)
  oldE.fundingReason=nil;oldE.fundingStep=nil;newE.fundingReason=nil;newE.fundingStep=nil
  R.equal(oldE,newE,scalar)
  local oldS,newS=Codec.copy(a.simulation),Codec.copy(b.simulation);oldS.online=nil;newS.online=nil
  R.equal(oldS,newS,scalar)
 end
end
return table.freeze(Schema)
