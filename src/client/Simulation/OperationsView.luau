--!strict
local C = require(script.Parent.Parent.Views.Components)
local Icon = require(script.Parent.Parent.Views.NavigationIcon)
local Theme = require(script.Parent.Parent.Theme)
local View = {}
function View.create(app: any): any
 local metrics={textMeasurements=0}
 local v=app.view
 local panel=C.scroll(v.page,"OperationsConsole");panel.Position=UDim2.fromOffset(16,12);panel.Size=UDim2.new(1,-32,1,-24);C.stack(panel,8)
 local title=C.label(panel,"NATIONAL CONTROL ROOM",18,Theme.accent);title.Size=UDim2.new(1,-8,0,24);title.LayoutOrder=1;title.Font=Theme.fontBold
 local status=C.label(panel,"Connecting",14,Theme.muted);status.Size=UDim2.new(1,-8,0,32);status.LayoutOrder=2
 local totals=C.label(panel,"",15);totals.Size=UDim2.new(1,-8,0,32);totals.LayoutOrder=3
 local alerts=C.label(panel,"",14,Theme.warning);alerts.Size=UDim2.new(1,-8,0,44);alerts.LayoutOrder=4
 local group=C.frame(panel,"FleetCards");group.BackgroundTransparency=1;group.LayoutOrder=6
 local fleet={}
 for index,id in {"gas","wind","peak"}do
  local card=C.panel(group,id);card.Size=UDim2.new(1,-8,0,214);card.LayoutOrder=5+index
  C.surface(card)
  local tint=if id=="wind" then Theme.healthy elseif id=="peak" then Theme.credits else Theme.grid
  local emblem=Icon.create(card,id,tint);emblem.Position=UDim2.fromOffset(14,14)
  local stripe=C.frame(card,"TechnologyAccent",tint);stripe.Position=UDim2.fromOffset(12,0);stripe.Size=UDim2.new(1,-24,0,2)
  local track=C.frame(card,"OutputTrack",Theme.raised);C.corner(track,3)
  local fill=C.frame(track,"OutputFill",tint);C.corner(fill,3);fill.Size=UDim2.fromScale(0,1)
  local name=C.label(card,"",20);name.Font=Theme.fontBold;name.Position=UDim2.fromOffset(46,10);name.Size=UDim2.new(1,-58,0,28)
  local output=C.label(card,"",26,Theme.grid);output.Font=Theme.fontBold;output.Position=UDim2.fromOffset(12,40);output.Size=UDim2.new(.6,-12,0,34)
  local state=C.label(card,"",14,Theme.healthy);state.Position=UDim2.new(.6,0,0,40);state.Size=UDim2.new(.4,-12,0,34);state.TextXAlignment=Enum.TextXAlignment.Right
  local text=C.label(card,"",14);text.Position=UDim2.fromOffset(12,82);text.Size=UDim2.new(1,-20,0,94);text.TextYAlignment=Enum.TextYAlignment.Top
  local toggle=C.button(card,"Switch On");toggle.Size=UDim2.new(1,-198,0,44)
  local minus=C.button(card,"−");minus.Position=UDim2.new(1,-182,0,104);minus.Size=UDim2.fromOffset(44,44)
  local plus=C.button(card,"+");plus.Position=UDim2.new(1,-134,0,104);plus.Size=UDim2.fromOffset(44,44)
  local locate=C.button(card,"Locate");locate.Position=UDim2.new(1,-86,0,104);locate.Size=UDim2.fromOffset(78,44)
  local details=C.button(card,"Generator details");details.Size=UDim2.new(1,-16,0,44)
  minus:SetAttribute("AccessibleLabel",id.." output cap minus 100 kW");plus:SetAttribute("AccessibleLabel",id.." output cap plus 100 kW")
  local lastWidth,lastScale=0,0
  local function fit()
   local width=math.max(1,card.AbsoluteSize.X-20);local scale=v.root:GetAttribute("TextScale") or 1
   if width==lastWidth and scale==lastScale then return end;lastWidth=width;lastScale=scale
   metrics.textMeasurements+=1;text.TextSize=14*scale
   name.TextSize=18*scale;name.Size=UDim2.new(1,-58,0,28*scale)
   output.TextSize=26*scale;state.TextSize=14*scale
   output.Position=UDim2.fromOffset(12,12+28*scale);state.Position=UDim2.new(.6,0,0,12+28*scale)
   output.Size=UDim2.new(.6,-12,0,34*scale);state.Size=UDim2.new(.4,-12,0,34*scale)
   track.Position=UDim2.fromOffset(12,14+65*scale);track.Size=UDim2.new(1,-24,0,6)
   local top=26+70*scale;text.Position=UDim2.fromOffset(12,top)
   -- Stable worst-case geometry depends on width/font, never on transient dispatch values.
   local sample="Ready 9.99 MW · Cap 9.99 MW\n110 Credits/MWh + 10/h On"
   local height=math.max(48,math.ceil(game:GetService("TextService"):GetTextSize(sample,text.TextSize,text.Font,Vector2.new(width,10000)).Y)+8)
   text.Size=UDim2.new(1,-20,0,height)
   toggle.Position=UDim2.fromOffset(8,top+height+12)
   for _,button in {minus,plus,locate}do button.Position=UDim2.new(button.Position.X.Scale,button.Position.X.Offset,0,top+height+12)end
   details.Position=UDim2.fromOffset(8,top+height+60)
  end
  local size=card:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
  local scale=v.root:GetAttributeChangedSignal("TextScale"):Connect(fit)
  card.Destroying:Once(function()size:Disconnect();scale:Disconnect()end)
  C.action(toggle,"primary");C.surface(locate);C.surface(details)
  fleet[id]={fill=fill,track=track,card=card,text=text,name=name,output=output,state=state,toggle=toggle,minus=minus,plus=plus,locate=locate,details=details}
 end
 local function arrange()
  local width=panel.AbsoluteSize.X-8;local columns=if width>=1050 then 3 elseif width>=720 then 2 else 1
  local cell=(width-(columns-1)*12)/columns;local scale=v.root:GetAttribute("TextScale") or 1
  local h=26+math.ceil(134*scale)+112
  group.Size=UDim2.new(1,-8,0,math.ceil(3/columns)*(h+12)-12)
  for i,id in {"gas","wind","peak"}do local row=fleet[id]
   row.card.Position=UDim2.fromOffset((i-1)%columns*(cell+12),math.floor((i-1)/columns)*(h+12))
   row.card.Size=UDim2.fromOffset(cell,h)
  end
 end
 local resized=panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(arrange)
 local scaled=v.root:GetAttributeChangedSignal("TextScale"):Connect(arrange)
 panel.Destroying:Once(function()resized:Disconnect();scaled:Disconnect()end)
 task.defer(arrange)
 local forecast=C.label(panel,"",14,Theme.muted);forecast.Size=UDim2.new(1,-8,0,48);forecast.LayoutOrder=10
 local forecastButton=C.button(panel,"Demand & wind forecast");forecastButton.Size=UDim2.new(1,-8,0,44);forecastButton.LayoutOrder=11
 local bank=C.button(panel,"Bank & financial history");bank.Size=UDim2.new(1,-8,0,44);bank.LayoutOrder=12
 local retry=C.button(panel,"Retry suspended operation");retry.Size=UDim2.new(1,-8,0,44);retry.LayoutOrder=13
 local back=C.button(panel,"View grid");back.Size=UDim2.new(1,-8,0,44);back.LayoutOrder=14
 local leave=C.button(panel,"Return to First Playable");leave.Size=UDim2.new(1,-8,0,44);leave.LayoutOrder=15
 return {panel=panel,status=status,totals=totals,fleet=fleet,forecast=forecast,alerts=alerts,retry=retry,back=back,leave=leave,metrics=metrics,bank=bank,forecastButton=forecastButton}
end
return table.freeze(View)
