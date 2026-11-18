--!strict
return function(playerGui:PlayerGui)
 local Client=require(script.Parent.Parent.Client.Simulation.ConstructionClient)
 local Policy=require(script.Parent.Parent.Client.Simulation.ConstructionQuoteAction)
 local live=Client.active() or Client.mount(playerGui);local app=live.app
 local checks=0;local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 local function waitFor(fn:()->boolean,seconds:number)
  local deadline=os.clock()+seconds;repeat task.wait(.05)until fn() or os.clock()>deadline;check(fn(),"Quote refresh deadline")
 end
 local sample={built=false,suspended=false,bankMinor=125000,construction={state="Available",quoteId="test",expiresIn=1}}
 check(Policy.resolve(sample,true,.999)=="Confirm","Live quote")
 check(Policy.resolve(sample,true,1)=="Quote","Exact local expiry cannot confirm")
 check(Policy.resolve(sample,false,0)=="Disabled","Stale snapshots cannot refresh")
 sample.construction.state="Unavailable";check(Policy.resolve(sample,true,0)=="Disabled","Uncertain purchase cannot refresh")
 sample.construction.state="Saving";check(Policy.resolve(sample,true,0)=="Disabled","Pending purchase cannot refresh")
 sample.construction.state="InsufficientCredits";check(Policy.resolve(sample,true,0)=="Quote","Earnings allow fresh eligibility review")
 sample.built=true;check(Policy.resolve(sample,true,0)=="Disabled","Built cannot repurchase")
 assert(not live.current().built,"Fresh unbuilt fake session required")
 app.selectAsset(live.current().proposedNode.id);app.actions[live.button]()
 waitFor(function()return live.current().construction.quoteId~=nil end,3)
 local old=live.current().construction.quoteId;local step=live.current().step
 waitFor(function()return live.current().construction.state=="QuoteExpired"end,33)
 check(app.view.feedback.root.Visible,"Menu stays open past server expiry")
 check(live.confirm.Active and live.confirm.Selectable and live.confirm.Text=="Refresh Quote","Expired quote exposes accessible refresh")
 check(live.current().step>step,"Open review never pauses simulation")
 for _,size in {Vector2.new(1366,704),Vector2.new(768,960),Vector2.new(360,580),Vector2.new(640,300)}do
  app.view.root.Size=UDim2.fromOffset(size.X,size.Y);app.refresh();task.wait(.1)
  check(live.confirm.AbsoluteSize.Y>=44 and live.confirm.Visible and live.confirm.Selectable,"Refresh target retained across safe roots")
 end
 app.view.root.Size=UDim2.fromScale(1,1);app.refresh()
 local selected=game:GetService("GuiService");selected.SelectedObject=live.confirm;task.wait()
 check(selected.SelectedObject==live.confirm,"Same valid keyboard/gamepad target")
 app.actions[live.confirm]()
 waitFor(function()return live.current().construction.quoteId~=old and live.current().construction.expiresIn>0 end,3)
 check(app.view.feedback.root.Visible and not live.current().built,"Refresh preserves panel and does not purchase")
 check(live.current().finance.bank.constructionSpentMinor==0,"Refresh never debits capital")
 print(string.format("[Quote Refresh GUI] PASS: %d assertions; real 30-second server expiry, fake storage",checks))
end
