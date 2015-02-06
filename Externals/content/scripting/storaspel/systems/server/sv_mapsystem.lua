MapSystem = System()
MapSystem.entities = { }
MapSystem.mapX = 0
MapSystem.mapY = 0

MapSystem.Initialize = function(self)
	self:SetName("MapSystem System")
	self:AddComponentTypeToFilter("CreateMap", FilterType.Mandatory)
	Console.AddCommand("loadmap", self.LoadMap)
end

MapSystem.LoadMap = function (_command, ...)

	local args = { ... }
	if #args == 1 then
		if type(args[1]) == "string" then
			print( args[1] )
			local id = world:CreateNewEntity()
			world:CreateComponentAndAddTo("CreateMap", id)
			world:GetComponent(id, "CreateMap", 0):SetString(args[1])
		end
	else
		local id = world:CreateNewEntity()
		world:CreateComponentAndAddTo("CreateMap", id)
		world:GetComponent(id, "CreateMap", 0):SetString("content/maps/smallmap.txt")
	end
end

MapSystem.OnEntityAdded = function(self, entity)

	local name = world:GetComponent(entity, "CreateMap", 0):GetString()
	print( name )
	local map
    self.mapX, self.mapY, map = File.LoadMap(name)

	--local map
    --self.mapX, self.mapY, map = File.LoadMap("content/maps/smallmap.txt")

	--local mapComp = self:GetComponent(entity, "Rotation", 0)
	--rotComp:SetFloat3(0, math.pi * 0.5 * math.random(0, 4), 0)
	print("MapSize:", self.mapX, self.mapY)
		
	for x = 0, self.mapX + 1 do
		self:AddTile(x, 0, 111) -- 111 = void
	end
	
	local highestCP = 0
	local finishList = { }
	
	for y = 1, self.mapY do
		self:AddTile(0, y, 111) -- 111 = void
		for x = 1, self.mapX do
			local tiletype = map[(y - 1) * self.mapX + x]			
            local entity = self:AddTile(x, y, tiletype)

			if tiletype >= 49 and tiletype <= 57 then -- 49 = 1 = first checkpoint, 57 = 9 = 9th checkpoint

				highestCP = math.max(highestCP, tiletype - 48)

			elseif tiletype == 102 then -- 102 = f = finish
				
				finishList[#finishList + 1] = entity

			end
        end
		self:AddTile(self.mapX + 1, y, 111) -- 111 = void
    end

	for i = 1, #finishList do

		local comp = self:GetComponent(finishList[i], "Checkpoint", 0)
        comp:SetInt(highestCP + 1)

	end
	
	for x = 0, self.mapX + 1 do
		self:AddTile(x, self.mapY+1, 111) -- 111 = void
	end
	
	-- Add to the map size as voids have been added around the map.
	self.mapX = self.mapX + 2
	self.mapY = self.mapY + 2
	
	-- Create an entity that will keep track of the map size.
	local mapEntity = world:CreateNewEntity()
	world:CreateComponentAndAddTo("MapSize", mapEntity)
	self:GetComponent(mapEntity, "MapSize", 0):SetInt2(self.mapX, self.mapY)
	    
	local activeEntities = MapSystem.entities
	local waterTiles = {}
	for i = 1, #activeEntities do
		if world:EntityHasComponent(activeEntities[i], "River") then
			waterTiles[#waterTiles + 1] = activeEntities[i]
		end
	end

	print("Water size: " .. #waterTiles)

	for waterA = 1, #waterTiles do
		
		local waterPosA = world:GetComponent(waterTiles[waterA], "MapPosition", 0)
		local waterDirA = world:GetComponent(waterTiles[waterA], "River", 0)
		local posAX, posAY = waterPosA:GetInt2()
		local dirAX, dirAY = waterDirA:GetInt2()

		--print("Water[ " .. posAX .. ", " .. posAY .. "] with direction [" .. dirAX .. ", " .. dirAY .. "]")

		for waterB = 1, #waterTiles do

			if waterA ~= waterB then
				local waterPosB = world:GetComponent(waterTiles[waterB], "MapPosition", 0)
				local waterDirB = world:GetComponent(waterTiles[waterB], "River", 0)
				local posBX, posBY = waterPosB:GetInt2()
				local dirBX, dirBY = waterDirB:GetInt2()

				if posAX + dirAX == posBX and posAY + dirAY == posBY then
					if dirAX ~= dirBX and dirAY ~= dirBY then

						local comp = self:GetComponent(waterTiles[waterB], "Model", 0)
						comp:SetModel("rivercorner", "rivercorner", 0, 0)


						--	LEFT TURN (Correct rotation)
						--if dirAX == 1 and dirBY == -1 then
						--elseif dirAX == -1 and dirBY == 1 then
						--elseif dirAY == -1 and dirBX == -1 then
						--elseif dirAY == 1 and dirBX == 1 then

						local comp = self:GetComponent(waterTiles[waterB], "Rotation", 0)
						local currentRotation = comp:GetFloat(1)

						--	RIGHT TURN
						if dirAX == 1 and dirBY == 1 then
							comp:SetFloat3(0, currentRotation - math.pi/2, 0)
						elseif dirAX == -1 and dirBY == -1 then
							comp:SetFloat3(0, currentRotation - math.pi/2, 0)
						elseif dirAY == 1 and dirBX == -1 then
							comp:SetFloat3(0, currentRotation - math.pi/2, 0)
						elseif dirAY == -1 and dirBX == 1 then
							comp:SetFloat3(0, currentRotation - math.pi/2, 0)
						end



					end
				end
			end
		end

	end
	world:KillEntity(entity)
end

MapSystem.PostInitialize = function(self)
	local map
    self.mapX, self.mapY, map = File.LoadMap("content/maps/smallmap.txt")

	--local mapComp = self:GetComponent(entity, "Rotation", 0)
	--rotComp:SetFloat3(0, math.pi * 0.5 * math.random(0, 4), 0)
	print("MapSize:", self.mapX, self.mapY)
		
	for x = 0, self.mapX + 1 do
		self:AddTile(x, 0, 111) -- 111 = void
	end
	
	local highestCP = 0
	local finishList = { }
	
	for y = 1, self.mapY do
		self:AddTile(0, y, 111) -- 111 = void
		for x = 1, self.mapX do
			local tiletype = map[(y - 1) * self.mapX + x]			
            local entity = self:AddTile(x, y, tiletype)

			if tiletype >= 49 and tiletype <= 57 then -- 49 = 1 = first checkpoint, 57 = 9 = 9th checkpoint

				highestCP = math.max(highestCP, tiletype - 48)

			elseif tiletype == 102 then -- 102 = f = finish
				
				finishList[#finishList + 1] = entity

			end
        end
		self:AddTile(self.mapX + 1, y, 111) -- 111 = void
    end

	for i = 1, #finishList do

		local comp = self:GetComponent(finishList[i], "Checkpoint", 0)
        comp:SetInt(highestCP + 1)

	end
	
	for x = 0, self.mapX + 1 do
		self:AddTile(x, self.mapY+1, 111) -- 111 = void
	end
	
	-- Add to the map size as voids have been added around the map.
	self.mapX = self.mapX + 2
	self.mapY = self.mapY + 2 
	
	-- Create an entity that will keep track of the map size.
	local mapEntity = world:CreateNewEntity()
	world:CreateComponentAndAddTo("MapSize", mapEntity)
	self:GetComponent(mapEntity, "MapSize", 0):SetInt2(self.mapX, self.mapY)
    
	local activeEntities = MapSystem.entities
	local waterTiles = {}
	for i = 1, #activeEntities do
		if world:EntityHasComponent(activeEntities[i], "River") then
			waterTiles[#waterTiles + 1] = activeEntities[i]
		end
	end

	print("Water size: " .. #waterTiles)

	for waterA = 1, #waterTiles do
		
		local waterPosA = world:GetComponent(waterTiles[waterA], "MapPosition", 0)
		local waterDirA = world:GetComponent(waterTiles[waterA], "River", 0)
		local posAX, posAY = waterPosA:GetInt2()
		local dirAX, dirAY = waterDirA:GetInt2()

		--print("Water[ " .. posAX .. ", " .. posAY .. "] with direction [" .. dirAX .. ", " .. dirAY .. "]")

		for waterB = 1, #waterTiles do

			if waterA ~= waterB then
				local waterPosB = world:GetComponent(waterTiles[waterB], "MapPosition", 0)
				local waterDirB = world:GetComponent(waterTiles[waterB], "River", 0)
				local posBX, posBY = waterPosB:GetInt2()
				local dirBX, dirBY = waterDirB:GetInt2()

				if posAX + dirAX == posBX and posAY + dirAY == posBY then
					if dirAX ~= dirBX and dirAY ~= dirBY then

						local comp = self:GetComponent(waterTiles[waterB], "Model", 0)
						comp:SetModel("rivercorner", "rivercorner", 0, 0)


						--	LEFT TURN (Correct rotation)
						--if dirAX == 1 and dirBY == -1 then
						--elseif dirAX == -1 and dirBY == 1 then
						--elseif dirAY == -1 and dirBX == -1 then
						--elseif dirAY == 1 and dirBX == 1 then

						local comp = self:GetComponent(waterTiles[waterB], "Rotation", 0)
						local currentRotation = comp:GetFloat(1)

						--	RIGHT TURN
						if dirAX == 1 and dirBY == 1 then
							comp:SetFloat3(0, currentRotation - math.pi/2, 0)
						elseif dirAX == -1 and dirBY == -1 then
							comp:SetFloat3(0, currentRotation - math.pi/2, 0)
						elseif dirAY == 1 and dirBX == -1 then
							comp:SetFloat3(0, currentRotation - math.pi/2, 0)
						elseif dirAY == -1 and dirBX == 1 then
							comp:SetFloat3(0, currentRotation - math.pi/2, 0)
						end



					end
				end
			end
		end

	end

end

MapSystem.AddTile = function(self, posX, posZ, tiletype)
	
    local entity = world:CreateNewEntity("Tile")
    local posComp = self:GetComponent(entity, "Position", 0)
    posComp:SetFloat3(posX, 0.0, posZ)
	
    local mapPosComp = self:GetComponent(entity, "MapPosition", 0)
    mapPosComp:SetInt2(posX, posZ)
		
    if tiletype == 104 then -- 104 = h = hole
        world:CreateComponentAndAddTo("Void", entity)
		world:CreateComponentAndAddTo("Model", entity)
		local comp = self:GetComponent(entity, "Model", 0)
		comp:SetModel("hole", "hole", 0)
		local rotComp = self:GetComponent(entity, "Rotation", 0)
		rotComp:SetFloat3(0, math.pi * 0.5 * math.random(0, 4), 0)

    elseif tiletype == 120 then -- 120 = x = stone
		world:CreateComponentAndAddTo("NotWalkable", entity)
		world:CreateComponentAndAddTo("Model", entity)
		local comp = self:GetComponent(entity, "Model", 0)
		comp:SetModel("stone", "stone", 0)
		posComp:SetFloat3(posX, 0.8 + 0.1* math.random(-1, 1), posZ)
		
		local rotComp = self:GetComponent(entity, "Rotation", 0)
		rotComp:SetFloat3(math.pi * 0.01 * math.random(0, 25), math.pi * 0.01 * math.random(0, 100), math.pi * 0.01 * math.random(0, 25))
		self:AddGroundTileBelow(posX, posZ)

    elseif tiletype >= 49 and tiletype <= 57 then -- 49 = 1 = first checkpoint, 57 = 9 = 9th checkpoint

        world:CreateComponentAndAddTo("Checkpoint", entity)
        local comp = self:GetComponent(entity, "Checkpoint", 0)
        comp:SetInt(tiletype - 48)
		world:CreateComponentAndAddTo("Model", entity)
		local comp = self:GetComponent(entity, "Model", 0)
		
		if tiletype == 49 then
			comp:SetModel("checkpoint1", "checkpoint", 0)
		elseif tiletype == 50 then
			comp:SetModel("checkpoint2", "checkpoint", 0)
		elseif tiletype == 51 then
			comp:SetModel("checkpoint3", "checkpoint", 0)
		elseif tiletype == 52 then
			comp:SetModel("checkpoint4", "checkpoint", 0)
		else
			comp:SetModel("checkpoint", "checkpoint", 0)
		end

		--posComp:SetFloat3(posX, 0.5, posZ)

    elseif tiletype == 102 then -- 102 = f = finish
        world:CreateComponentAndAddTo("Finishpoint", entity)
		world:CreateComponentAndAddTo("Checkpoint", entity)
		world:CreateComponentAndAddTo("Model", entity)
		local comp = self:GetComponent(entity, "Model", 0)
		comp:SetModel("finish", "finish", 0)
		--posComp:SetFloat3(posX, 1.0, posZ)

    elseif tiletype == 117 then -- 117 = u = water up
        world:CreateComponentAndAddTo("River", entity)
        local comp = self:GetComponent(entity, "River", 0)
        comp:SetInt3(0, -1, 1)
		local comp = self:GetComponent(entity, "Rotation", 0)
		comp:SetFloat3(0, -math.pi/2, 0)
		world:CreateComponentAndAddTo("Model", entity)
		local comp = self:GetComponent(entity, "Model", 0)
		comp:SetModel("riverstraight", "riverstraight", 0)

    elseif tiletype == 100 then -- 100 = d = water down
        world:CreateComponentAndAddTo("River", entity)
        local comp = self:GetComponent(entity, "River", 0)
        comp:SetInt3(0, 1, 1)
		local comp = self:GetComponent(entity, "Rotation", 0)
		comp:SetFloat3(0, math.pi/2, 0)
		world:CreateComponentAndAddTo("Model", entity)
		local comp = self:GetComponent(entity, "Model", 0)
		comp:SetModel("riverstraight", "riverstraight", 0)

    elseif tiletype == 108 then -- 108 = l = water left
        world:CreateComponentAndAddTo("River", entity)
        local comp = self:GetComponent(entity, "River", 0)
        comp:SetInt3(-1, 0, 1)
		world:CreateComponentAndAddTo("Model", entity)
		local comp = self:GetComponent(entity, "Model", 0)
		comp:SetModel("riverstraight", "riverstraight", 0)

    elseif tiletype == 114 then -- 114 = r = water right
        world:CreateComponentAndAddTo("River", entity)
        local comp = self:GetComponent(entity, "River", 0)
        comp:SetInt3(1, 0, 1)
		local comp = self:GetComponent(entity, "Rotation", 0)
		comp:SetFloat3(0, math.pi, 0)
		world:CreateComponentAndAddTo("Model", entity)
		local comp = self:GetComponent(entity, "Model", 0)
		comp:SetModel("riverstraight", "riverstraight", 0)
		
	elseif tiletype == 115 then -- 115 = s = Available spawn point
		world:CreateComponentAndAddTo("Model", entity)
		local comp = self:GetComponent(entity, "Model", 0)
		comp:SetModel("grass", "grass", 0, 0)
		
		
		local newSpawnId = world:CreateNewEntity()
		world:CreateComponentAndAddTo("AvailableSpawnpoint", newSpawnId)
		local newSpawn = self:GetComponent(newSpawnId, "AvailableSpawnpoint", 0)
		newSpawn:SetInt2(posX, posZ)
		
	elseif tiletype == 46 then -- 46 = . = grass
		world:CreateComponentAndAddTo("Model", entity)
		local comp = self:GetComponent(entity, "Model", 0)
		comp:SetModel("grass", "grass", 0)
		
	else
        world:CreateComponentAndAddTo("Void", entity)
		--world:CreateComponentAndAddTo("Model", entity)
		--local comp = self:GetComponent(entity, "Model", 0)
		--comp:SetModel("grass", "grass", 0)
		
    end

    table.insert(self.entities, entity)

	return entity
end

MapSystem.AddGroundTileBelow = function(self, posX, posZ)

	local groundEntity = world:CreateNewEntity("Tile")
	
	-- Remove the tile component, as this tile is visual only.
	world:RemoveComponentFrom("TileComp", groundEntity)
	
	local posComp = self:GetComponent(groundEntity, "Position", 0)
	posComp:SetFloat3(posX, 0.0, posZ)
	
	local mapPosComp = self:GetComponent(groundEntity, "MapPosition", 0)
	mapPosComp:SetInt2(posX, posZ)
	
	world:CreateComponentAndAddTo("Model", groundEntity)
	local comp = self:GetComponent(groundEntity, "Model", 0)
	comp:SetModel("grass", "grass", 0)
end