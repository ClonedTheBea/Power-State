--!strict
-- Verify the visible structured presentation against the same authoritative snapshot.
return function(live: any)
 local app=live.app
 local Bank=require(script.Parent.Parent.Client.Simulation.BankPresentation)
 local Currency=require(game.ReplicatedStorage.Shared.Util.CurrencyFormat)
 local Theme=require(script.Parent.Parent.Client.Theme)
 local RunService=game:GetService("RunService")
 local count=0
 local function check(value:boolean,message:string) assert(value,message);count+=1 end
 local function layout() for _=1,3 do RunService.RenderStepped:Wait() end end
 local function money(value:number):string return (if value<0 then "−" else "")..Currency.format(math.abs(value)) end
 local originalSize=app.view.root.Size
 local originalScale=app.view.root:GetAttribute("TextScale")
 for _,size in {Vector2.new(1366,704),Vector2.new(768,960),Vector2.new(360,580),Vector2.new(640,300)} do
  for _,scale in {1,1.25,1.5} do
   app.view.root.Size=UDim2.fromOffset(size.X,size.Y);app.view.root:SetAttribute("TextScale",scale);app.refresh();layout()
   local snapshot=live.current()
   local expected=Bank.text(snapshot)..string.format("\n\nConstruction spending: %.2f Credits (capital; excluded from operating net)",snapshot.finance.bank.constructionSpentMinor/100)
   local scroll=app.view.feedback.root.Message :: ScrollingFrame
   local canonical=scroll:FindFirstChildWhichIsA("TextLabel") :: TextLabel
   check(canonical.Text==expected,"Canonical financial message matches current authoritative snapshot")
   if not Theme.visualRedesign then
    check(canonical.Visible and canonical.TextFits and canonical.AbsoluteSize.Y>500,"Legacy full paragraph fits including capital row")
   else
    check(not canonical.Visible,"Canonical paragraph is replaced, not overlaid")
    local lines={};for line in string.gmatch(expected,"[^\n]+") do table.insert(lines,line) end
    local actual={};local bottom=0
    for i=1,20 do
     local row=scroll:FindFirstChild("DetailRow"..i) :: Frame
     check(row~=nil and row.Visible==(lines[i]~=nil),"Every expected pooled row is visible")
     if row.Visible then
      check(row.Position.Y.Offset>=bottom,"Financial row boxes do not overlap")
      bottom=row.Position.Y.Offset+row.AbsoluteSize.Y
      local labels:{TextLabel}={}
      for _,label in row:GetChildren() do if label:IsA("TextLabel") and label.Visible then table.insert(labels,label) end end
      table.sort(labels,function(a,b) if a.Position.Y.Offset~=b.Position.Y.Offset then return a.Position.Y.Offset<b.Position.Y.Offset end;return a.AbsolutePosition.X<b.AbsolutePosition.X end)
      check(#labels>=1 and #labels<=2,"Expected key/value or prose row")
      local text=labels[1].Text..(if #labels==2 then ": "..labels[2].Text else "")
      check(text==lines[i],"Exact visible financial row "..i)
      table.insert(actual,text)
      for _,label in labels do
       check(label.TextBounds.X<=label.AbsoluteSize.X+1 and label.TextBounds.Y<=label.AbsoluteSize.Y+1,"Complete visible label measured without clipping")
       check(label.AbsolutePosition.X>=row.AbsolutePosition.X and label.AbsolutePosition.Y>=row.AbsolutePosition.Y and label.AbsolutePosition.X+label.AbsoluteSize.X<=row.AbsolutePosition.X+row.AbsoluteSize.X+1 and label.AbsolutePosition.Y+label.AbsoluteSize.Y<=row.AbsolutePosition.Y+row.AbsoluteSize.Y+1,"Financial label contained in row")
      end
     end
    end
    local tail:TextLabel?=nil
    for _,child in scroll:GetChildren() do if child:IsA("TextLabel") and child~=canonical and child.Visible then check(tail==nil,"Single bounded overflow tail");tail=child end end
    if #lines>20 then
     check(tail~=nil,"All excess financial information remains visible")
     local t=tail :: TextLabel
     local rest={};for i=21,#lines do table.insert(rest,lines[i]);table.insert(actual,lines[i]) end
     check(t.Text==table.concat(rest,"\n") and t.TextFits,"Exact complete measured overflow tail")
     check(t.Position.Y.Offset>=bottom,"Tail does not overlap rows")
     bottom=t.Position.Y.Offset+t.AbsoluteSize.Y
    else check(tail==nil,"No stale overflow text") end
    local rendered=table.concat(actual,"\n")
    check(rendered==table.concat(lines,"\n"),"No missing, hidden or reordered financial information")
    local b,e=snapshot.finance.bank,snapshot.finance.economy
    for _,required in {"Live Bank: "..money(b.balanceMinor),"Last confirmed: "..(if snapshot.save.savedBankMinor then money(snapshot.save.savedBankMinor) else "Unavailable"),"Electricity sales: "..money(e.baseSalesMinor),"Variable generation costs (includes fuel): "..money(e.variableExpenseMinor),"Fixed running costs: "..money(e.fixedExpenseMinor),"Net earnings: "..money(e.baseSalesMinor-e.variableExpenseMinor-e.fixedExpenseMinor),"Operating buffer: "..money(b.operatingBufferMinor),"Construction spending: 1000.00 Credits","Save: "..snapshot.save.state,"Unsaved earnings and electricity may roll back together."} do
     check(string.find(rendered,required,1,true)~=nil,"Authoritative financial value/warning visible: "..required)
    end
    check(scroll.AbsoluteCanvasSize.Y>=bottom and scroll.AbsoluteCanvasSize.Y<=bottom+20,"Canvas encloses complete content with bounded trailing space")
   end
   scroll.CanvasPosition=Vector2.new(0,scroll.AbsoluteCanvasSize.Y);layout()
   check(scroll.AbsoluteWindowSize.Y>0,"Positive financial viewport at supported size/scale")
   check(math.abs(scroll.CanvasPosition.Y-math.max(0,scroll.AbsoluteCanvasSize.Y-scroll.AbsoluteWindowSize.Y))<=1,"Bottommost financial information reachable")
  end
 end
 app.view.root.Size=originalSize;app.view.root:SetAttribute("TextScale",originalScale);app.refresh();layout()
 print("[Bank structured coverage] PASS",count,"assertions / 12 size-scale combinations")
 return count
end
