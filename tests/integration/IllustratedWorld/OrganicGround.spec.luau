--!strict
return function(gui:PlayerGui,fixtures:{any})
 local Run=game:GetService("RunService")
 local App=require(script.Parent.Parent.Parent.Client.Controllers.AppController)
 local Controller=require(script.Parent.IllustratedController)
 local checks=0
 local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 local function settle()for _=1,6 do Run.RenderStepped:Wait()end end
 for fi,f in fixtures do
  local old=gui:FindFirstChild("PowerStateShell");if old then old:Destroy()end
  local before=game.HttpService:JSONEncode(f)
  local app=App.mount(gui,f);settle();local proof=Controller.attach(app,f)
  app.selectAsset(f.nodes[1].id);local map=app.view.map
  local camera={map.root:GetAttribute("CameraX"),map.root:GetAttribute("CameraY"),map.root:GetAttribute("CameraZoom")}
  proof.setLandscapeMode("Organic")
  local deadline=os.clock()+20
  repeat Run.RenderStepped:Wait() until proof.ground().state()~="Loading" or os.clock()>deadline
  check(proof.ground().state()=="Ready","Organic preparation within unchanged deadline")
  settle();check(map.root:GetAttribute("OrganicShoreActive")==true,"Organic actually visible")
  check(proof.ground().allocationCount()==4,"Four images only")
  check(#map.root:GetDescendants()<=600,"Map resource ceiling")
  for _,entry in proof.renderer().entries()do check(not string.find(entry.id,"shore:",1,true),"No incompatible categorical shore above curves")end
  for _,size in {Vector2.new(1366,560),Vector2.new(820,560),Vector2.new(360,560),Vector2.new(740,320)} do
   app.view.root.Size=UDim2.fromOffset(size.X,size.Y);settle()
   for _,z in {.55,.72,1,1.2,1.8,.937}do
    map.render(-127.83,-63.19,z);settle()
    check(proof.ground().allocationCount()==4,"Movement reuses images")
    check(#map.root:GetDescendants()<=600,"Movement remains bounded")
    for i,im in proof.ground().cells do
     if i%16~=0 then check(im.AbsolutePosition.X+im.AbsoluteSize.X==proof.ground().cells[i+1].AbsolutePosition.X,"Shared fractional horizontal edge")end
     if i<=240 then check(im.AbsolutePosition.Y+im.AbsoluteSize.Y==proof.ground().cells[i+16].AbsolutePosition.Y,"Shared fractional vertical edge")end
    end
    check(app.state.selectedId==f.nodes[1].id,"Selection preserved")
   end
  end
  map.render(camera[1],camera[2],camera[3]);settle()
  app.showFeedback("Construction boundary check","Exact Native geography during review",app.view.drawer.buttons.Geography);settle()
  check(map.root:GetAttribute("OrganicShoreActive")==false and map.root:GetAttribute("IllustratedActive")==false,"Review exposes exact Native ownership")
  app.view.feedback.root.Visible=false;settle()
  check(map.root:GetAttribute("OrganicShoreActive")==true,"Close review restores cached cosmetic mode")
  check(before==game.HttpService:JSONEncode(f),"Saved descriptor unchanged")
  local cells=table.clone(proof.ground().cells)
  for _,mode in {"Ocean","Organic","Native","Organic"}do
   proof.setLandscapeMode(mode)
   local untilTime=os.clock()+20
   while proof.ground().state()=="Loading" and os.clock()<untilTime do Run.RenderStepped:Wait()end
   check(proof.ground().state()=="Ready","Variant readiness without second image pool")
   settle()
   for i,cell in cells do check(proof.ground().cells[i]==cell,"Variant reuses exact terrain instances")end
   check(app.state.selectedId==f.nodes[1].id,"Variant preserves selection")
   check(map.root:GetAttribute("CameraX")==camera[1] and map.root:GetAttribute("CameraY")==camera[2] and map.root:GetAttribute("CameraZoom")==camera[3],"Variant preserves camera")
  end
  print("IW14_ORGANIC_FIXTURE",fi,checks,#map.root:GetDescendants())
  app.destroy();check(proof.ground().allocationCount()==0,"Cleanup destroys all images")
 end
 print("IW14_ORGANIC_PASS",checks)
end
