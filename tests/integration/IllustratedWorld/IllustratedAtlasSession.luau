--!strict
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Catalog = require(script.Parent.IllustratedAtlasCatalog)
local Client = script.Parent.Parent.Parent.Client
local Loader = require(Client.Views.Map.SpriteAtlasLoader)
local Session = {}
-- Engine requests cannot be cancelled. Share at most four outstanding requests across
-- remounts; observers are cancellable. Failure is terminal until a fresh Play session.
local fetches: {[string]: string} = {}
local fetchCount = 0
function Session.create(probes: {ImageLabel}, injected: Loader.Request?)
	assert(RunService:IsStudio() and RunService:IsClient() and game.GameId == 10776833313, "Illustrated Test client only")
	assert(#probes == 4, "Four approved atlas probes")
	local began = 0
	local elapsed: number? = nil
	local request = injected or function(done: (boolean)->()): ()->()
		began=os.clock()
		for i,name in Catalog.order do
			local uri=Catalog.atlases[name]
			assert(probes[i].Image==uri,"Unexpected atlas probe")
			if not fetches[uri] then
				fetches[uri]="Loading";fetchCount+=1
				task.spawn(function()
					local success=false;local failed=false
					local ok,problem=pcall(function() ContentProvider:PreloadAsync({probes[i]},function(id: string,status: Enum.AssetFetchStatus)
						-- Roblox may canonicalize the callback URI. This one transparent
						-- ImageLabel has exactly one catalog-owned content dependency.
						if status==Enum.AssetFetchStatus.Success then success=true else failed=true end
						print("[Illustrated atlas fetch]",uri,id,status.Name)
					end) end)
					fetches[uri]=if ok and success and not failed then "Ready" else "Failed"
					if not ok then warn("[Illustrated atlas fetch]",uri,tostring(problem)) end
				end)
			end
		end
		local alive=true
		local connection: RBXScriptConnection?=nil
		local function cancel() alive=false;if connection then connection:Disconnect();connection=nil end end
		connection=RunService.Heartbeat:Connect(function()
			if not alive then return end
			for i,name in Catalog.order do
				local uri=Catalog.atlases[name]
				if fetches[uri]=="Failed" or not probes[i].Parent or probes[i].Image~=uri then cancel();done(false);return end
				if fetches[uri]~="Ready" or not probes[i].IsLoaded then return end
			end
			elapsed=(os.clock()-began)*1000;cancel();done(true)
		end)
		return cancel
	end
	local loader=Loader.new(request)
	return {start=loader.start,state=loader.state,destroy=loader.destroy,
		milliseconds=function() return elapsed end,fetchCount=function() return fetchCount end}
end
return table.freeze(Session)
