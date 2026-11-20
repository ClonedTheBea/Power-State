--!strict
-- Normal owned-country transport and bound GUI actions, not Training imports.
return function(playerGui:PlayerGui,resumeBuilt:boolean?)
 assert(game:GetService("RunService"):IsStudio()and game.GameId==10776833313,"Owned fleet Test diagnostics only")
 local Client=require(script.Parent.Parent.Client.Simulation.ConstructionClient)
 if Client.active()then Client.active().destroy()end
 local live=Client.mount(playerGui);local app=live.app;local ui=live.ownedFleet;local checks=0
 local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 local function waitFor(fn:()->boolean,seconds:number)
  local untilAt=os.clock()+seconds;repeat task.wait(.05)until fn()or os.clock()>untilAt
  check(fn(),"Owned fleet authoritative progression deadline")
 end
 check(ui~=nil and live.current().fleet~=nil,"Normal fake country has owned-fleet presentation")
 local wind=live.current().fleet.node.id;local gas=live.current().generatorId
 if not resumeBuilt then
 check(live.current().built and not live.current().fleet.built,"Earned district prerequisite, wind not granted")
 check(live.current().bankMinor>=425000,"Wind funded by prior genuine fake intervals")
 local initialStep=live.current().step
 for _,size in {{1366,704},{768,960},{360,580},{640,300}}do
  app.view.root.Size=UDim2.fromOffset(size[1],size[2]);app.selectAsset(wind);task.wait(.3)
  check(ui.review.Visible and ui.review.AbsoluteSize.Y>=44,"Responsive wind review target")
  local camera=app.view.map.root:GetAttribute("CameraX")
  app.actions[ui.review]();waitFor(function()return live.current().fleet.project.state=="Available"end,5)
  check(ui.confirm.AbsoluteSize.Y>=44 and ui.confirm.AbsoluteSize.X>=44,"44px purchase target")
  check(app.keyboard.valid(app.view.feedback.close),"Accessible wind modal dismissal")
  check(app.state.selectedId==wind and app.view.map.root:GetAttribute("CameraX")==camera,"Review preserves camera and selection")
  app.actions[app.view.feedback.close]()
 end
 app.actions[ui.review]();waitFor(function()return live.current().fleet.project.state=="Available"end,5)
 local expired=live.current().fleet.project.quoteId
 waitFor(function()return live.current().fleet.project.state=="QuoteExpired"end,35)
 check(app.view.feedback.root.Visible and ui.confirm.Text=="Refresh Quote","Expiry keeps review open and offers refresh")
 app.actions[ui.confirm]();waitFor(function()return live.current().fleet.project.state=="Available"and live.current().fleet.project.quoteId~=expired end,5)
 check(live.current().step>initialStep,"Ordinary review does not pause production")
 local camera=app.view.map.root:GetAttribute("CameraX")
 app.actions[ui.confirm]();app.actions[ui.confirm]();app.actions[app.view.feedback.close]()
 waitFor(function()return live.current().fleet.built end,10)
 check(live.current().finance.bank.windConstructionSpentMinor==400000 and live.current().bankMinor>=25000,"One capital debit and operating buffer")
 check(app.state.selectedId==wind and app.view.map.root:GetAttribute("CameraX")==camera,"Committed construction preserves map")
 else check(live.current().fleet.built and live.current().finance.bank.windConstructionSpentMinor==400000,"Resume only the already confirmed purchase, without resetting fake funds")end
 waitFor(function()return live.current().fleet.dispatch~=nil end,5)
 check(live.current().report.sinks[1].id==live.current().demandId and live.current().report.sinks[2].id==live.current().proposedNode.id,"Town/district public ordering preserved")
 check(live.current().fleet.dispatch.sources[wind]>=0 and live.current().fleet.dispatch.sources[gas]>=0,"Separate real solver source outputs")
 for _,size in {{1366,704},{768,960},{360,580},{640,300}}do
  app.view.root.Size=UDim2.fromOffset(size[1],size[2]);app.selectAsset(wind);task.wait(.3)
  check(ui.toggle.Visible and ui.toggle.AbsoluteSize.Y>=44 and ui.down.AbsoluteSize.Y>=44 and ui.up.AbsoluteSize.X>=44,"Responsive owned controls retain 44px targets")
  -- A collapsed mobile inspector legitimately clips its lower controls. Exercise
  -- the actual paging/focus path instead of requiring off-screen eligibility.
  for _,target in {ui.toggle,ui.down}do
   if app.state.inspectorStage=="peek"then app.actions[app.view.inspector.expand]();task.wait(.1)end
   for _=1,12 do
    if app.keyboard.valid(target)then break end
    check(app.keyboard.scrollPage(1),"Inspector keyboard/shoulder paging available")
    task.wait(.05)
   end
   check(app.keyboard.valid(target),"Owned control reachable after paging")
   app.keyboard.focus(target);task.wait(.05)
   check(game:GetService("GuiService").SelectedObject==target,"Owned control receives real engine focus")
  end
  check(#app.view.map.root:GetDescendants()<=600,"Native map budget after wind purchase")
  app.actions[app.view.inspector.locate]();check(app.state.selectedId==wind,"Locate retains owned identity")
 end
 local function control(button:TextButton,predicate:()->boolean)
  app.actions[button]();waitFor(predicate,5);task.wait(.6)
 end
 app.selectAsset(wind)
 control(ui.down,function()return live.current().fleet.units[wind].capKW==1900 end)
 control(ui.up,function()return live.current().fleet.units[wind].capKW==2000 end)
 control(ui.toggle,function()return not live.current().fleet.units[wind].on end)
 waitFor(function()return live.current().fleet.dispatch.sources[wind]==0 end,5)
 control(ui.toggle,function()return live.current().fleet.units[wind].on end)
 app.selectAsset(gas);control(ui.toggle,function()return not live.current().online end)
 waitFor(function()return live.current().fleet.dispatch.sources[gas]==0 and live.current().report.unmetMW>0 end,5)
 control(ui.toggle,function()return live.current().online end)
 waitFor(function()return live.current().report.unmetMW==0 end,5)
 app.navigate("Infrastructure");task.wait(.3)
 check(#live.directory.rows==5,"Bounded directory includes wind")
 local windRow=nil
 for _,row in live.directory.rows do if row.id==wind then windRow=row.button end end
 check(windRow~=nil,"Owned wind discoverable outside the map")
 app.actions[windRow]();app.actions[live.directory.control]();check(app.state.selectedId==wind,"Directory opens correct generator controls")
 local json=game:GetService("HttpService"):JSONEncode(live.current())
 for _,private in {"legacySimulation","migrationOperationId","ownerSessionId","lastCommit","windSeed"}do check(not json:find(private,1,true),"Private baseline/seed/lease excluded")end
 local step=live.current().step;local capital=live.current().finance.bank.windConstructionSpentMinor;local oldSubscription=live.current().subscriptionId
 live.destroy();task.wait(1.2);live=Client.mount(playerGui);app=live.app
 check(live.current().fleet.built and live.current().step>=step and live.current().finance.bank.windConstructionSpentMinor==capital,"Remount retains wind and financial state")
 check(live.current().subscriptionId~=oldSubscription,"Fresh mount requires its own server subscription acknowledgement")
 live.ownedFleet.open();waitFor(function()return live.current().fleet.project.state=="AlreadyBuilt"end,5)
 check(not live.ownedFleet.confirm.Active and live.ownedFleet.confirm.Text:find("Built",1,true)~=nil,"Completed project cannot charge again")
 local remountedStep=live.current().step
 waitFor(function()return live.current().step>=remountedStep+3 end,8)
 local s=live.current();local intent=game.ReplicatedStorage.P3cConstruction.Intent
 intent:FireServer({version=1,command="Unsubscribe",subscriptionId=oldSubscription})
 local rejected={version=1,kind="SetFleetGenerator",epoch=s.epoch,sequence=s.nextSequence,
  revision=s.controlRevision,assetId=wind,online=false,capKW=2000}
 local malformedChanges:{any}={{owner=149564436},{bankMinor=1000000000},{capKW=150},{assetId="foreign:wind"},{version=999}}
 for _,change in malformedChanges do
  local payload=table.clone(rejected);for key,value in change do payload[key]=value end;intent:FireServer(payload)
 end
 intent:FireServer(rejected,"unexpected extra argument")
 intent:FireServer({version=1,command="Confirm",projectId="starter-wind-v1",epoch=s.epoch,
  sequence=s.fleet.project.nextSequence,quoteId="00000000-0000-0000-0000-000000000000",priceMinor=0})
 waitFor(function()return live.current().step>=s.step+2 end,8)
 check(live.current().fleet.units[wind].on==s.fleet.units[wind].on and live.current().fleet.units[wind].capKW==s.fleet.units[wind].capKW,"Malformed actual remote controls leave owned dispatch unchanged")
 check(live.current().finance.bank.windConstructionSpentMinor==capital and not live.current().suspended,"Malformed actual purchases cannot debit or suspend gameplay")
 app.actions[app.view.feedback.close]();app.view.root.Size=UDim2.fromScale(1,1);app.selectAsset(wind)
 print(if resumeBuilt then "[Owned fleet GUI post-purchase] PASS"else "[Owned fleet GUI journey] PASS",checks,"map",#app.view.map.root:GetDescendants(),"snapshot bytes",#json,"fake only; bound actions are not physical-device acceptance")
 return checks
end
