--!strict
local ContentProvider=game:GetService("ContentProvider")
local RunService=game:GetService("RunService")
local Profiles=require(script.Parent.SettlementProfiles)
local Atlas={}
function Atlas.create()
	assert(RunService:IsStudio() and RunService:IsClient() and game.GameId==10776833313,"Test client only")
	-- Restricted images are preloaded through their actual labels, once per atlas per mount.
	-- At most two engine operations can outlive observer cancellation; switches never queue more.
	local states:{[string]:string}={}
	local destroyed=false
	local fetchCount=0
	local function preload(uri:string,images:{ImageLabel})
		if states[uri] or destroyed then return end
		states[uri]="Loading";fetchCount+=1
		task.spawn(function()
			local seen,failed=false,false
			local ok=pcall(function()
				ContentProvider:PreloadAsync(images,function(id:string,status:Enum.AssetFetchStatus)
					if destroyed then return end
					if id==uri then
						if status==Enum.AssetFetchStatus.Success then seen=true else failed=true end
					end
				end)
			end)
			if destroyed then return end
			states[uri]=if ok and seen and not failed then "Ready" else "Failed"
		end)
	end
	local function request(images:{ImageLabel},profile:string)
		assert(#images==6,"Fixed six-label pool")
		local expected:{string}={}
		local groups:{[string]:{ImageLabel}}={}
		for i,image in images do
			local uri=Profiles.uri(profile,i);expected[i]=uri
			assert(image.Image==uri,"Unexpected texture in profile")
			if not groups[uri] then groups[uri]={} end
			table.insert(groups[uri],image)
		end
		return function(done:(boolean)->())
			local alive=true
			local start=os.clock()
			local heartbeat:RBXScriptConnection?=nil
			local function cancel() alive=false;if heartbeat then heartbeat:Disconnect();heartbeat=nil end end
			local function finish(ok:boolean)
				if not alive or destroyed then return end
				cancel()
				print(string.format("[R3.7 REAL load] %s ready=%s %.3f ms; cache unknown",profile,tostring(ok),(os.clock()-start)*1000))
				done(ok)
			end
			heartbeat=RunService.Heartbeat:Connect(function()
				if not alive or destroyed then cancel();return end
				if os.clock()-start>=5 then cancel();return end
				for uri in groups do
					if states[uri]=="Failed" then finish(false);return end
					if states[uri]~="Ready" then return end
				end
				for i,image in images do
					if image.Parent==nil or image.Image~=expected[i] then finish(false);return end
					if not image.IsLoaded then return end
				end
				finish(true)
			end)
			for uri,labels in groups do preload(uri,labels) end
			return cancel
		end
	end
	return {request=request,destroy=function() destroyed=true end,fetchCount=function() return fetchCount end}
end
return table.freeze(Atlas)
