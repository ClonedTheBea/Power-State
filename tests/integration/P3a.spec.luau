--!strict
return function(playerGui:PlayerGui)
 assert(game.GameId==10776833313 and game:GetService("RunService"):IsStudio(),"Test only")
 require(script.Parent["P2b.spec"])(playerGui,"P3a")
 require(script.Parent["P2aRemote.spec"])("P3a")
 local Client=require(script.Parent.Parent.Client.Simulation.SimulationClient)
 local existing=playerGui:FindFirstChild("PowerStateShell");if existing then existing:Destroy()end
 local live=Client.mount(playerGui,"P3a")
 local current=live.current()
 assert(current.epoch~=current.world.countryId,"Session epoch differs from country identity")
 assert(current.bankMinor==0 and current.save.storage=="Fake","Nonspendable zero Bank; honest fake mode")
 assert(live.app.view.kpis.cards[1].value.Text=="0 Credits","Bank display zero")
 local encoded=game:GetService("HttpService"):JSONEncode(current)
 for _,private in {"ownerSessionId","expiresAtUtcMs","lastCommit","sessionEpoch"}do assert(not string.find(encoded,private,1,true),"Private lease field leaked")end
 assert(live.app.view.root:GetAttribute("SaveStatus")~=nil,"Sanitised save status exposed")
 -- Synthetic presentation inputs only: these do not claim real storage failures occurred.
 local savedStatus=current.save.state;local suspended=current.suspended
 for _,status in {"Live","Saving","Delayed","Suspended"}do
  current.save.state=status;current.suspended=status=="Suspended";live.app.refresh()
  assert(live.app.view.root:GetAttribute("SaveStatus")==status,"Save status presentation")
  if status=="Suspended" then assert(not live.toggle.Active,"Suspended control disabled")end
 end
 current.save.state=savedStatus;current.suspended=suspended;live.app.refresh()
 live.app.actions[live.app.view.header.overview]()
 local zero=false
 for _,object in live.app.view.feedback.root:GetDescendants()do
  if object:IsA("TextLabel") and string.find(object.Text,"Bank:",1,true)then
   assert(string.find(object.Text,"Bank: 0 Credits",1,true),"Overview cannot show preview funds");zero=true
  end
 end
 assert(zero,"Bank overview checked");live.app.actions[live.app.view.feedback.close]()
 print("[P3a live fake GUI] PASS 15 presentation/privacy assertions; status changes synthetic; remounted for inspection")
 return live
end
