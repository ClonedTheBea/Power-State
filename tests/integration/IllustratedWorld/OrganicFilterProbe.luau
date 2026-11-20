--!strict
-- Diagnostic black/white coverage, not artwork acceptance. Same real chunk/filter path.
return function(gui:PlayerGui,fixture:any)
 assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
 local Run=game:GetService("RunService")
 local App=require(script.Parent.Parent.Parent.Client.Controllers.AppController)
 local Controller=require(script.Parent.IllustratedController)
 local old=gui:FindFirstChild("PowerStateShell");if old then old:Destroy()end
 local app=App.mount(gui,fixture)
 app.view.root.Size=UDim2.fromOffset(1366,704)
 local proof=Controller.attach(app,fixture,{maskDiagnostic=true,loadSource=function()
  return game:GetService("AssetService"):CreateEditableImageAsync(Content.fromUri("rbxassetid://82421581539732"))
 end})
 proof.setLandscapeMode("Organic")
 local deadline=os.clock()+20
 repeat Run.RenderStepped:Wait()until proof.ground().state()~="Loading" or os.clock()>deadline
 assert(proof.ground().state()=="Ready","Real filter probe ready")
 local function capture()
  local z=game.ReplicatedStorage:GetAttribute("OrganicProbeZoom") or .55
  assert(type(z)=="number" and z>=.55 and z<=1.8,"Supported zoom only")
  local map=app.view.map
  local adversarial=game.ReplicatedStorage:GetAttribute("OrganicProbeCase")==17
  if adversarial then
   map.render(math.floor(map.viewport.AbsoluteSize.X/2-320*z)+.55,math.floor(map.viewport.AbsoluteSize.Y/2-704*z)+.15,z)
  else map.render(map.viewport.AbsoluteSize.X/2-320*z+.37,map.viewport.AbsoluteSize.Y/2-832*z+.19,z)end
  for _,im in proof.renderer().images do im.Visible=false end
  -- Reproduce the rejected nearest-filter alternative without changing renderer defaults.
  for _,im in proof.ground().cells do
   im.ResampleMode=if game.ReplicatedStorage:GetAttribute("OrganicProbeNearest")==true
    then Enum.ResamplerMode.Pixelated else Enum.ResamplerMode.Default
  end
  local records={}
  for i,im in proof.ground().cells do
   if (i-1)%16>=3 and (i-1)%16<=5 and math.floor((i-1)/16)>=11 and math.floor((i-1)/16)<=13 then
    table.insert(records,{index=i,x=im.AbsolutePosition.X,y=im.AbsolutePosition.Y,w=im.AbsoluteSize.X,h=im.AbsoluteSize.Y})
   end
  end
  for _,r in records do print("IW14_FILTER_RECT",z,game.HttpService:JSONEncode(r))end
  print("IW14_FILTER_READY",z,if adversarial then "radius17 at320,704 SW land" else "radius18 at320,832 NW land","actual saved fixture; sample centres; viewport offset must be observed")
 end
 local change=game.ReplicatedStorage:GetAttributeChangedSignal("OrganicProbeZoom"):Connect(capture)
 local caseChange=game.ReplicatedStorage:GetAttributeChangedSignal("OrganicProbeCase"):Connect(capture)
 app.view.gui.Destroying:Once(function()change:Disconnect();caseChange:Disconnect()end)
 capture()
end
