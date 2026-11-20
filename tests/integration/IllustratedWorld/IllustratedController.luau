--!strict
local Renderer = require(script.Parent.IllustratedSectorRenderer)
local Controller = {}
local mounted: {[Instance]: any} = setmetatable({}, {__mode="k"}) :: any
function Controller.active(gui: Instance): any return mounted[gui] end
function Controller.attach(app: any, preview: any, groundLoader: any?)
	assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Experimental Test only")
	if mounted[app.view.gui] then return mounted[app.view.gui] end
	local button=app.view.drawer.buttons.Geography
	local oldAction=app.actions[button];local oldText=button.Text
	local renderer: any=nil
	local ground:any=nil
 local organic:any=nil
 local organicEnabled=game.ReplicatedStorage:GetAttribute("OrganicCoastProof")==true -- Failed filtering gate: explicit diagnostic opt-in only.
	local landscape="Native"
	local requested=false
	local function update()
		-- A failed ground proof restores the whole Native presentation, not just
		-- flat terrain underneath still-enabled illustrated decorations.
		if ground and requested and (landscape=="Ground" or landscape=="Ocean" or landscape=="Organic")
			and (ground.state()=="Failed" or ground.state()=="TimedOut") then
			requested=false
			if renderer then renderer.setEnabled(false) end
		end
		local state=app.view.map.root:GetAttribute("IllustratedLoadState")
		if landscape=="Ground" or landscape=="Ocean" or landscape=="Organic" then
			local status=if ground then ground.state() else "Idle"
			button.Text=if status=="Ready" and app.view.map.root:GetAttribute("IllustratedActive")~=true
				then (if state=="Failed" or state=="TimedOut" or state=="LabelTimedOut" then "Native · artwork unavailable" else "Native · waiting for artwork").."\nGround cached"
				elseif status=="Failed" or status=="TimedOut"
				then "Native fallback · "..status.."\nNext landscape comparison"
				else (if landscape=="Organic" then "Organic Coast — Experimental" else landscape.." (Test)").." · "..status.."\nNext: "..(if landscape=="Ground" then "Ocean" elseif landscape=="Ocean" and organicEnabled then "Organic Coast" else "Native")
		else button.Text=if requested then "Illustrated (Experimental) · "..tostring(state).."\nSelect Native" else "Native · selected\nSelect Illustrated (Experimental)" end
		button:SetAttribute("AccessibleLabel",button.Text)
	end
	local function setEnabled(value: boolean)
		if ground then ground.setMode("Native") end
		landscape=if value then "Illustrated" else "Native"
		if not renderer and value then
			local ok,result=pcall(Renderer.attach,app.view.map,preview)
			if not ok then
				warn("[Illustrated World] Native retained: "..tostring(result));button.Text="Native · illustration unavailable";return
			end
			renderer=result
		end
		requested=value
		if renderer then renderer.setEnabled(value) end
		update()
	end
	local function setLandscapeMode(value:string)
  if value=="Organic" and not organicEnabled then warn("[Organic Coast] Filtering gate unresolved; diagnostic opt-in required");return end
		assert(value=="Native" or value=="Illustrated" or value=="Ground" or value=="Ocean" or value=="Organic","Test landscape mode")
		setEnabled(value~="Native")
		if value=="Ground" or value=="Ocean" or value=="Organic" then
			if not renderer then return end
			if not ground then ground=require(script.Parent.ContinuousGround).attach(app.view.map,preview.world,groundLoader) end
			if value=="Organic" and not organic then
    local catalog=require(script.Parent.IllustratedAtlasCatalog)
    local footprints={}
    for _,group in {renderer.descriptor.assets,renderer.descriptor.decorations} do for _,e in group do
     local m=catalog.motifs[e.art];local x=e.x-m.pivot[1]*m.size/m.rect[3];local y=e.y-m.pivot[2]*m.size/m.rect[4]
     table.insert(footprints,{x,y,x+m.size,y+m.size})
    end end
    local ok,result=pcall(require(script.Parent.OrganicCoast).create,preview.world,preview.nodes,preview.links,footprints)
    if not ok then
     ground.setMode("Native");renderer.setEnabled(false);requested=false;landscape="Native"
     warn("[Organic Coast] Unsupported geometry; Native retained",result);update();return
    end
    organic=result
    app.view.map.root:SetAttribute("OrganicCornerCount",#organic.corners)
   end
   ground.setOrganic(if value=="Organic" then organic else nil)
   ground.setMode(value)
		end
		landscape=value
		update()
	end
	-- Reuse a mounted 44+ px control and the shell's keyboard/gamepad action router.
	app.actions[button]=function()
		if game.ReplicatedStorage:GetAttribute("ContinuousGroundProof")==true then
			setLandscapeMode(if landscape=="Native" then "Illustrated" elseif landscape=="Illustrated" then "Ground" elseif landscape=="Ground" then "Ocean" elseif landscape=="Ocean" and organicEnabled then "Organic" else "Native")
		else setEnabled(not requested) end
	end
	button.TextWrapped=true;update()
	local change=app.view.map.root:GetAttributeChangedSignal("IllustratedLoadState"):Connect(update)
	local activeChange=app.view.map.root:GetAttributeChangedSignal("IllustratedActive"):Connect(update)
	local groundChange=app.view.map.root:GetAttributeChangedSignal("ContinuousGroundState"):Connect(update)
	local modeChange=game.ReplicatedStorage:GetAttributeChangedSignal("ContinuousGroundMode"):Connect(function()
		if game.ReplicatedStorage:GetAttribute("ContinuousGroundProof")~=true then return end
		local value=game.ReplicatedStorage:GetAttribute("ContinuousGroundMode")
		if value=="Native" or value=="Illustrated" or value=="Ground" or value=="Ocean" or value=="Organic" then setLandscapeMode(value) end
	end)
 local reviewChange=app.view.feedback.root:GetPropertyChangedSignal("Visible"):Connect(function()
  if landscape~="Organic" or not ground or not renderer then return end
  if app.view.feedback.root.Visible then ground.setMode("Native");renderer.setEnabled(false)
  else renderer.setEnabled(requested);ground.setMode("Organic") end
 end)
 local destroyed=false
	local function destroy()
		if destroyed then return end;destroyed=true
		change:Disconnect();activeChange:Disconnect();groundChange:Disconnect();modeChange:Disconnect();reviewChange:Disconnect();if ground then ground.destroy() end;if renderer then renderer.destroy() end
		app.actions[button]=oldAction;button.Text=oldText;mounted[app.view.gui]=nil
	end
	app.view.gui.Destroying:Once(destroy)
	local result={setEnabled=setEnabled,setLandscapeMode=setLandscapeMode,ground=function()return ground end,renderer=function() return renderer end,destroy=destroy}
	mounted[app.view.gui]=result
	return result
end
return table.freeze(Controller)
