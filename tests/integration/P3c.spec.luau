--!strict
return function(playerGui:PlayerGui)
 local Client=require(script.Parent.Parent.Client.Simulation.ConstructionClient)
 local live=Client.mount(playerGui);local app=live.app;local checks=0
 local function check(v:boolean,why:string)assert(v,why);checks+=1 end
 local function waitFor(predicate:()->boolean,seconds:number)
  local deadline=os.clock()+seconds
  repeat task.wait(.05)until predicate() or os.clock()>=deadline
  check(predicate(),"Construction authoritative progression deadline")
 end
	local GuiService=game:GetService("GuiService")
	local function modalFocus()
		waitFor(function()return GuiService.SelectedObject==app.view.feedback.close end,2)
		check(app.keyboard.valid(app.view.feedback.close),"Review/Bank close is an eligible focus target")
	end
 app.selectAsset(live.current().proposedNode.id)
 for _,size in {{1366,704},{768,960},{360,580},{640,300}}do
  app.view.root.Size=UDim2.fromOffset(size[1],size[2]);task.wait(.3)
  app.selectAsset(live.current().proposedNode.id);task.wait(.2)
  check(live.button.AbsoluteSize.Y>=44 and live.button.AbsoluteSize.X>=44,"Accessible review target")
  check(not string.find(app.view.header.identity.Text,"100K Credits",1,true),"Compact header never shows fixture Bank")
  local camera=app.view.map.root:GetAttribute("CameraX");local selected=app.state.selectedId
  app.actions[live.button]();task.wait(1.1)
  check(live.confirm.AbsoluteSize.Y>=44 and live.confirm.AbsoluteSize.X>=44,"Accessible confirmation target")
  check(app.view.feedback.root.Visible,"Responsive construction review")
		modalFocus()
  local step=live.current().step
  waitFor(function()return live.current().step>step end,3)
  check(app.state.selectedId==selected and app.view.map.root:GetAttribute("CameraX")==camera,"Review preserves selection/camera")
  app.actions[app.view.feedback.close]()
  check(#app.view.map.root:GetDescendants()<=600,"Native map descendant budget")
 end
 print("[P3c GUI] Waiting for genuinely earned fake Credits; no test grant")
 waitFor(function()return live.current().bankMinor>=125000 end,180)
 app.actions[live.button]();waitFor(function()return live.current().construction.state=="Available"end,3)
 local camera=app.view.map.root:GetAttribute("CameraX");local selected=app.state.selectedId
 app.actions[live.confirm]()
 app.actions[app.view.feedback.close]()
 waitFor(function()return live.current().built end,5)
 check(live.current().bankMinor>=25000,"Buffer preserved after confirmed purchase")
 check(app.state.selectedId==selected and app.view.map.root:GetAttribute("CameraX")==camera,"Commit preserves selection/camera")
 check(live.current().save.storage=="Fake" and #live.current().report.sinks==2,"Real engine, fake storage, two sinks")
 app.actions[live.button]();waitFor(function()return live.current().construction.state=="AlreadyBuilt"end,3)
 check(not live.confirm.Active,"Repeat purchase disabled")
	modalFocus()
	-- The approved redesign adds category navigation and a second dismissal action.
	-- Traverse the entire modal in both directions; disabled purchase stays excluded.
	local allowed: {[TextButton]: boolean}={}
	local expected=0
	for button in app.actions do
		if app.keyboard.valid(button) then
			check(button:IsDescendantOf(app.view.feedback.root),"Completed modal contains every eligible target")
			allowed[button]=true;expected+=1
		end
	end
	check(expected>=1 and expected<=16 and not allowed[live.confirm],"Bounded traversal excludes completed purchase")
	for _,direction in {1,-1} do
		local visited: {[Instance]: boolean}={}
		for _=1,expected do
			app.keyboard.step(direction)
			local focused=GuiService.SelectedObject
			check(focused~=nil and focused:IsA("TextButton") and allowed[focused]==true and not visited[focused],"Each modal target visited once; no disabled purchase or escape")
			if focused then visited[focused]=true end
		end
		check(GuiService.SelectedObject==app.view.feedback.close,"Traversal returns to dismiss control")
	end
	check(not live.confirm.Selectable and not live.confirm.Active,"Completed purchase cannot be selected or activated")
	local capital=live.current().finance.bank.constructionSpentMinor
	app.actions[live.confirm]();task.wait(.2)
	check(live.current().built and live.current().finance.bank.constructionSpentMinor==capital and capital==100000,"Disabled action cannot repeat the capital debit")
	app.keyboard.activate()
	check(not app.view.feedback.root.Visible,"Keyboard/gamepad dismissal closes completed review")
 app.actions[app.view.feedback.close]()
 app.actions[app.view.inspector.locate]();task.wait(.2)
 check(#app.view.map.root:GetDescendants()<=600,"Locate retains bounded map")
 app.actions[app.view.kpis.buttons[1]]();task.wait(.2)
 check(app.view.feedback.root:GetAttribute("ConstructionBank")==true,"Live construction Bank overview")
	modalFocus()
 local capitalShown=false
 for _,obj in app.view.feedback.root:GetDescendants()do
  if obj:IsA("TextLabel") and string.find(obj.Text,"Construction spending: 1000.00 Credits",1,true)then capitalShown=true end
 end
 check(capitalShown and not live.confirm.Visible,"Capital spending separated from operating earnings")
 app.view.root.Size=UDim2.fromOffset(360,580);task.wait(.3)
 local bankScroll=app.view.feedback.root:FindFirstChild("Message") :: ScrollingFrame
 check(bankScroll.AbsoluteCanvasSize.Y>bankScroll.AbsoluteSize.Y,"Mobile Bank has scrollable financial overflow")
 bankScroll.CanvasPosition=Vector2.new(0,1000);task.wait(.1)
 check(bankScroll.CanvasPosition.Y>0,"Mobile financial details can be reached")
 local bankBody=bankScroll:FindFirstChildWhichIsA("TextLabel") :: TextLabel
 check(bankBody.TextFits and bankBody.AbsoluteSize.Y>500,"Full Bank text fits measured content, including capital row")
 app.actions[app.view.feedback.close]()
	waitFor(function()return GuiService.SelectedObject==app.view.kpis.buttons[1] end,2)
	app.actions[app.view.kpis.buttons[1]]();modalFocus()
	app.actions[app.view.feedback.close]()
	waitFor(function()return GuiService.SelectedObject==app.view.kpis.buttons[1] end,2)
 local text=game:GetService("HttpService"):JSONEncode(live.current())
 for _,private in {"ownerSessionId","expiresAtUtcMs","operationId","sessionEpoch","lastCommit"}do check(not string.find(text,private,1,true),"Private construction field excluded")end
 print(string.format("[Power State P3c GUI] PASS: %d assertions; map %d descendants",checks,#app.view.map.root:GetDescendants()))
 local stepBeforeUnmount=live.current().step
 local remote=game.ReplicatedStorage.P3cConstruction.Snapshot :: RemoteEvent
 local afterUnmount=0
 local listener=remote.OnClientEvent:Connect(function()afterUnmount+=1 end)
 live.destroy()
 task.wait(.3);afterUnmount=0;task.wait(2.2)
 check(afterUnmount==0,"Unsubscribe stops periodic transport")
 listener:Disconnect()
 local remounted=Client.mount(playerGui)
 check(remounted.current().built and remounted.current().step>stepBeforeUnmount,"Remount preserves build; ordinary UI lifetime does not pause simulation")
 remounted.destroy()
 local rapid=Client.mount(playerGui)
 check(rapid.current().built,"Rapid remount recovers within bounded subscription retry")
 rapid.destroy()
 print(string.format("[Power State P3c GUI lifecycle] PASS: %d total assertions including unsubscribe/remount",checks))
 require(script.Parent.Parent.Client.Controllers.AppController).mount(playerGui)
 return checks
end
