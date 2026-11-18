--!strict
return function(playerGui:PlayerGui,bankOnly:boolean?,legacyTiming:boolean?)
 assert(game.GameId==10776833313 and game:GetService("RunService"):IsStudio(),"Test only")
 if not bankOnly then
  require(script.Parent["P2b.spec"])(playerGui,"P3b")
  require(script.Parent["P2aRemote.spec"])("P3b")
 end
 local Client=require(script.Parent.Parent.Client.Simulation.SimulationClient)
 local Format=require(script.Parent.Parent.Client.Simulation.BankPresentation)
 local existing=playerGui:FindFirstChild("PowerStateShell");if existing then existing:Destroy()end
 local live=Client.mount(playerGui,"P3b");local checks=0
 local function check(ok:boolean,msg:string)assert(ok,msg);checks+=1 end
 local app=live.app
 for _,size in {{1366,704},{360,580},{640,300},{768,960}}do
  app.view.root.Size=UDim2.fromOffset(size[1],size[2]);task.wait(.2)
  app.selectAsset(live.current().generatorId)
  local camera=app.view.map.root:GetAttribute("CameraX")
  local selected=app.state.selectedId
  app.actions[app.view.kpis.buttons[1]]()
  check(app.view.feedback.root.Visible and app.view.feedback.root:GetAttribute("BankOverview")==true,"Bank opens in responsive shell")
  check(app.view.feedback.close.AbsoluteSize.X>=44 and app.view.feedback.close.AbsoluteSize.Y>=44,"Accessible dismissal")
  local text=Format.text(live.current())
  for _,label in {"Live Bank:","Last confirmed:","Electricity sales:","Variable generation costs","Fixed running costs:","Net earnings:","Operating buffer:","Hourly statements","Fake storage"}do check(string.find(text,label,1,true)~=nil,"Financial disclosure: "..label)end
  local Trace=require(game.ReplicatedStorage.Shared.Util.SnapshotTrace)
  local initial=live.current();local expectedStep=initial.step+1;local expectedRevision=initial.revision+1
  local began=os.clock();Trace.record("test:begin",initial,expectedRevision)
  if legacyTiming then
   -- Retained unchanged for reproducing the original failure, never reported as corrected acceptance.
   task.wait(1.2);Trace.record("test:after1.2",live.current());Trace.dump("original-1.2")
   check(live.current().step>initial.step,"Bank does not pause simulation")
  else
   -- Two independent <=1s schedules plus delivery/frame allowance. See D118.
   -- This is a liveness deadline, not a 3s latency target or a change to gameplay clocks.
   local deadline=began+3
   while (live.current().step<expectedStep or live.current().revision<expectedRevision) and os.clock()<deadline do
    game:GetService("RunService").Heartbeat:Wait()
   end
   local observed=live.current();local latency=os.clock()-began
   print(string.format("[P3b.1 Bank progression] %dx%d initial step/rev %d/%d expected >=%d/%d observed %d/%d wait %.4fs exceeds1.2=%s",size[1],size[2],initial.step,initial.revision,expectedStep,expectedRevision,observed.step,observed.revision,latency,tostring(latency>1.2)))
   Trace.record("test:progressed",observed,latency)
   check(latency<=3 and observed.step>=expectedStep and observed.revision>=expectedRevision,"Authoritative Bank progression deadline")
   check(observed.epoch==initial.epoch and observed.finance.economy.lastSettledStep==observed.step,"Same session and settled financial cursor")
   check(observed.bankMinor>initial.bankMinor,"Funded served interval changes Bank")
   check(app.view.kpis.cards[1].value.Text==Format.compact(observed),"KPI matches accepted snapshot")
   local rendered=false
   for _,obj in app.view.feedback.root:GetDescendants()do
    if obj:IsA("TextLabel") and string.sub(obj.Text,1,10)=="Live Bank:" then
     check(obj.Text==Format.text(observed),"Rendered overview matches accepted finances and step");rendered=true
    end
   end
   check(rendered,"Actual Bank overview text inspected")
  end
  check(app.view.map.root:GetAttribute("CameraX")==camera and app.state.selectedId==selected,"Bank preserves camera/selection")
  app.actions[app.view.feedback.close]()
 end
 local current=live.current();local saved=current.save.state;local suspended=current.suspended
 for _,status in {"Live","Saving","Delayed","Suspended"}do
  current.save.state=status;current.suspended=status=="Suspended";app.refresh()
  check(string.find(Format.text(current),status,1,true)~=nil,"Synthetic save status presentation")
  if current.suspended then check(not live.toggle.Active,"Suspended control disabled")end
 end
 current.save.state=saved;current.suspended=suspended;app.refresh()
 local encoded=game:GetService("HttpService"):JSONEncode(current)
 for _,private in {"ownerSessionId","expiresAtUtcMs","activationOperationId","lastCommit","sessionEpoch"}do check(not string.find(encoded,private,1,true),"Private storage field excluded")end
 check(current.finance.economy.bonusSalesMinor==0 and current.save.storage=="Fake","No entitlement or real storage")
 app.view.root.Size=UDim2.fromScale(1,1);app.actions[app.view.header.overview]()
 print(string.format("[P3b Bank GUI] PASS %d assertions; status faults synthetic; actual server uses fake storage",checks))
 return live
end
