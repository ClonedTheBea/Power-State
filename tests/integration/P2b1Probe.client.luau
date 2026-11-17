--!strict
-- Dormant in ordinary Test runs; the server harness clones it with explicit adversarial fixtures.
if not game:GetService("RunService"):IsStudio() or game.GameId~=10776833313 then return end
local peerEpoch=script:GetAttribute("PeerEpoch")
local peerGenerator=script:GetAttribute("PeerGenerator")
if type(peerEpoch)~="string" or type(peerGenerator)~="string" then return end
local tests=game:GetService("StarterPlayer").StarterPlayerScripts.DevelopmentTests
require(tests["P2b1.spec"])(peerEpoch,peerGenerator)
script:Destroy()
