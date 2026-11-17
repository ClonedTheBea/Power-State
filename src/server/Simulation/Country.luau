--!strict
local Model=require(script.Parent.NetworkModel)
local Solver=require(script.Parent.GridSolver)
local Country={}
Country.STEP_HOURS=1/60
function Country.new(owner:number,epoch:string,generated:Model.Network?)
 local network=generated or Model.starter()
 return {owner=owner,epoch=epoch,network=network,online=true,step=0,revision=0,controlRevision=0,
  requestedMWh=0,deliveredMWh=0,history={}::{ {requested:number,delivered:number} },historyIndex=0,
  windowRequested=0,windowDelivered=0,lastSequence=0,tokens=4,rateAt=0,
  report=Solver.solve(network,true),suspended=false,delayed=false}
end
export type State=typeof(Country.new(0,""))
function Country.advance(state:State,demandMW:number?)
 -- Solve before any mutation: failure cannot partially advance accounting.
 local network=state.network
 if demandMW then network=table.clone(network);network.demandMW=demandMW end
 local result=Solver.solve(network,state.online)
 state.network=network
 local requested=result.demandMW*Country.STEP_HOURS;local delivered=result.deliveredMW*Country.STEP_HOURS
 local index=state.historyIndex%1440+1;local old=state.history[index]
 state.windowRequested+=requested-(if old then old.requested else 0)
 state.windowDelivered+=delivered-(if old then old.delivered else 0)
 state.history[index]={requested=requested,delivered=delivered};state.historyIndex=index
 state.step+=1;state.revision+=1;state.report=result
 state.requestedMWh+=requested;state.deliveredMWh+=delivered
end
function Country.snapshot(state:State,outcome:string?)
 return {version=1,epoch=state.epoch,revision=state.revision,controlRevision=state.controlRevision,
  nextSequence=state.lastSequence+1,ackSequence=state.lastSequence,outcome=outcome or "Snapshot",
  online=state.online,step=state.step,simulatedMinutes=state.step,stepHours=Country.STEP_HOURS,
  deliveredMWh=state.deliveredMWh,requestedMWh=state.requestedMWh,
  reliability=if state.windowRequested>0 then state.windowDelivered/state.windowRequested else -1,
  historyMinutes=math.min(state.step,1440),report=state.report,
  nodes=state.network.nodes,lines=state.network.lines,population=state.network.population,
  suspended=state.suspended,delayed=state.delayed}
end
return table.freeze(Country)
