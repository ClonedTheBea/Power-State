--!strict
-- Explicit opt-in normal fake host endurance; never a real persistence adapter.
return function(player:Player)
 assert(game:GetService("RunService"):IsStudio()and game.GameId==10776833313,"Isolated Test only")
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local host=require(S.Services.ConstructionTestService).start();assert(host.fleet,"Owned fleet required")
 local a=host.inspect(player);assert(a and a.state.fleet.windReceipt,"Complete the fake wind purchase first")
 local C=require(S.Domain.ProfileCodec);local scalar=function(v:any):string return H:JSONEncode(v)end
 local first=host.country.capture(a.world,a.state);local baseline=C.encode(first.fleet.baseline,scalar)
 local receipt=C.encode(first.fleet.windReceipt,scalar);local start=os.clock();local advancedAt=start;local step=a.state.step
 local cycles=0;local maxBytes=0;local capturePeak=0;local memoryBefore=gcinfo()
 while os.clock()-start<600 do
  task.wait(1);cycles+=1
  assert(host.inspect(player)==a and not a.entry.terminal,"Same bounded live fake owner")
  local at=os.clock();local c=host.country.capture(a.world,a.state);local bytes=#C.encode(c,scalar)
  capturePeak=math.max(capturePeak,(os.clock()-at)*1000);maxBytes=math.max(maxBytes,bytes)
  assert(C.encode(c.fleet.baseline,scalar)==baseline and C.encode(c.fleet.windReceipt,scalar)==receipt,"Immutable baseline and permanent purchase")
  assert(c.bank.windConstructionSpentMinor==400000 and c.bank.openingGrantMinor==100000,"No repeat capital or grant")
  assert(a.state.step>=step and c.economy.lastSettledStep==a.state.step,"Monotonic exact financial cursor")
  if a.state.step>step then advancedAt=os.clock();step=a.state.step end
  assert(os.clock()-advancedAt<10,"Normal owned host continues progressing")
  local stats=host.profiles.stats();assert(stats.profiles<=8 and stats.inFlight<=8,"Bounded coordinator")
  if cycles%60==0 then print("[Owned fleet host soak]",cycles,"step",step,"country bytes",bytes)end
 end
 print("[Owned fleet host soak] PASS",H:JSONEncode({elapsed=os.clock()-start,cycles=cycles,firstStep=first.simulation.step,lastStep=step,
  countryBytesMax=maxBytes,captureAndEncodePeakMs=capturePeak,sharedLuaHeapDeltaKiB=gcinfo()-memoryBefore,coordinator=host.profiles.stats()}),"fake host; shared heap delta is not a leak or peak bound")
end
