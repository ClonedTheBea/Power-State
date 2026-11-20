--!strict
-- Explicit isolated capability gate, never an ordinary terrain renderer.
if game.ReplicatedStorage:GetAttribute("RunGroundCapability")~=true then return end
local Run=game:GetService("RunService")
local Players=game:GetService("Players")
local Assets=game:GetService("AssetService")
local Edges=require(script.Parent.IllustratedWorld.ScreenGridEdges)
assert(Run:IsStudio() and game.GameId==10776833313 and game.CreatorId==149564436,"Test only")
local player=Players.LocalPlayer
assert(player.UserId==149564436,"Approved authenticated account only")
script:SetAttribute("ProbeStarted",true)
local allocated:{EditableImage}={}
local screen:ScreenGui?=nil
local expired=false
local frames:{number}={}
local memoryStart=game:GetService("Stats"):GetTotalMemoryUsageMb()
local frameConnection:RBXScriptConnection?=Run.RenderStepped:Connect(function(dt:number)
 if #frames<1200 then table.insert(frames,dt*1000) end
end)
local function cleanup()
 if frameConnection then frameConnection:Disconnect();frameConnection=nil end
 if screen then screen:Destroy();screen=nil end
 for _,e in allocated do e:Destroy() end
 table.clear(allocated)
 script:SetAttribute("AllocationCount",0)
