--!strict
-- Bounded observation, not causal attribution. No forced GC or microprofiler settings.
local Run=game:GetService("RunService")
local Stats=game:GetService("Stats")
local Probe={}
function Probe.start(map:any)
 local phase="idle";local workMs=0;local workAt=0;local frames:{number}={};local events:{any}={}
 local start=os.clock();local memory=Stats:GetTotalMemoryUsageMb();local lua=gcinfo()
 local connection=Run.RenderStepped:Connect(function(dt:number)
  if #frames<72000 then frames[#frames+1]=dt*1000 end
  if dt>.05 and #events<64 then
   events[#events+1]={at=os.clock()-start,dtMs=dt*1000,phase=phase,lastWorkMs=workMs,workAgeMs=if workAt>0 then (os.clock()-workAt)*1000 else -1,
    groundState=map.root:GetAttribute("ContinuousGroundState"),mode=map.root:GetAttribute("ContinuousGroundMode"),
    illustrated=map.root:GetAttribute("IllustratedActive"),descendants=#map.root:GetDescendants(),luaKb=gcinfo(),totalMb=Stats:GetTotalMemoryUsageMb()}
  end
 end)
 return {phase=function(value:string)phase=value end,work=function(ms:number)workMs=ms;workAt=os.clock()end,
  finish=function()
   connection:Disconnect();table.sort(frames)
   -- Studio truncates long output lines. Keep every bounded event independently readable.
   for i,event in events do print("IW13_LONG_FRAME",i,game.HttpService:JSONEncode(event))end
   return {seconds=os.clock()-start,samples=#frames,p50=frames[math.max(1,math.ceil(#frames*.5))],p95=frames[math.max(1,math.ceil(#frames*.95))],worst=frames[#frames],
    events=events,eventLimit=64,memoryStartMb=memory,memoryEndMb=Stats:GetTotalMemoryUsageMb(),luaStartKb=lua,luaEndKb=gcinfo()}
  end}
end
return table.freeze(Probe)
