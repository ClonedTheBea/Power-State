--!strict
return function()
	local O = game.ServerScriptService.Server.Operations
	local C = require(O.OperationsCountry); local S = require(O.OperationsScenario); local Solver = require(O.FleetSolver)
	local Codec = require(O.Parent.Domain.ProfileCodec)
	local count = 0
	local function check(v: boolean, message: string) assert(v,message); count += 1 end
	local base = C.convert(S.new(1,1)); base=C.control(base,1,1,base.countryRevision,"peak",true,2000)
	local upgraded = C.invest(base,"engine-economy-comparison")
	local peaks = {prepare=0, solve=0, install=0}
	local function advance(s: any): any
		local started=os.clock(); s=S.prepare(s); peaks.prepare=math.max(peaks.prepare,(os.clock()-started)*1000)
		started=os.clock(); local report=Solver.solve(C.envelope(s).network,s.step); peaks.solve=math.max(peaks.solve,(os.clock()-started)*1000)
		started=os.clock(); s=C.advance(s,report); peaks.install=math.max(peaks.install,(os.clock()-started)*1000)
		return s
	end
	for step=1,10080 do
		base=advance(base); upgraded=advance(upgraded)
		check(upgraded.ledger.cursor == step and upgraded.topologyRevision == 2, "Overlay survives every interval")
		check(base.report.generatedKW == base.report.deliveredKW and upgraded.report.generatedKW == upgraded.report.deliveredKW, "Both paths conserve energy")
		if step==1440 or step==10080 then
			local gain=(upgraded.ledger.salesMinor-upgraded.ledger.expensesMinor)-(base.ledger.salesMinor-base.ledger.expensesMinor)
			check(gain == (if step==1440 then 3161 else 24465), "Actual engine matches analytical incremental net")
			check(upgraded.deliveredKwMinutes-base.deliveredKwMinutes == (if step==1440 then 93000 else 651000), "Actual extra delivered energy")
			check(upgraded.ledger.balanceMinor-base.ledger.balanceMinor == gain-50000, "Capital distinct from operating earnings")
			print(string.format("[Reinforcement engine economics] %d intervals; extra %.6f MWh; extra net %.2f Credits; capital 500; Bank difference %.2f",step,(upgraded.deliveredKwMinutes-base.deliveredKwMinutes)/60000,gain/100,(gain-50000)/100))
		end
		if step%60==0 then task.wait() end
	end
	for _, mode in {"Off","Capped","NoWind","Disconnected","Upstream"} do
		local n=Codec.copy(S.network(90)); n.lines[5].capacityKW=4000
		if mode=="Off" then for _, s in n.sources do s.availableKW=0 end
		elseif mode=="Capped" then for _, s in n.sources do s.availableKW=math.min(s.availableKW,1000) end
		elseif mode=="NoWind" then n.sources[2].availableKW=0
		elseif mode=="Disconnected" then n.lines[5].connected=false
		elseif mode=="Upstream" then n.nodes[4].capacityKW=3000 end
		local r=Solver.solve(n,90)
		check(r.deliveredKW==r.generatedKW and math.abs(r.flowsKW.sb)<=4000,"Conserved constrained graph")
		check(r.sinks.a.deliveredKW+r.sinks.b.deliveredKW==r.deliveredKW,"Independent sink accounting")
		if mode=="Off" then check(r.deliveredKW==0 and r.unmetKW==6000,"Off demand retained") end
		if mode=="Disconnected" then check(r.sinks.b.deliveredKW==0 and r.sinks.b.unmetKW==3500,"Disconnected demand retained") end
		if mode=="Upstream" then check(r.deliveredKW==3000 and r.sinks.a.deliveredKW==1250 and r.sinks.b.deliveredKW==1750,"Original proportional fairness under shared scarcity") end
	end
	print(string.format("[Reinforcement Stage C] PASS %d assertions; peak preparation %.3f / solve %.3f / installation %.3f ms",count,peaks.prepare,peaks.solve,peaks.install))
end