end
local done=false
local start=os.clock()
task.spawn(function()
 local ok,problem=xpcall(function()
  local loadStart=os.clock()
  local source=Assets:CreateEditableImageAsync(Content.fromUri("rbxassetid://82421581539732"))
  if expired then if source then source:Destroy() end;return false end
  assert(source,"Source allocation denied")
  table.insert(allocated,source)
  assert(source.Size==Vector2.new(1024,1024),"Exact approved image size")
  local bytes=source:ReadPixelsBuffer(Vector2.zero,source.Size)
  local loadMs=(os.clock()-loadStart)*1000
  local chunks:{EditableImage}={};local cpu=0;local checks=0
  for cy=0,1 do for cx=0,1 do
   local e=Assets:CreateEditableImage({Size=Vector2.new(514,514)})
   assert(e,"514-square allocation denied; no resolution reduction")
   table.insert(allocated,e);table.insert(chunks,e)
   local pixels=buffer.create(514*514*4)
   local tick=os.clock()
   for y=0,513 do
    local sy=(cy*512+y-1)%1024
    for x=0,513 do
     local sx=(cx*512+x-1)%1024
     buffer.writeu32(pixels,(y*514+x)*4,buffer.readu32(bytes,(sy*1024+sx)*4))
    end
    if y%32==31 then cpu+=os.clock()-tick;Run.Heartbeat:Wait();tick=os.clock();assert(not expired,"Cancelled") end
   end
   cpu+=os.clock()-tick
   e:WritePixelsBuffer(Vector2.zero,e.Size,pixels)
   local read=e:ReadPixelsBuffer(Vector2.zero,e.Size)
   for i=0,514*514-1 do assert(buffer.readu32(read,i*4)==buffer.readu32(pixels,i*4),"Exact pixel write/read");checks+=1 end
  end end
  local gui=Instance.new("ScreenGui");screen=gui;gui.Name="GroundCapabilityProof";gui.IgnoreGuiInset=true;gui.DisplayOrder=100
  local title=Instance.new("TextLabel");title.Size=UDim2.fromOffset(1040,40);title.Text="TEST CAPABILITY ONLY: four padded chunks / 256 reused-slot analogue; no map integration"
  title.BackgroundColor3=Color3.fromRGB(11,20,32);title.TextColor3=Color3.new(1,1,1);title.TextSize=16;title.Parent=gui
  local images:{ImageLabel}={}
  for y=0,15 do for x=0,15 do
   local e=chunks[math.floor(y/8)*2+math.floor(x/8)+1]
   local im=Instance.new("ImageLabel");im.Name="Cell"..x.."_"..y;im.BackgroundTransparency=1;im.BorderSizePixel=0
   im.ImageContent=Content.fromObject(e);im.ImageRectOffset=Vector2.new(1+(x%8)*64,1+(y%8)*64);im.ImageRectSize=Vector2.new(64,64)
   im.Parent=gui
   table.insert(images,im)
  end end
  gui.Parent=player:WaitForChild("PlayerGui")
  local function place(z:number,ox:number,oy:number)
   local xs,ys=Edges.axis(ox,z,16,64),Edges.axis(oy,z,16,64)
   for i,im in images do
    local x,y=(i-1)%16+1,math.floor((i-1)/16)+1
    im.Position=UDim2.fromOffset(xs[x],ys[y]);im.Size=UDim2.fromOffset(xs[x+1]-xs[x],ys[y+1]-ys[y])
   end
  end
  place(.55,0,40)
  for _=1,6 do Run.RenderStepped:Wait() end
  local loaded=0;for _,im in images do if im.IsLoaded then loaded+=1 end end
  local record={loadMs=loadMs,cpuCopyMs=cpu*1000,wallMs=(os.clock()-start)*1000,pixelChecks=checks,labels=#images,loadedLabels=loaded,objects=#allocated}
  print("IW12B_CAPABILITY",game.HttpService:JSONEncode(record))
  assert(loaded==256,"All actual bindings must load")
  local coverage=0
  for _,z in {.55,.613,.72,.937,1,1.2,1.437,1.8} do
   for _,offset in {Vector2.new(0,40),Vector2.new(.37,40.61),Vector2.new(-127.83,-63.19),Vector2.new(13.5,-511.5)} do
    place(z,offset.X,offset.Y);Run.RenderStepped:Wait();Run.RenderStepped:Wait()
    for i,im in images do
     local x,y=(i-1)%16,math.floor((i-1)/16)
     if x<15 then assert(im.AbsolutePosition.X+im.AbsoluteSize.X==images[i+1].AbsolutePosition.X,"Horizontal coverage");coverage+=1 end
     if y<15 then assert(im.AbsolutePosition.Y+im.AbsoluteSize.Y==images[i+16].AbsolutePosition.Y,"Vertical coverage");coverage+=1 end
     assert(im.ImageRectSize==Vector2.new(64,64) and im.ImageRectOffset==Vector2.new(1+(x%8)*64,1+(y%8)*64),"Crops unchanged");coverage+=1
    end
   end
  end
  place(.55,0,40)
  print("IW12C_COVERAGE",coverage,"32 transforms; actual AbsolutePosition/Size; clipped negative positions included")
  gui:SetAttribute("CoveragePassed",true)
  table.sort(frames)
  print("IW12C_PREPARATION",game.HttpService:JSONEncode({frames=#frames,p50=frames[math.max(1,math.ceil(#frames*.5))],p95=frames[math.max(1,math.ceil(#frames*.95))],worst=frames[#frames],memoryStartMb=memoryStart,memoryReadyMb=game:GetService("Stats"):GetTotalMemoryUsageMb()}))
  if frameConnection then frameConnection:Disconnect();frameConnection=nil end
  -- Read-only flag control for the isolated screenshot; source/chunks never recreated on zoom.
  local zoomConnection=game.ReplicatedStorage:GetAttributeChangedSignal("GroundCapabilityZoom"):Connect(function()
   local z=game.ReplicatedStorage:GetAttribute("GroundCapabilityZoom")
   if type(z)~="number" or z<.55 or z>1.8 then return end
   local offset=game.ReplicatedStorage:GetAttribute("GroundCapabilityOffset")
   place(z,if typeof(offset)=="Vector2" then offset.X else 0,if typeof(offset)=="Vector2" then offset.Y else 40)
  end)
  gui.Destroying:Connect(function()zoomConnection:Disconnect()end)
  return true
 end,debug.traceback)
 if not ok then cleanup();warn("IW12B_CAPABILITY_FAIL",problem) end
 done=true
 script:SetAttribute("ProbeDone",true)
end)
task.delay(20,function()
 if done then return end
 expired=true;cleanup();warn("IW12B_CAPABILITY_TIMEOUT:20s; late source destroyed")
end)
game.ReplicatedStorage:GetAttributeChangedSignal("RunGroundCapability"):Connect(function()
 if game.ReplicatedStorage:GetAttribute("RunGroundCapability")~=true then expired=true;cleanup();print("IW12B_CAPABILITY_CLEANUP",#allocated) end
end)
