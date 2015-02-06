AddAISystem = System()

AddAISystem.Initialize = function(self)
	self:SetName("AI System")
	
	--	Toggle EntitiesAdded
	self:UsingEntitiesAdded()
	
	self:AddComponentTypeToFilter("AI", FilterType.RequiresOneOf)
	self:AddComponentTypeToFilter("PlayerCounter", FilterType.RequiresOneOf)
	
	Console.AddCommand("AddAI", self.AddAI)
end

AddAISystem.AddAI = function(_command, ...)

	local newAI = world:CreateNewEntity("AI")
end

AddAISystem.EntitiesAdded = function(self, dt, taskIndex, taskCount, entities)
	
	for	i = 1, #entities do
		if world:EntityHasComponent(entities[i], "AI") then
			
			local counterEntities = self:GetEntities("PlayerCounter")
			local counterComp = world:GetComponent(counterEntities[1], "PlayerCounter", 0)
			local maxPlayers, noOfPlayers = counterComp:GetInt2()
			
			local newName = "Player_" .. tostring(noOfPlayers + 1)
			world:SetComponent(entities[i], "PlayerName", "Name", newName)
			world:SetComponent(entities[i], "PlayerNumber", "Number", noOfPlayers + 1)
			
			self:CounterComponentChanged(1, "Players")
			
			world:CreateComponentAndAddTo("NeedUnit", entities[i])
			
			print("AI Added")
		end
	end
end

AddAISystem.CounterComponentChanged = function(self, _change, _component)
	
	local counterEntities = self:GetEntities("PlayerCounter")
	local counterComp = world:GetComponent(counterEntities[1], "PlayerCounter", _component)
	local number = counterComp:GetInt()
	number = number + _change
	world:SetComponent(counterEntities[1], "PlayerCounter", _component, number)
end