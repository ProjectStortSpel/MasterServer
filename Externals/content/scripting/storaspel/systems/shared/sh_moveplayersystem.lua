TrueTestMoveSystem = System()

TrueTestMoveSystem.Initialize = function(self)
	
	self:SetName("TrueTestMoveSystem")
	
	self:AddComponentTypeToFilter("MapPosition",FilterType.Mandatory)
	self:AddComponentTypeToFilter("Unit", FilterType.Mandatory)
	self:AddComponentTypeToFilter("Position",FilterType.Mandatory)

end

TrueTestMoveSystem.OnEntityAdded = function(self, entity)
	
end

TrueTestMoveSystem.Update = function(self, dt)
	local entities = self:GetEntities()

	for i = 1, #entities do

		local entity = entities[i]
		local mapPositionX, mapPositionZ = world:GetComponent(entity, "MapPosition", 0):GetInt2()
		local pos = world:GetComponent(entity, "Position", 0)
		local newPosX, newPosY, newPosZ = pos:GetFloat3()
		
		if mapPositionX ~= newPosX or mapPositionZ ~= newPosZ 
		then
			local dirposX = mapPositionX - newPosX;
			local dirposZ = mapPositionZ - newPosZ;
			local tempX = math.abs(dirposX)
			local tempZ = math.abs(dirposZ)
			local total = math.sqrt(dirposX*dirposX + dirposZ*dirposZ)

			dirposX = dirposX/total
			dirposZ = dirposZ/total

			local walkX = dirposX * dt * 1.5
			local walkZ = dirposZ * dt * 1.5

			newPosX = newPosX + walkX
			newPosZ = newPosZ + walkZ

			if tempX < walkX then
				newPosX = mapPositionX
			end
			if tempZ < walkZ  then
				newPosZ = mapPositionZ
			end

			world:GetComponent(entity, "Position", 0):SetFloat3(newPosX, newPosY, newPosZ, false)
		end

	end
end