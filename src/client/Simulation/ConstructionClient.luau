--!strict
local App=require(script.Parent.Parent.Controllers.AppController)
local ViewModel=require(script.Parent.LiveViewModel)
local C=require(script.Parent.Parent.Views.Components)
local Theme=require(script.Parent.Parent.Theme)
local Bank=require(script.Parent.BankPresentation)
local QuoteAction=require(script.Parent.ConstructionQuoteAction)
local Client={}
local mounted:any=nil
function Client.active():any return mounted end
function Client.mount(playerGui:PlayerGui)
 assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Construction Test only")
 local folder=game.ReplicatedStorage:WaitForChild("P3cConstruction",10);assert(folder,"Fake server not started")
 local remote=folder:WaitForChild("Snapshot") :: RemoteEvent
 local intent=folder:WaitForChild("Intent") :: RemoteEvent
 local current:any=nil;local app:any=nil;local received=0;local nextSequence=1;local destroyed=false
 local controlSequence=1
 local update:(()->())?=nil
 local loading=Instance.new("ScreenGui");loading.Name="CountryLoading";loading.ResetOnSpawn=false
 local loadingText=C.label(loading,"Loading your country · fake Test saves",18,Theme.text)
 loadingText.Size=UDim2.fromScale(1,1);loadingText.BackgroundColor3=Theme.background;loadingText.BackgroundTransparency=0
 loading.Parent=playerGui
 local loadState="Loading"
 local connection=remote.OnClientEvent:Connect(function(value:any)
  if destroyed or type(value)~="table" or value.version~=1 or value.profile~="P3c" then return end
  if value.loadState then loadState=value.loadState;loadingText.Text="Country "..loadState.." · fake Test saves";return end
  if current and (value.epoch~=current.epoch or value.revision<current.revision)then return end
  current=value;received=os.clock();controlSequence=math.max(controlSequence,value.nextSequence);nextSequence=math.max(nextSequence,value.construction.nextSequence)
  if update then update()end
 end)
 intent:FireServer({version=1,command="Subscribe"})
 local began=os.clock();local retryAt=began+1.1
 while not current and os.clock()-began<60 do
  task.wait(.1)
  if not current and os.clock()>=retryAt then
   intent:FireServer({version=1,command="Subscribe"});retryAt=os.clock()+1.1
  end
 end
 loading:Destroy()
 if not current then connection:Disconnect();intent:FireServer({version=1,command="Unsubscribe"});error("Country unavailable: "..loadState)end
 local existing=playerGui:FindFirstChild("PowerStateShell");if existing then existing:Destroy()end
 local preview=ViewModel.create(current)
 preview.metrics[1].label="BANK · LIVE";preview.metrics[1].detail="Fake storage · confirmed checkpoint shown in review"
 preview.metrics[4].label="CUSTOMERS";preview.metrics[4].detail="District joins after confirmation"
 preview.metrics[1].currencyMinor=current.bankMinor;preview.metrics[1].value=Bank.compact(current)
 local p=current.proposedNode
 table.insert(preview.nodes,{id=p.id,name=p.name,kind="Settlement",x=p.x,y=p.y,description="Surveyed district · preview only until saved"})
 table.insert(preview.links,{from=current.proposedLine.from,to=p.id})
 app=App.mount(playerGui,preview)
 local view=app.view

 local playable:any=nil
 local directory:any=nil
 local button=C.button(view.inspector.note.Parent,"Review connection")
 button.Size=UDim2.new(1,-8,0,44);button.LayoutOrder=3;button.ZIndex=11
 local confirm=C.button(view.feedback.root,"Build for 1,000 Credits")
 confirm.Size=UDim2.new(1,-32,0,44);confirm.Position=UDim2.new(0,16,1,-60);confirm.ZIndex=32
 local categories=require(script.Parent.Parent.Views.ProjectCategories).create(app,"ConstructionOverview",confirm)
 local scroll=view.feedback.root:FindFirstChild("Message") :: ScrollingFrame
 -- Shared FeedbackView owns full-string sizing for construction and Bank alike.
 local function send(command:string)
  local sequence=nextSequence;nextSequence+=1
  intent:FireServer({version=1,epoch=current.epoch,sequence=sequence,command=command,quoteId=if command=="Confirm"then current.construction.quoteId else nil})
 end
 local descriptions={Available="Available to build",InsufficientCredits="Not enough Credits",QuoteExpired="Quote expired — refresh to review a new quote",
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
  button.Visible=app.state.selectedId==p.id
  button.Active=healthy;button.Selectable=healthy
  for i,line in view.map.linkFrames do
   line.BackgroundTransparency=if i==3 and not current.built then .8 else .15
   line:SetAttribute("PreviewOnly",i==3 and not current.built)
  end
  view.map.markers[p.id]:SetAttribute("AccessibleLabel",label)
  confirm.Visible=view.feedback.root:GetAttribute("ConstructionOverview")==true
  local action=QuoteAction.resolve(current,healthy,os.clock()-received)
  confirm.Active=action~="Disabled";confirm.Selectable=confirm.Active
  C.action(confirm,if confirm.Active then "financial" else "secondary")
  confirm.Text=if current.built then "Connected · saved in this Test server"elseif current.construction.state=="Saving" then "Checking saved result…"elseif action=="Quote" then "Refresh Quote"else "Build for 1,000 Credits"
  confirm:SetAttribute("AccessibleLabel",confirm.Text)
  if view.feedback.root.Visible and confirm.Visible then
   scroll.Size=UDim2.new(1,-32,1,-140);view.feedback.updateDetails(text())
  elseif view.feedback.root.Visible and view.feedback.root:GetAttribute("ConstructionBank")==true then
   scroll.Size=UDim2.new(1,-32,1,-76)
   view.feedback.updateDetails(Bank.text(current)..string.format("\n\nConstruction spending: %.2f Credits (capital; excluded from operating net)",current.finance.bank.constructionSpentMinor/100))
  end
  categories.refresh()
  if playable then playable.refresh()end
  if directory then directory.refresh()end
 end
 app.bind(button,function()
  send("Quote");app.showFeedback("Connect new district",text(),button,"info")
  view.feedback.root:SetAttribute("ConstructionBank",false);view.feedback.root:SetAttribute("ConstructionOverview",true);refresh()
 end)
 app.actions[view.kpis.buttons[1]]=function()
  view.feedback.root:SetAttribute("ConstructionOverview",false);view.feedback.root:SetAttribute("ConstructionBank",true)
  app.showFeedback("Bank · Test session",Bank.text(current),view.kpis.buttons[1]);refresh()
 end
 app.bind(confirm,function()
  if not confirm.Active then return end
  -- Re-evaluate at activation: a key press can race the last displayed snapshot.
  local action=QuoteAction.resolve(current,os.clock()-received<3,os.clock()-received)
  if action=="Disabled"then return end
  send(action);confirm.Active=false;confirm.Selectable=false
 end)
 local function requestToggle()
  if os.clock()-received>=3 or current.suspended then return end
  local sequence=controlSequence;controlSequence+=1
  intent:FireServer({version=1,kind="SetGenerator",epoch=current.epoch,sequence=sequence,revision=current.controlRevision,assetId=current.generatorId,online=not current.online})
 end
 playable=require(script.Parent.PlayablePresentation).attach(app,function()return current end,function()return os.clock()-received<3 end,requestToggle,function()app.actions[button]()end)
 view.navigation.buttons.Build:SetAttribute("LabelOverride","Build")
 view.drawer.buttons.Build.Text="Build";view.drawer.buttons.Infrastructure.Text="Infrastructure"
 directory=require(script.Parent.InfrastructureDirectory).create(app,function()return current end,requestToggle,function()return os.clock()-received<3 end)
 update=function()app.present()end
 app.setPresenter(refresh)
 local beat=game:GetService("RunService").Heartbeat:Connect(function()if os.clock()-received>=3 or (confirm.Visible and view.feedback.root.Visible and current.construction.expiresIn>0 and os.clock()-received>=current.construction.expiresIn)then refresh()end end)
 local function cleanup()
  if destroyed then return end;destroyed=true;mounted=nil
  intent:FireServer({version=1,command="Unsubscribe"});connection:Disconnect();beat:Disconnect();update=nil
 end
 view.gui.Destroying:Once(cleanup)
 mounted={app=app,directory=directory,button=button,confirm=confirm,toggle=playable.toggle,requestToggle=requestToggle,current=function()return current end,
  destroy=function()cleanup();app.destroy()end}
 return mounted
end
return table.freeze(Client)
