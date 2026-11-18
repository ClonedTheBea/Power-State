--!strict
game:GetService("Players").CharacterAutoLoads = false
-- One normal fake-storage loop, only in the isolated Studio Test universe.
if game:GetService("RunService"):IsStudio() and game.GameId == 10776833313 then
 require(script.Parent.Services.ConstructionTestService).start()
 require(script.Parent.Operations.OperationsService).start()
 if game.ReplicatedStorage:GetAttribute("RunRegressionTests")==true then
  require(script.Parent.Simulation.SimulationService).start()
  require(script.Parent.World.GeneratedService).start()
 end
end
