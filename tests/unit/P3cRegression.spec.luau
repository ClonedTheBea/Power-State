--!strict
return function()
 assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Isolated Test only")
 require(script.Parent["P3a.spec"])()
 require(script.Parent["P3b.spec"])()
 require(script.Parent["P3b3.spec"])()
 require(script.Parent["P3b4.spec"])()
 require(script.Parent["P3b5.spec"])()
 require(script.Parent["P2b1Scheduler.spec"])()
 require(script.Parent["P3cAccounting.spec"])()
 require(script.Parent["P3cWorld.spec"])()
 print("[P3c retained server regression] PASS; fake/local only")
end
