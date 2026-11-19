--!strict
-- Public snapshot presentation only; original IDs and electrical anchors stay authoritative.
local C=require(script.Parent.Parent.Views.Components)
local Icon=require(script.Parent.Parent.Views.NavigationIcon)
local Theme=require(script.Parent.Parent.Theme)
local Directory={}
function Directory.create(app:any,current:()->any,toggle:()->(),healthy:()->boolean):any
 local v=app.view;local root=C.scroll(v.page,"InfrastructureDirectory")
 root.Position=UDim2.fromOffset(16,16);root.Size=UDim2.new(1,-32,1,-32);root.Visible=false;C.stack(root,12)
 local title=C.label(root,"INFRASTRUCTURE",26);title.Font=Theme.fontBold;title.Size=UDim2.new(1,-8,0,34);title.LayoutOrder=1
 local subtitle=C.label(root,"Your existing assets · select to inspect or locate on Grid",14,Theme.muted);subtitle.Size=UDim2.new(1,-8,0,44);subtitle.LayoutOrder=2
 local training=C.button(root,"Open National Operations Training");training.Size=UDim2.new(1,-8,0,44);training.LayoutOrder=3;C.action(training,"primary")
 local tabs=C.frame(root,"Categories");tabs.BackgroundTransparency=1;tabs.Size=UDim2.new(1,-8,0,44);tabs.LayoutOrder=4
 local category="All";local buttons:{[string]:TextButton}={};local slots:{any}={};local selected:string?=nil
 local content=C.frame(root,"DirectoryContent");content.BackgroundTransparency=1;content.LayoutOrder=5
 local grid=C.frame(content,"AssetRows");grid.BackgroundTransparency=1;grid.LayoutOrder=5
 local detail=C.panel(content,"AssetDetails");detail.Size=UDim2.new(1,-8,0,250);detail.LayoutOrder=6;C.surface(detail)
 local heading=C.label(detail,"Select an asset",22);heading.Font=Theme.fontBold;heading.Position=UDim2.fromOffset(16,12);heading.Size=UDim2.new(1,-32,0,34)
 local track=C.frame(detail,"OutputTrack",Theme.raised);track.Position=UDim2.fromOffset(16,54);track.Size=UDim2.new(1,-32,0,7);C.corner(track,3)
 local fill=C.frame(track,"OutputFill",Theme.grid);fill.Size=UDim2.fromScale(0,1);C.corner(fill,3)
 local info=C.label(detail,"",16,Theme.muted);info.Position=UDim2.fromOffset(16,54);info.Size=UDim2.new(1,-32,0,120);info.TextYAlignment=Enum.TextYAlignment.Top
 local locate=C.button(detail,"View on Grid");locate.Position=UDim2.fromOffset(12,190);locate.Size=UDim2.new(.5,-18,0,44);C.action(locate,"primary")
 local control=C.button(detail,"Switch generator");control.Position=UDim2.new(.5,6,0,190);control.Size=UDim2.new(.5,-18,0,44)
 local later=C.label(root,"Maintenance, inspections and upgrades · Coming later. No condition or staff data is simulated.",14,Theme.muted);later.Size=UDim2.new(1,-8,0,64);later.LayoutOrder=7
 local records:{any}={}
 local refresh:()->()
 local function arrange()
  local width=math.max(1,root.AbsoluteSize.X-8);local scale=v.root:GetAttribute("TextScale") or 1
  local wide=width>=860;local listWidth=if wide then math.floor(width*.48)-6 else width;local columns=1
  local rowHeight=math.ceil(72*scale);local pitch=rowHeight+12
  title.TextSize=26*scale;title.Size=UDim2.new(1,-8,0,34*scale)
  subtitle.TextSize=14*scale;subtitle.Size=UDim2.new(1,-8,0,44*scale)
  heading.TextSize=22*scale;heading.Size=UDim2.new(1,-32,0,34*scale)
  info.TextSize=16*scale;info.Position=UDim2.fromOffset(16,68*scale);info.Size=UDim2.new(1,-32,0,160*scale)
  local detailHeight=240*scale+56
  for _,button in {locate,control} do button.Position=UDim2.new(button.Position.X.Scale,button.Position.X.Offset,0,detailHeight-56)end
  detail.Position=if wide then UDim2.fromOffset(listWidth+12,0)else UDim2.fromOffset(0,0)
  detail.Size=UDim2.fromOffset(if wide then width-listWidth-12 else width,detailHeight)
  local shown=0
  for _,slot in slots do if slot.button.Visible then
   slot.button.Position=UDim2.fromOffset(shown%columns*((listWidth-12*(columns-1))/columns+12),math.floor(shown/columns)*pitch)
   slot.button.Size=UDim2.fromOffset((listWidth-12*(columns-1))/columns,rowHeight);slot.button.TextSize=16*scale;shown+=1
  end end
  local listHeight=math.ceil(shown/columns)*pitch
  grid.Size=UDim2.fromOffset(listWidth,listHeight)
  if not wide then detail.Position=UDim2.fromOffset(0,listHeight+12)end
  content.Size=UDim2.fromOffset(width,if wide then math.max(listHeight,detailHeight)else listHeight+12+detailHeight)
 end
 for i=1,4 do
  local button=C.button(grid,"");button.Visible=false;button.TextSize=16
  local icon=Icon.create(button,"Infrastructure",Theme.grid);icon.Position=UDim2.new(0,14,.5,-10)
  local name=C.label(button,"",17);name.Font=Theme.fontBold;name.Position=UDim2.fromOffset(48,8);name.Size=UDim2.new(1,-60,.5,-8);name.TextWrapped=false;name.TextTruncate=Enum.TextTruncate.AtEnd
  local status=C.label(button,"",14,Theme.muted);status.Position=UDim2.new(0,48,.5,0);status.Size=UDim2.new(1,-60,.5,-6)
  local slot:any={button=button,name=name,status=status};table.insert(slots,slot)
  app.bind(button,function()selected=slot.id;refresh()end)
 end
 for i,name in {"All","Generators","Network","Customers"}do
  local button=C.button(tabs,name);button.Position=UDim2.new((i-1)/4,0,0,0);button.Size=UDim2.new(.25,-4,1,0);button.TextSize=12;buttons[name]=button
  app.bind(button,function()category=name;refresh()end)
 end
 app.bind(locate,function()if selected then app.navigate("Map");app.selectAsset(selected);for _,node in records do if node.id==selected then app.mapController.locate(node.x,node.y)end end end end)
 app.bind(control,toggle)
 refresh=function()
  local s=current();local active=app.state.route=="Infrastructure";root.Visible=active
  for _,obj in {v.pageTitle,v.pageTag,v.pageBody,v.pageBack}do obj.Visible=not active end
  if not active then return end
  records={};for _,node in s.nodes do table.insert(records,node)end
  if s.built then table.insert(records,s.proposedNode)end
  selected=selected or s.generatorId
  local index=0;local chosen:any=nil
  for _,node in records do
   if node.id==selected then chosen=node end
   local kind=if node.id==s.generatorId then "Generators" elseif node.kind=="Substation" then "Network" else "Customers"
   if category=="All" or category==kind then
    index+=1;local slot=slots[index];slot.id=node.id;slot.button.Visible=true
    local status=if node.id==s.generatorId then (if s.online then "On" else "Off")..string.format(" · %.3f / 5 MW",s.report.outputMW) elseif node.kind=="Substation" then "10 MW routing capacity" else "Connected customers"
    slot.button:SetAttribute("AccessibleLabel",node.name.." · "..status);slot.name.Text=node.name;slot.status.Text=status;C.selected(slot.button,selected==node.id)
   end
  end
  for i=index+1,#slots do slots[i].button.Visible=false end
  for name,button in buttons do C.selected(button,name==category)end
  heading.Text=if chosen then chosen.name else "Select an asset"
  local isGenerator=selected==s.generatorId
  track.Visible=isGenerator;fill.Size=UDim2.fromScale(math.clamp(s.report.outputMW/5,0,1),1)
  info.Text=if isGenerator then string.format("Gas generation · %s\nOutput %.3f / 5 MW\nFuel 80 Credits/MWh · Running 10 Credits/hour\nControls apply to the next completed interval.",if s.online then "On" else "Off",s.report.outputMW)
   elseif chosen and chosen.kind=="Substation" then string.format("Substation · 10 MW capacity\nCurrent flow %.3f MW\nRoutes generation to connected customers.",s.report.outputMW)
   else "Customer connection\nDelivery and unmet demand are shown on the Grid inspector.\nNo maintenance or population-growth model is active."
  control.Visible=isGenerator;control.Active=healthy() and not s.suspended;control.Selectable=control.Active
  control.Text=if s.online then "Switch Off" else "Switch On"
  locate.Active=chosen~=nil;arrange()
 end
 local changed=root:GetPropertyChangedSignal("AbsoluteSize"):Connect(arrange);local scaled=v.root:GetAttributeChangedSignal("TextScale"):Connect(arrange);root.Destroying:Once(function()changed:Disconnect();scaled:Disconnect()end)
 return {root=root,training=training,refresh=refresh,rows=slots,locate=locate,control=control,tabs=buttons}
end
return table.freeze(Directory)
