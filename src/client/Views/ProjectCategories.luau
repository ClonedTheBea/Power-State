--!strict
local C=require(script.Parent.Components)
local Theme=require(script.Parent.Parent.Theme)
local Categories={}
function Categories.create(app:any,attribute:string,confirm:TextButton,onGeneration:(()->())?):any
 local feedback=app.view.feedback;local root=C.frame(feedback.root,"ProjectCategories");root.BackgroundTransparency=1;root.ZIndex=32
 root.Position=UDim2.fromOffset(16,60);root.Size=UDim2.new(1,-32,0,44);root.Visible=false
 local masthead=C.label(feedback.root,"CONNECTION INVESTMENT · SERVER QUOTE",12,Theme.credits);masthead.Name="InvestmentCaption";masthead.ZIndex=32;masthead.Visible=false;masthead.Size=UDim2.new(1,-32,0,20)
 local cancel=C.button(feedback.root,"Cancel");cancel.ZIndex=32;cancel.Position=UDim2.new(0,16,1,-60);cancel.Size=UDim2.new(.34,-20,0,44);cancel.Visible=false
 app.bind(cancel,function()app.back()end)
 confirm.Position=UDim2.new(.34,4,1,-60);confirm.Size=UDim2.new(.66,-20,0,44)
 for i,text in {"Connections","Generation · Later","Storage · Later"}do
  local button=C.button(root,text);button.ZIndex=33;button.TextSize=12
  button.Position=UDim2.new((i-1)/3,0,0,0);button.Size=UDim2.new(1/3,-4,1,0)
  if i==1 then C.action(button,"primary");button.Active=false;button.Selectable=false
  elseif i==2 and onGeneration then button.Text="Generation";app.bind(button,onGeneration)
  else
   app.bind(button,function()feedback.root:SetAttribute("ConstructionOverview",false);feedback.root:SetAttribute("ConstructionBank",false);app.showFeedback("Coming later", "This category has no approved purchasable projects. Your existing country and connection quote are unchanged.",feedback.close)end)
  end
 end
 return {refresh=function()
  root.Visible=feedback.root.Visible and feedback.root:GetAttribute(attribute)==true and Theme.visualRedesign
  cancel.Visible=root.Visible;masthead.Visible=root.Visible
  cancel.Text=if string.find(confirm.Text,"Checking",1,true) or string.find(confirm.Text,"Saving",1,true) or string.find(confirm.Text,"Already",1,true) or string.find(confirm.Text,"Completed",1,true) or string.find(confirm.Text,"Connected",1,true) then "Close review" else "Cancel"
  if root.Visible then
   local scroll=feedback.root.Message :: ScrollingFrame
   local scale=app.view.root:GetAttribute("TextScale") or 1
   local y=if scale>1 then 124 else 84
   masthead.Position=UDim2.fromOffset(16,y-24)
   root.Position=UDim2.fromOffset(16,y)
   scroll.Position=UDim2.fromOffset(16,y+52);scroll.Size=UDim2.new(1,-32,1,-y-132)
  end
 end}
end
return table.freeze(Categories)
