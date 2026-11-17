--!strict
game:GetService("Players").CharacterAutoLoads = false
-- This gameplay proof is never activated outside the owner's isolated Studio Test universe.
if game:GetService("RunService"):IsStudio() and game.GameId == 10776833313 then
 require(script.Parent.Simulation.SimulationService).start()
 require(script.Parent.World.GeneratedService).start()
end
