--!strict
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local Country=require(script.Parent.Country)
local Handler=require(script.Parent.IntentHandler)
local Service={}
function Service.start()
 assert(RunService:IsStudio() and game.GameId==10776833313,"P2a isolated Test only")
 local folder=Instance.new("Folder");folder.Name="P2aSimulation"
 local intent=Instance.new("RemoteEvent");intent.Name="Intent";intent.Parent=folder
 local snapshot=Instance.new("RemoteEvent");snapshot.Name="Snapshot";snapshot.Parent=folder
 local states:{[Player]:Country.State}={}
 local subscribed:{[Player]:boolean}={}
 local function add(player:Player)
  if states[player] then return end
  local n=0;for _ in states do n+=1 end
  if n>=8 then return end -- bounded proof capacity; excess clients see unavailable, never another country
  states[player]=Country.new(player.UserId,HttpService:GenerateGUID(false))
 end
 Players.PlayerAdded:Connect(add)
 Players.PlayerRemoving:Connect(function(player)states[player]=nil;subscribed[player]=nil end)
 for _,player in Players:GetPlayers() do add(player) end
 intent.OnServerEvent:Connect(function(player,payload,...)
  local state=states[player];if not state then return end
  local ok,outcome=pcall(Handler.handle,state,player.UserId,if select("#",...)==0 then payload else nil,os.clock())
  if not ok then state.suspended=true;outcome="Suspended";warn("[P2a] Intent failed safely") end
  -- Drop throttled traffic without amplifying it; ordinary periodic snapshots recover the UI.
  if outcome=="Unsubscribed" then subscribed[player]=nil;return end
  if outcome=="Synced" then subscribed[player]=true end
  if outcome~="RateLimited" then snapshot:FireClient(player,Country.snapshot(state,tostring(outcome))) end
 end)
 local elapsed=0
 RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<1 then return end
  local count=math.min(2,math.floor(elapsed));local delayed=elapsed>=3
  elapsed=if delayed then 0 else elapsed-count
  for player,state in states do
   state.delayed=delayed
   if not state.suspended then
    for _=1,count do
     local ok,problem=pcall(function() Country.advance(state);return true end)
     if not ok then state.suspended=true;warn("[P2a] Step suspended: "..tostring(problem));break end
    end
   end
   if subscribed[player] then snapshot:FireClient(player,Country.snapshot(state))end
  end
 end)
 folder.Parent=game:GetService("ReplicatedStorage")
 print("[P2a] Isolated server started; 1 wall second = 1 simulated minute; no persistence or economy")
end
return table.freeze(Service)
