--!strict
local App=require(script.Parent.Parent.Controllers.AppController)
local ViewModel=require(script.Parent.LiveViewModel)
local C=require(script.Parent.Parent.Views.Components)
local Theme=require(script.Parent.Parent.Theme)
local Bank=require(script.Parent.BankPresentation)
local Client={}
function Client.mount(playerGui:PlayerGui)
 assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Construction Test only")
 local folder=game.ReplicatedStorage:WaitForChild("P3cConstruction",10);assert(folder,"Fake server not started")
 local remote=folder:WaitForChild("Snapshot") :: RemoteEvent
 local intent=folder:WaitForChild("Intent") :: RemoteEvent
 local current:any=nil;local app:any=nil;local received=0;local nextSequence=1;local destroyed=false
 local update:(()->())?=nil
 local connection=remote.OnClientEvent:Connect(function(value:any)
  if destroyed or type(value)~="table" or value.version~=1 or value.profile~="P3c" then return end
  if current and (value.epoch~=current.epoch or value.revision<current.revision)then return end
  current=value;received=os.clock();nextSequence=math.max(nextSequence,value.construction.nextSequence)
  if update then update()end
 end)
 intent:FireServer({version=1,command="Subscribe"})
 local began=os.clock();local retryAt=began+1.1
 while not current and os.clock()-began<10 do
  task.wait(.1)
  if not current and os.clock()>=retryAt then
   intent:FireServer({version=1,command="Subscribe"});retryAt=os.clock()+1.1
  end
 end
 if not current then connection:Disconnect();error("Construction snapshot unavailable")end
 local existing=playerGui:FindFirstChild("PowerStateShell");if existing then existing:Destroy()end
 local preview=ViewModel.create(current)
 preview.metrics[1].label="BANK · LIVE";preview.metrics[1].detail="Fake storage · confirmed checkpoint shown in review"
 preview.metrics[1].currencyMinor=current.bankMinor;preview.metrics[1].value=Bank.compact(current)
 local p=current.proposedNode
 table.insert(preview.nodes,{id=p.id,name=p.name,kind="Settlement",x=p.x,y=p.y,description="Surveyed district · preview only until saved"})
 table.insert(preview.links,{from=current.proposedLine.from,to=p.id})
 app=App.mount(playerGui,preview)
 local view=app.view
 local button=C.button(view.inspector.note.Parent,"Review connection")
 button.Size=UDim2.new(1,-8,0,44);button.LayoutOrder=3;button.ZIndex=11
 local confirm=C.button(view.feedback.root,"Build for 1,000 Credits")
 confirm.Size=UDim2.new(1,-32,0,44);confirm.Position=UDim2.new(0,16,1,-60);confirm.ZIndex=32
 local scroll=view.feedback.root:FindFirstChild("Message") :: ScrollingFrame
 local body=scroll:FindFirstChildWhichIsA("TextLabel") :: TextLabel
 -- Measure the full string: live TextBounds can reflect the clipped viewport.
 scroll.AutomaticCanvasSize=Enum.AutomaticSize.None
 body.AutomaticSize=Enum.AutomaticSize.None
 local function resizeCanvas()
  local width=math.max(1,scroll.AbsoluteSize.X-8)
  local bounds=game:GetService("TextService"):GetTextSize(body.Text,body.TextSize,body.Font,Vector2.new(width,100000))
  body.Size=UDim2.new(1,-8,0,bounds.Y+4);scroll.CanvasSize=UDim2.fromOffset(0,bounds.Y+12)
 end
 local canvasConnections={body:GetPropertyChangedSignal("Text"):Connect(resizeCanvas),body:GetPropertyChangedSignal("TextSize"):Connect(resizeCanvas),scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeCanvas)}
 resizeCanvas()
 local function send(command:string)
  local sequence=nextSequence;nextSequence+=1
  intent:FireServer({version=1,epoch=current.epoch,sequence=sequence,command=command,quoteId=if command=="Confirm"then current.construction.quoteId else nil})
 end
 local descriptions={Available="Available to build",InsufficientCredits="Not enough Credits",QuoteExpired="Quote expired — review again",
  Saving="Saving construction — checking result",Built="District connected and saved",AlreadyBuilt="Already built",Unavailable="Outcome unavailable — do not repurchase",DrainingSave="Waiting for current save — review again"}
 local function text():string
  local status=current.construction
  local spending=if current.built then "Paid once: 1,000 Credits. No further purchase."
   elseif current.bankMinor<125000 then string.format("Additional earnings needed: %.2f Credits",(125000-current.bankMinor)/100)
   else string.format("After purchase: %.2f Credits",(current.bankMinor-100000)/100)
  return string.format("%s\n\nPrice: 1,000 Credits\nLive Bank: %.2f Credits\nLast confirmed: %.2f Credits\n%s\nOperating buffer: 250 Credits\n\nConnect a fixed 250-resident-equivalent district using spare capacity. Peak total: 4.764 / 5 MW. Estimated added net: 754.70 Credits per simulated day; actual delivery determines earnings.\n\nFake storage only. Closing this panel cannot cancel a submitted purchase.",descriptions[status.state] or status.state,current.bankMinor/100,(current.save.savedBankMinor or 0)/100,spending)
 end
 local function refresh()
  local healthy=os.clock()-received<3
  view.header.status.Text=if not healthy then "Construction data unavailable" elseif current.suspended then "Construction · simulation suspended" else "P3c · Fake storage"
  view.header.identity.Text=string.format("%s · %.2f / %.2f MW",Bank.compact(current),current.report.deliveredMW,current.report.demandMW)
   view.kpis.cards[1].value.Text=Bank.compact(current)
  view.kpis.cards[2].value.Text=string.format("%.3f / %.3f MW",current.report.deliveredMW,current.report.demandMW)
  view.kpis.cards[3].value.Text=if current.reliability>=0 then string.format("%.1f%% · %d min",current.reliability*100,current.historyMinutes)else "Unknown"
  view.kpis.cards[4].value.Text=if current.built then "1,000 + 250"else "1,000"
  local label=if current.built then "Connected district"else "Surveyed district · preview"
  view.inspector.title.Text=if app.state.selectedId==p.id then p.name else "District connection"
  view.inspector.tag.Text="P3c · Fake storage"
  view.inspector.body.Text=string.format("%s\n1 MW feeder · 250 resident-equivalent customers\nPrice: 1,000 Credits · keep 250 Credits\nLive Bank: %.2f Credits",descriptions[current.construction.state] or current.construction.state,current.bankMinor/100)
  view.inspector.note.Text=label..". "..(if current.built then "Paid once; electricity bills follow actual delivery."else "No new demand before durable completion.")
  button.Text=if current.built then "View saved connection"else "Review connection"
  button.Active=healthy;button.Selectable=healthy
  for i,line in view.map.linkFrames do
   line.BackgroundTransparency=if i==3 and not current.built then .8 else .15
   line:SetAttribute("PreviewOnly",i==3 and not current.built)
  end
  view.map.markers[p.id]:SetAttribute("AccessibleLabel",label)
  confirm.Visible=view.feedback.root:GetAttribute("ConstructionOverview")==true
  confirm.Active=healthy and current.construction.state=="Available" and not current.suspended and current.bankMinor>=125000 and current.construction.expiresIn>0
  confirm.Selectable=confirm.Active
  confirm.BackgroundColor3=if confirm.Active then Theme.raised else Theme.panel
  confirm.Text=if current.construction.state=="Saving" then "Checking saved result…"else "Build for 1,000 Credits"
  if view.feedback.root.Visible and confirm.Visible then
   scroll.Size=UDim2.new(1,-32,1,-140);view.feedback.updateText(text())
  elseif view.feedback.root.Visible and view.feedback.root:GetAttribute("ConstructionBank")==true then
   scroll.Size=UDim2.new(1,-32,1,-76)
   view.feedback.updateText(Bank.text(current)..string.format("\n\nConstruction spending: %.2f Credits (capital; excluded from operating net)",current.finance.bank.constructionSpentMinor/100))
  end
 end
 app.bind(button,function()
  send("Quote");app.showFeedback("Connect new district",text(),button,"info")
  view.feedback.root:SetAttribute("ConstructionBank",false);view.feedback.root:SetAttribute("ConstructionOverview",true);refresh()
 end)
 app.actions[view.kpis.buttons[1]]=function()
  view.feedback.root:SetAttribute("ConstructionOverview",false);view.feedback.root:SetAttribute("ConstructionBank",true)
  app.showFeedback("Bank · fake construction proof",Bank.text(current),view.kpis.buttons[1]);refresh()
 end
 app.bind(confirm,function()if confirm.Active then send("Confirm");confirm.Active=false;confirm.Selectable=false end end)
 update=function()app.refresh()end
 app.setPresenter(refresh)
 local beat=game:GetService("RunService").Heartbeat:Connect(function()if os.clock()-received>=3 then refresh()end end)
 local function cleanup()
  if destroyed then return end;destroyed=true
  intent:FireServer({version=1,command="Unsubscribe"});connection:Disconnect();beat:Disconnect();for _,c in canvasConnections do c:Disconnect()end;update=nil
 end
 view.gui.Destroying:Once(cleanup)
 return {app=app,button=button,confirm=confirm,current=function()return current end,
  destroy=function()cleanup();app.destroy()end}
end
return table.freeze(Client)
