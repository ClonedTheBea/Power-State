--!strict
-- One map-owned immutable cosmetic cache. No persistence, world writes or gameplay arithmetic.
local Run=game:GetService("RunService")
local Assets=game:GetService("AssetService")
local Edges=require(script.Parent.ScreenGridEdges)
local Ocean=require(script.Parent.OceanBoundary)
local Ribbon=require(script.Parent.OrganicRibbon)
local Ground={}
local function smooth(t:number):number return t*t*(3-2*t) end
function Ground.attach(map:any,world:any,injected:any?)
 assert(Run:IsStudio() and game.GameId==10776833313 and game.CreatorId==149564436,"Test only")
 assert(#world.samples==289 and world.width==1024 and world.height==1024,"Bounded sector")
 assert(world.generationVersion==1 and world.climateVersion==1 and world.startTemplateVersion==1,"Known cosmetic field versions")
 -- A mounted map owns exactly one immutable sector cache. Remount destroys it;
 -- pan/zoom/mode changes reuse it, never regenerate or retain prior countries.
 local snapshot=table.clone(world);snapshot.samples={}
 for i,sample in world.samples do snapshot.samples[i]=table.freeze(table.clone(sample))end
 table.freeze(snapshot.samples);world=table.freeze(snapshot)
 local cacheKey=tostring(world.countryId)..":"..tostring(world.seed)..":sector0,0:g1:c1:t1:image82421581539732:colour2"
 map.root:SetAttribute("ContinuousGroundCacheKey",cacheKey)
 local cells:{ImageLabel}={};local colours:{Color3}={};local land:{boolean}={}
 map.terrain.replaceCells(function(old:GuiObject,i:number)
  local im=Instance.new("ImageLabel");im.Name=old.Name;im.BorderSizePixel=0
  im.BackgroundColor3=old.BackgroundColor3;im.BackgroundTransparency=old.BackgroundTransparency
  im.Size=old.Size;im.Position=old.Position;im.ZIndex=old.ZIndex;im.Visible=old.Visible;im.Parent=old.Parent
  im.ImageTransparency=1;im.Active=false;im.Selectable=false
  cells[i]=im;colours[i]=old.BackgroundColor3
  land[i]=world.samples[math.floor((i-1)/16)*17+(i-1)%16+1].elevationM>0
  return im
 end)
 local owned:{EditableImage}={};local chunks:{EditableImage}={}
 local state="Idle";local mode="Native";local destroyed=false;local cancelled=false
 local organic:any=nil;local generation=0;local restart=false
 local start:()->()
 local lastX=(map.root:GetAttribute("CameraX") or 0)::number
 local lastY=(map.root:GetAttribute("CameraY") or 0)::number
 local lastZ=(map.root:GetAttribute("CameraZoom") or 1)::number
 local lastSize=map.viewport.AbsoluteSize
 local viewportColour=map.viewport.BackgroundColor3
 local original=map.terrain.render
 local pendingLabels=false
 local pendingSince=0
 local preparationMonitor:RBXScriptConnection?=nil
 local function stopMonitor()
  if preparationMonitor then preparationMonitor:Disconnect();preparationMonitor=nil end
 end
 local function release()
  local releaseStart=os.clock();local released=#owned
  for _,im in cells do im.ImageContent=Content.none;im.ImageTransparency=1 end
  for _,e in owned do e:Destroy() end;table.clear(owned);table.clear(chunks)
  if released>0 then print("IW13_RESOURCE_RELEASE",game.HttpService:JSONEncode({images=released,bindingAndDestroyMs=(os.clock()-releaseStart)*1000,state=state}))end
 end
 local function draw()
  if destroyed then return end
  local active=state=="Ready" and mode~="Native" and map.root:GetAttribute("IllustratedActive")==true
  local ocean=active and (mode=="Ocean" or mode=="Organic")
  pendingLabels=false
  local xs,ys=Edges.axis(lastX,lastZ,16,64),Edges.axis(lastY,lastZ,16,64)
  for i,im in cells do
   local x,y=(i-1)%16,math.floor((i-1)/16)
   im.Visible=xs[x+2]>0 and ys[y+2]>0 and xs[x+1]<lastSize.X and ys[y+1]<lastSize.Y
   if active then
    im.Parent=map.viewport;im.Position=UDim2.fromOffset(xs[x+1],ys[y+1])
    im.Size=UDim2.fromOffset(xs[x+2]-xs[x+1],ys[y+2]-ys[y+1]);im.ZIndex=0
   else
    im.Parent=map.terrain.root;im.Position=UDim2.fromOffset(x*64,y*64);im.Size=UDim2.fromOffset(64,64);im.ZIndex=1
   end
   local wanted=active and (land[i] or ocean)
   if wanted and im.Visible and not im.IsLoaded then pendingLabels=true end
   im.ImageTransparency=if wanted then (if im.IsLoaded then 0 else .999) elseif state=="Loading" then .999 else 1
   im.BackgroundColor3=colours[i]
  end
  map.viewport.BackgroundColor3=if ocean then Ocean.DEEP else viewportColour
  map.root:SetAttribute("ContinuousGroundState",state);map.root:SetAttribute("ContinuousGroundActive",active)
  map.root:SetAttribute("ContinuousGroundMode",mode)
  map.root:SetAttribute("OrganicShoreActive",active and mode=="Organic")
  if pendingLabels then if pendingSince==0 then pendingSince=os.clock()end else pendingSince=0 end
 end
 map.terrain.render=function(x:number,y:number,z:number,size:Vector2)
  original(x,y,z,size);lastX=x;lastY=y;lastZ=z;lastSize=size;draw()
 end
 start=function()
  if state~="Idle" then return end;state="Loading";generation+=1;local thisGeneration=generation;local coast=organic;draw()
  map.root:SetAttribute("ContinuousGroundCacheKey",cacheKey..":coast"..(if coast then tostring(coast.version) else "0"))
  local started=os.clock();local cpu=0;local writes=0;local frames:{number}={}
  preparationMonitor=Run.RenderStepped:Connect(function(dt:number)if #frames<1200 then table.insert(frames,dt*1000)end end)
  task.delay(20,function()if generation==thisGeneration and tostring(state)=="Loading" then cancelled=true;state="TimedOut";stopMonitor();release();draw()end end)
  task.spawn(function()
   local ok,problem=xpcall(function()
    local source=if injected then injected.loadSource() else Assets:CreateEditableImageAsync(Content.fromUri("rbxassetid://82421581539732"))
    local sourceMs=(os.clock()-started)*1000
    if cancelled or destroyed then if source then source:Destroy()end;return false end
    assert(source,"Source allocation denied");table.insert(owned,source)
    assert(source.Size==Vector2.new(1024,1024),"Approved source size")
    local raw=source:ReadPixelsBuffer(Vector2.zero,source.Size)
    local material=buffer.create(256*256*4);local slice=os.clock()
    local function yieldWork()
     if os.clock()-slice>.001 then cpu+=os.clock()-slice;Run.Heartbeat:Wait();slice=os.clock()end
     assert(not cancelled and not destroyed,"Cancelled")
    end
    -- Exact 4x4 box prefilter: four source texels per world unit, no source alteration.
    for y=0,255 do for x=0,255 do
     local r,g,b=0,0,0
     for dy=0,3 do for dx=0,3 do local p=((y*4+dy)*1024+x*4+dx)*4
      r+=buffer.readu8(raw,p);g+=buffer.readu8(raw,p+1);b+=buffer.readu8(raw,p+2)
     end end
     local p=(y*256+x)*4;buffer.writeu8(material,p,math.floor(r/16+.5));buffer.writeu8(material,p+1,math.floor(g/16+.5));buffer.writeu8(material,p+2,math.floor(b/16+.5))
    end;yieldWork()end
    source:Destroy();table.remove(owned,1)
    local function field(x:number,y:number,key:string):number
     local ix,iy=math.min(math.floor(x/64),15),math.min(math.floor(y/64),15)
     local u,v=smooth((x-ix*64)/64),smooth((y-iy*64)/64)
     local a=world.samples[iy*17+ix+1];local b=world.samples[iy*17+ix+2]
     local c=world.samples[(iy+1)*17+ix+1];local d=world.samples[(iy+1)*17+ix+2]
     return (a[key]*(1-u)+b[key]*u)*(1-v)+(c[key]*(1-u)+d[key]*u)*v
    end
    for cy=0,1 do for cx=0,1 do
     local image=if injected and injected.createChunk then injected.createChunk() else Assets:CreateEditableImage({Size=Vector2.new(514,514)})
     assert(image,"Chunk allocation denied");table.insert(owned,image);table.insert(chunks,image)
     local pixels=buffer.create(514*514*4)
     local sample=if coast then Ribbon.rows(coast,cx*512-1,cy*512-1) else nil
     for py=0,513 do for px=0,513 do
      local wx,wy=cx*512+px-1,cy*512+py-1
      local x,y=math.clamp(wx+.5,0,1024),math.clamp(wy+.5,0,1024)
      local e=field(x,y,"elevationM");local high=smooth(math.clamp((e-30)/170,0,1))
      local dry=math.clamp((1000-field(x,y,"rainfallMm"))/1000+(field(x,y,"temperatureCentiC")/100-17)/60,-.15,.15)
      local coast=smooth(math.clamp((25-e)/25,0,1))*.35
      local m=((wy%256)*256+wx%256)*4
      local r,g,b=(107+19*high+9*dry)*(1-coast)+157*coast,(132+13*high+3*dry)*(1-coast)+155*coast,(99+12*high-5*dry)*(1-coast)+119*coast
      r+=buffer.readu8(material,m)-107;g+=buffer.readu8(material,m+1)-132;b+=buffer.readu8(material,m+2)-99
      local cellX,cellY=math.clamp(math.floor(wx/64),0,15),math.clamp(math.floor(wy/64),0,15)
      local isLand=land[cellY*16+cellX+1];local shore=0
      if sample then isLand,shore=sample(py,px) end
      if not isLand then
       -- Cosmetic continuous depth cue reads elevation only; never changes ownership.
       local shallow=smooth(math.clamp((e+65)/65,0,1));local grain=(buffer.readu8(material,m)-107)*.15
       r,g,b=Ocean.colour(x,y,shallow,grain)
      elseif sample then r,g,b=Ribbon.colour(shore,(buffer.readu8(material,m)-107)*.35,r,g,b) end
      -- Explicit opt-in high-contrast test of this exact chunk/crop/filter path.
      if injected and injected.maskDiagnostic==true then r=if isLand then 255 else 0;g=r;b=r end
      local p=(py*514+px)*4
      buffer.writeu8(pixels,p,math.clamp(math.floor(r+.5),0,255));buffer.writeu8(pixels,p+1,math.clamp(math.floor(g+.5),0,255));buffer.writeu8(pixels,p+2,math.clamp(math.floor(b+.5),0,255));buffer.writeu8(pixels,p+3,255)
     end;yieldWork()end
     local writeStart=os.clock();image:WritePixelsBuffer(Vector2.zero,image.Size,pixels);writes+=os.clock()-writeStart
     cpu+=os.clock()-slice;Run.RenderStepped:Wait();slice=os.clock() -- at most one changed image per frame
    end end
    local bindingStart=os.clock()
    for i,im in cells do local x,y=(i-1)%16,math.floor((i-1)/16)
     im.ImageContent=Content.fromObject(chunks[math.floor(y/8)*2+math.floor(x/8)+1])
     im.ImageRectOffset=Vector2.new(1+(x%8)*64,1+(y%8)*64);im.ImageRectSize=Vector2.new(64,64)
    end
    draw()
    for _=1,6 do Run.RenderStepped:Wait();assert(not cancelled and not destroyed,"Cancelled")end
    -- Actual content binding can be checked even while the Native background is retained.
    local visibleCount,loadedCount,visibleLoaded=0,0,0
    for _,im in cells do
     if im.IsLoaded then loadedCount+=1 end
     if im.Visible then visibleCount+=1;if im.IsLoaded then visibleLoaded+=1 end end
    end
    print("IW12C_BINDING",loadedCount,visibleCount,visibleLoaded)
    -- Culled labels intentionally report false. Visible cells must be ready;
    -- newly exposed cells keep their Native background until their own readiness.
    assert(visibleLoaded==visibleCount,"Visible ground label binding failed")
    state="Ready";table.sort(frames)
    print("IW12C_GROUND_READY",game.HttpService:JSONEncode({sourceMs=sourceMs,writeMs=writes*1000,bindingMs=(os.clock()-bindingStart)*1000,cpuMs=cpu*1000,elapsedMs=(os.clock()-started)*1000,frames=#frames,p95=frames[math.max(1,math.ceil(#frames*.95))],worst=frames[#frames],images=#owned,mapDescendants=#map.root:GetDescendants()}))
    return true
   end,debug.traceback)
   stopMonitor()
   if not ok then
    if not destroyed and tostring(state)~="TimedOut" then state="Failed"end
    release();warn("IW12C_GROUND_FAILED",problem)
   end
   if restart and not destroyed then restart=false;cancelled=false;state="Idle";start() else draw()end
  end)
 end
 local beat=Run.Heartbeat:Connect(function()
  if pendingLabels then
   if pendingSince>0 and os.clock()-pendingSince>=5 then state="Failed";release()end
   draw()
  end
 end)
 local artChange=map.root:GetAttributeChangedSignal("IllustratedActive"):Connect(draw)
 local function destroy()
  if destroyed then return end
  mode="Native";state="Destroyed";draw();destroyed=true;cancelled=true
  stopMonitor()
  map.terrain.render=original;release();map.viewport.BackgroundColor3=viewportColour
  beat:Disconnect()
  artChange:Disconnect()
 end
 map.root.Destroying:Once(destroy)
 return {setMode=function(value:string)
  assert(value=="Native" or value=="Ground" or value=="Ocean" or value=="Organic","Cosmetic mode only")
  mode=value;if value~="Native" then start()end;draw()
 end,setOrganic=function(value:any)
  if organic==value or state=="Failed" or state=="TimedOut" or destroyed then return end
  organic=value
  if state=="Loading" then cancelled=true;restart=true;return end
  release();cancelled=false;state="Idle"
 end,destroy=destroy,state=function()return state end,allocationCount=function()return #owned end,isPreparing=function()return preparationMonitor~=nil end,cells=cells}
end
return table.freeze(Ground)
