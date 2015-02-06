RespawnSystem = System()

RespawnSystem.Initialize = function(self)

	--	Set Name
	self:SetName("RespawnSystem")
	
	--	Toggle EntitiesAdded
	self:UsingEntitiesAdded()
	
	--	Set Filter
	self:AddComponentTypeToFilter("UnitDead", FilterType.RequiresOneOf)
	self:AddComponentTypeToFilter("RespawnUnits", FilterType.RequiresOneOf)
end

RespawnSystem.EntitiesAdded = function(self, dt, taskIndex, taskCount, entities)

	for n = 1, #entities do
		local entityId = entities[n]
		if world:EntityHasComponent( entityId, "RespawnUnits") then
			
			local units = self:GetEntities("UnitDead")

			for i = 1, #units do
				
				world:RemoveComponentFrom("UnitDead", units[i])
				world:CreateComponentAndAddTo("Spawn", units[i])

			end

			world:KillEntity( entityId )
		end
	end
end
