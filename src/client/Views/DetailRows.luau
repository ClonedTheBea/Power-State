--!strict
-- Bounded presentation pool; exact remaining prose is kept in a measured tail.
local C=require(script.Parent.Components)
local Theme=require(script.Parent.Parent.Theme)
local Rows={}
function Rows.create(scroll:ScrollingFrame,metrics:any):any
 local pool:{any}={};local lines:{string}={};local active=false;local scale=1
 for i=1,20 do
  local root=C.panel(scroll,"DetailRow"..i);root.Visible=false;root.ZIndex=31
  local label=C.label(root,"",14,Theme.muted);label.ZIndex=32
  local value=C.label(root,"",18);value.Font=Theme.fontBold;value.ZIndex=32
  table.insert(pool,{root=root,label=label,value=value})
 end
 local tail=C.label(scroll,"",16,Theme.muted);tail.TextYAlignment=Enum.TextYAlignment.Top;tail.ZIndex=32;tail.Visible=false
 local function layout()
  if not active then return end
  local width=math.max(1,scroll.AbsoluteSize.X-8);local y=0
  for i,row in pool do
   local line=lines[i];row.root.Visible=line~=nil
   if line then
    local key,value=string.match(line,"^(.-):%s+(.+)$")
    if not key then key,value=string.match(line,"^(.-)  +(.+)$")end
    -- A colon in explanatory prose does not make the whole paragraph a field label.
    if key and #key>48 then key=nil;value=nil end
    local section=not key and #line<45 and line==string.upper(line)
    local wide=width>=480*scale
    local signature=tostring(width).."/"..tostring(scale).."/"..(key or line)
    if row.signature~=signature then
     row.signature=signature
     metrics.textMeasurements+=1
     row.height=game:GetService("TextService"):GetTextSize(key or line,14*scale,Theme.font,Vector2.new(if key and wide then width*.44-24 else width-24,100000)).Y
    end
    local valueSignature=tostring(width).."/"..tostring(scale).."/"..(if value and #value>40 then value else "short")
    if row.valueSignature~=valueSignature then
     row.valueSignature=valueSignature;row.valueHeight=30*scale
     if value and #value>40 then metrics.textMeasurements+=1;row.valueHeight=math.max(row.valueHeight,game:GetService("TextService"):GetTextSize(value,18*scale,Theme.fontBold,Vector2.new(if wide then width*.56-12 else width-24,100000)).Y+4)end
    end
    local h=if section then math.max(34*scale,row.height+12) elseif key then (if wide then math.max(44*scale,row.height+16,row.valueHeight+12) else row.height+row.valueHeight+16) else row.height+20
    row.root.Position=UDim2.fromOffset(0,y);row.root.Size=UDim2.fromOffset(width,h)
    row.root.BackgroundColor3=if section then Theme.selected else Theme.panel
    row.label.Text=key or line;row.label.TextSize=(if section then 14 else 14)*scale
    row.label.Position=UDim2.fromOffset(12,6);row.label.Size=UDim2.new(if key and wide then .44 else 1,-24,0,if key then (if wide then h-12 else row.height+2) else h-12)
    row.label.TextColor3=if section then Theme.grid else Theme.muted
    row.value.Visible=key~=nil;row.value.Text=value or "";row.value.TextSize=18*scale
    row.value.Position=if wide then UDim2.new(.44,0,0,6) else UDim2.fromOffset(12,row.height+10)
    row.value.Size=if wide then UDim2.new(.56,-12,1,-12) else UDim2.new(1,-24,0,row.valueHeight)
    row.value.TextColor3=if string.find(line,"Credits",1,true)then Theme.credits else Theme.text
    y+=h+5
   end
  end
  tail.Visible=#lines>20
  if tail.Visible then
   local rest={};for i=21,#lines do table.insert(rest,lines[i])end
   tail.Text=table.concat(rest,"\n");tail.TextSize=16*scale
   metrics.textMeasurements+=1
   local bounds=game:GetService("TextService"):GetTextSize(tail.Text,tail.TextSize,tail.Font,Vector2.new(width,100000))
   tail.Position=UDim2.fromOffset(0,y);tail.Size=UDim2.fromOffset(width,bounds.Y+8);y+=bounds.Y+16
  end
  scroll.CanvasSize=UDim2.fromOffset(0,y)
 end
 local resize=scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
 scroll.Destroying:Once(function()resize:Disconnect()end)
 return {active=function()return active end,resize=function(s:number)scale=s;layout()end,
  set=function(message:string)
   local nextLines={};for line in string.gmatch(message,"[^\n]+")do table.insert(nextLines,line)end
   active=true;lines=nextLines;layout()
  end,
  clear=function()active=false;for _,row in pool do row.root.Visible=false end;tail.Visible=false end}
end
return table.freeze(Rows)
