--!strict
-- Opt-in visual evidence only. The insufficient-money panel is explicitly a presentation fixture.
if game.ReplicatedStorage:GetAttribute("ReinforcementTests") ~= "Capture" then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
local R=game:GetService("RunService"); local start=os.clock()
while game.ReplicatedStorage:GetAttribute("ReinforcementReady")~=true do assert(os.clock()-start<60);task.wait(.1) end
require(script.Parent["Operations.spec"])()
local Client=script.Parent.Parent.Client
local live=require(Client.Simulation.OperationsClient).active()
local app=live.app
local C=require(Client.Views.Components); local Feedback=require(Client.Views.FeedbackView)
local fixture=Instance.new("ScreenGui");fixture.Name="ReinforcementPresentationFixture";fixture.DisplayOrder=100;fixture.Parent=game.Players.LocalPlayer.PlayerGui
local root=C.frame(fixture,"Fixture",Color3.fromRGB(15,23,35));root.Size=UDim2.fromScale(1,1)
local banner=C.label(root,"LOCAL PRESENTATION FIXTURE · no financial mutation or purchase sent",18)
banner.Position=UDim2.fromOffset(16,20);banner.Size=UDim2.new(1,-32,0,50)
local feedback=Feedback.create(root);feedback.root.AnchorPoint=Vector2.new(.5,.5);feedback.root.Position=UDim2.fromScale(.5,.5);feedback.root.Size=UDim2.fromOffset(480,380)
local hidden=C.frame(root,"Hidden",Color3.new());hidden.Visible=false
local note=C.label(hidden,"",12)
local snapshot={bankMinor=74999,savedBankMinor=74999,capitalExpenseMinor=0,eastCapacityKW=3000,saving=false,saveBlocked=false,
	investment={built=false,pending=false,outcome="InsufficientFunds",quoteRemaining=0}}
local proxy:any={view={feedback=feedback,inspector={note=note}},state={},actions={}}
proxy.bind=function(button:any,callback:any) proxy.actions[button]=callback end
proxy.showFeedback=function(title:string,body:string) feedback.show("notice",title,body) end
local view=require(Client.Simulation.ReinforcementView).create(proxy,{panel=hidden},function()return snapshot end,function()return 0 end,function()end)
view.open(view.review)
R.RenderStepped:Wait();R.RenderStepped:Wait();view.refresh()
assert(view.confirm.Text=="Refresh Quote" and view.confirm.AbsoluteSize.Y>=44,"Insufficient fixture retains accessible refresh")
print("[Reinforcement capture] INSUFFICIENT fixture visible for25 seconds")
task.wait(25);fixture:Destroy()
local function ready() return not live.current().saving and live.current().status~="Pending" end
start=os.clock();while not ready() do assert(os.clock()-start<5);R.Heartbeat:Wait()end
app.navigate("Map");app.selectAsset("b");app.actions[live.investment.inspect]()
start=os.clock();while not live.current().investment.quoteId do assert(os.clock()-start<5);R.Heartbeat:Wait()end
print("[Reinforcement capture] ACTUAL PROPOSAL visible for15 seconds")
task.wait(15)
app.actions[live.investment.confirm]()
start=os.clock();while not live.current().investment.built do assert(os.clock()-start<20,"Bounded12-second fake response");R.Heartbeat:Wait()end
print("[Reinforcement capture] ACTUAL CONFIRMED visible for25 seconds")
local samples={}
for _=1,100 do local at=os.clock();app.refresh();table.insert(samples,(os.clock()-at)*1000);R.RenderStepped:Wait()end
table.sort(samples)
print(string.format("[Reinforcement GUI timing] refresh p50 %.3f / p95 %.3f / max %.3f ms; desktop Studio",samples[50],samples[95],samples[100]))
task.wait(25)
print("[Reinforcement capture] COMPLETE; fixture destroyed, real fake Training purchase retained")
