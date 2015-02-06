CreateMapSystem = System()
CreateMapSystem.entities = nil
CreateMapSystem.waterTiles = nil
CreateMapSystem.mapX = 0
CreateMapSystem.mapY = 0

CreateMapSystem.Initialize = function(self)
	self:SetName("CreateMapSystem")
	self:UsingEntitiesAdded()
	self:AddComponentTypeToFilter("CreateMap", FilterType.RequiresOneOf)
	self:AddComponentTypeToFilter("MapSize", FilterType.RequiresOneOf)
	Console.AddCommand("loadmap", self.LoadMap)
end

CreateMapSystem.PostInitialize = function(self)
	--local inputData = InputData()
	--local map
    --self.mapX, self.mapY, map = File.LoadMap("content/maps/mapsda.txt")
	--
    --local posX, posZ
	--
	--for x = 0, self.mapX+1 do
	--	self:AddTile(x, 0, 111) -- 111 = void
	--	inputData:AddTile( 1, true )
	--end
	--
	--local highestCP = 0
	--local finishList = { }
	--finishList.__mode = "k"
	--
	--for y = 1, self.mapY do
	--	self:AddTile(0, y, 111) -- 111 = void
	--	inputData:AddTile( 1, true )
	--	for x = 1, self.mapX do
	--		local tiletype = map[(y - 1) * self.mapX + x]
	--		
    --        local entity = self:AddTile(x, y, tiletype)
	--		if tiletype == 120  
	--		then
	--			inputData:AddTile( 1, false )
	--		else
	--			inputData:AddTile( 1, true )
	--		end
	--		if tiletype >= 49 and tiletype <= 57 then -- 49 = 1 = first checkpoint, 57 = 9 = 9th checkpoint
    --
	--			highestCP = math.max(highestCP, tiletype - 48)
    --
	--		elseif tiletype == 102 then -- 102 = f = finish
	--			
	--			finishList[#finishList + 1] = entity
    --
	--		end
    --    end
	--	self:AddTile(self.mapX + 1, y, 111) -- 111 = void
	--	inputData:AddTile( 1, true )
    --end
	--
	--for i = 1, #finishList do
    --
	--	local comp = self:GetComponent(finishList[i], "Checkpoint", 0)
    --    comp:SetInt(highestCP + 1)
    --
	--end
	--
	--for x = 0, self.mapX+1 do
	--	self:AddTile(x, self.mapY+1, 111) -- 111 = void
	--	inputData:AddTile( 1, true )
	--end
	--
	---- Add to the map size as voids have been added around the map.
	--self.mapX = self.mapX + 2
	--self.mapY = self.mapY + 2
	--
	--inputData:SetSize(self.mapX, self.mapY)
	--
	--PathfinderHandler.SetData(inputData)
	--
	--PathfinderHandler.GeneratePath(4,4, 4, 5)
	--
	---- Create an entity that will keep track of the map size.
	--local mapEntity = world:CreateNewEntity()
	--world:CreateComponentAndAddTo("MapSize", mapEntity)
	--world:CreateComponentAndAddTo("SyncNetwork", mapEntity)
	--self:GetComponent(mapEntity, "MapSize", 0):SetInt2(self.mapX, self.mapY)
    --
	--for waterA = 1, #self.waterTiles do
	--	
	--	local waterPosA = world:GetComponent(self.waterTiles[waterA], "MapPosition", 0)
	--	local waterDirA = world:GetComponent(self.waterTiles[waterA], "River", 0)
	--	local posAX, posAY = waterPosA:GetInt2()
	--	local dirAX, dirAY = waterDirA:GetInt2()
    --
	--	--print("Water[ " .. posAX .. ", " .. posAY .. "] with direction [" .. dirAX .. ", " .. dirAY .. "]")
    --
	--	for waterB = 1, #self.waterTiles do
    --
	--		if waterA ~= waterB then
	--			local waterPosB = world:GetComponent(self.waterTiles[waterB], "MapPosition", 0)
	--			local waterDirB = world:GetComponent(self.waterTiles[waterB], "River", 0)
	--			local posBX, posBY = waterPosB:GetInt2()
	--			local dirBX, dirBY = waterDirB:GetInt2()
    --
	--			if posAX + dirAX == posBX and posAY + dirAY == posBY then
	--				if dirAX ~= dirBX and dirAY ~= dirBY then
    --
	--					local comp = self:GetComponent(self.waterTiles[waterB], "Model", 0)
	--					comp:SetModel("rivercorner", "rivercorner", 0, 0)
    --
    --
	--					--	LEFT TURN (Correct rotation)
	--					--if dirAX == 1 and dirBY == -1 then
	--					--elseif dirAX == -1 and dirBY == 1 then
	--					--elseif dirAY == -1 and dirBX == -1 then
	--					--elseif dirAY == 1 and dirBX == 1 then
    --
	--					local comp = self:GetComponent(self.waterTiles[waterB], "Rotation", 0)
	--					local currentRotation = comp:GetFloat(1)
    --
	--					--	RIGHT TURN
	--					if dirAX == 1 and dirBY == 1 then
	--						comp:SetFloat3(0, currentRotation - math.pi/2, 0)
	--					elseif dirAX == -1 and dirBY == -1 then
	--						comp:SetFloat3(0, currentRotation - math.pi/2, 0)
	--					elseif dirAY == 1 and dirBX == -1 then
	--						comp:SetFloat3(0, currentRotation - math.pi/2, 0)
	--					elseif dirAY == -1 and dirBX == 1 then
	--						comp:SetFloat3(0, currentRotation - math.pi/2, 0)
	--					end
    --
	--				end
	--			end
	--		end
	--	end
	--end
	self:CreateMap("content/maps/map.txt")
end

CreateMapSystem.EntitiesAdded = function(self, dt, taskIndex, taskCount, entities)
	for i = 1, #entities do
		local entity = entities[i]
		if world:EntityHasComponent(entity, "CreateMap") then
			local name = world:GetComponent(entity, "CreateMap", 0):GetString()
			print( name )
			self:CreateMap(name)
			world:KillEntity(entity)
		end
	end
end

CreateMapSystem.AddTile = function(self, posX, posZ, tiletype)
	
    local newTile = world:CreateNewEntity("Tile")
    local posComp = self:GetComponent(newTile, "Position", 0)
    posComp:SetFloat3(posX, 0.0, posZ)
	
    local mapPosComp = self:GetComponent(newTile, "MapPosition", 0)
    mapPosComp:SetInt2(posX, posZ)
    if tiletype == 104 then -- 104 = h = hole
        world:CreateComponentAndAddTo("Void", newTile)
		world:CreateComponentAndAddTo("Model", newTile)
		local comp = self:GetComponent(newTile, "Model", 0)
		comp:SetModel("hole", "hole", 0)
		local rotComp = self:GetComponent(newTile, "Rotation", 0)
		rotComp:SetFloat3(0, math.pi * 0.5 * math.random(0, 4), 0)
		
    elseif tiletype == 120 then -- 120 = x = stone
		world:CreateComponentAndAddTo("NotWalkable", newTile)
		world:CreateComponentAndAddTo("Model", newTile)
		local comp = self:GetComponent(newTile, "Model", 0)
		comp:SetModel("stone", "stone", 0)
		posComp:SetFloat3(posX, 0.8 + 0.1* math.random(-1, 1), posZ)
		
		local rotComp = self:GetComponent(newTile, "Rotation", 0)
		rotComp:SetFloat3(math.pi * 0.01 * math.random(0, 25), math.pi * 0.01 * math.random(0, 100), math.pi * 0.01 * math.random(0, 25))
		self:AddGroundTileBelow(posX, posZ)
    elseif tiletype >= 49 and tiletype <= 57 then -- 49 = 1 = first checkpoint, 57 = 9 = 9th checkpoint

        world:CreateComponentAndAddTo("Checkpoint", newTile)
        local comp = self:GetComponent(newTile, "Checkpoint", 0)
        comp:SetInt(tiletype - 48)
		world:CreateComponentAndAddTo("Model", newTile)
		local comp = self:GetComponent(newTile, "Model", 0)
		
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
        world:CreateComponentAndAddTo("Finishpoint", newTile)
		world:CreateComponentAndAddTo("Checkpoint", newTile)
		world:CreateComponentAndAddTo("Model", newTile)
		local comp = self:GetComponent(newTile, "Model", 0)
		comp:SetModel("finish", "finish", 0)
		--posComp:SetFloat3(posX, 1.0, posZ)

    elseif tiletype == 117 then -- 117 = u = water up
        world:CreateComponentAndAddTo("River", newTile)
        local comp = self:GetComponent(newTile, "River", 0)
        comp:SetInt3(0, -1, 1)
		local comp = self:GetComponent(newTile, "Rotation", 0)
		comp:SetFloat3(0, -math.pi/2, 0)
		world:CreateComponentAndAddTo("Model", newTile)
		local comp = self:GetComponent(newTile, "Model", 0)
		comp:SetModel("riverstraight", "riverstraight", 0)

		self.waterTiles[#self.waterTiles+1]=newTile
		
    elseif tiletype == 100 then -- 100 = d = water down
        world:CreateComponentAndAddTo("River", newTile)
        local comp = self:GetComponent(newTile, "River", 0)
        comp:SetInt3(0, 1, 1)
		local comp = self:GetComponent(newTile, "Rotation", 0)
		comp:SetFloat3(0, math.pi/2, 0)
		world:CreateComponentAndAddTo("Model", newTile)
		local comp = self:GetComponent(newTile, "Model", 0)
		comp:SetModel("riverstraight", "riverstraight", 0)

		self.waterTiles[#self.waterTiles+1]=newTile
		
    elseif tiletype == 108 then -- 108 = l = water left
        world:CreateComponentAndAddTo("River", newTile)
        local comp = self:GetComponent(newTile, "River", 0)
        comp:SetInt3(-1, 0, 1)
		world:CreateComponentAndAddTo("Model", newTile)
		local comp = self:GetComponent(newTile, "Model", 0)
		comp:SetModel("riverstraight", "riverstraight", 0)

		self.waterTiles[#self.waterTiles+1]=newTile
		
    elseif tiletype == 114 then -- 114 = r = water right
        world:CreateComponentAndAddTo("River", newTile)
        local comp = self:GetComponent(newTile, "River", 0)
        comp:SetInt3(1, 0, 1)
		local comp = self:GetComponent(newTile, "Rotation", 0)
		comp:SetFloat3(0, math.pi, 0)
		world:CreateComponentAndAddTo("Model", newTile)
		local comp = self:GetComponent(newTile, "Model", 0)
		comp:SetModel("riverstraight", "riverstraight", 0)

		self.waterTiles[#self.waterTiles+1]=newTile
		
	elseif tiletype == 115 then -- 115 = s = Available spawn point
		world:CreateComponentAndAddTo("Model", newTile)
		local comp = self:GetComponent(newTile, "Model", 0)
		comp:SetModel("grass", "grass", 0, 0)
		
		
		local newSpawnId = world:CreateNewEntity()
		world:CreateComponentAndAddTo("AvailableSpawnpoint", newSpawnId)
		local newSpawn = self:GetComponent(newSpawnId, "AvailableSpawnpoint", 0)
		newSpawn:SetInt2(posX, posZ)
		
	elseif tiletype == 46 then -- 46 = . = grass
		world:CreateComponentAndAddTo("Model", newTile)
		local comp = self:GetComponent(newTile, "Model", 0)
		comp:SetModel("grass", "grass", 0)
		
	else
        world:CreateComponentAndAddTo("Void", newTile)
		--world:CreateComponentAndAddTo("Model", entity)
		--local comp = self:GetComponent(entity, "Model", 0)
		--comp:SetModel("grass", "grass", 0)
		
    end
	
	self.entities[#self.entities+1]=newTile
	return newTile
end

CreateMapSystem.AddGroundTileBelow = function(self, posX, posZ)

	local groundEntity = world:CreateNewEntity("Tile")
	local posComp = self:GetComponent(groundEntity, "Position", 0)
	posComp:SetFloat3(posX, 0.0, posZ)
	
	local mapPosComp = self:GetComponent(groundEntity, "MapPosition", 0)
	mapPosComp:SetInt2(posX, posZ)
	
	world:CreateComponentAndAddTo("Model", groundEntity)
	local comp = self:GetComponent(groundEntity, "Model", 0)
	comp:SetModel("grass", "grass", 0)
	
	--table.insert(self.entities, groundEntity)
end 

CreateMapSystem.CreateMap = function(self, name)
	self.entities = { }
	self.entities.__mode = "k"
	self.waterTiles = { }
	self.waterTiles.__mode = "k"
	
	local inputData = InputData()
	local map
    self.mapX, self.mapY, map = File.LoadMap(name)

	print("MapSize:", self.mapX, self.mapY)
		
	for x = 0, self.mapX + 1 do
		self:AddTile(x, 0, 111) -- 111 = void
		inputData:AddTile( 1, true )
	end
	
	local highestCP = 0
	local finishList = { }
	finishList.__mode = "k"
	
	for y = 1, self.mapY do
		self:AddTile(0, y, 111) -- 111 = void
		inputData:AddTile( 1, true )
		for x = 1, self.mapX do
			local tiletype = map[(y - 1) * self.mapX + x]			
            local entity = self:AddTile(x, y, tiletype)
			if tiletype == 120  
			then
				inputData:AddTile( 1, false )
			else
				inputData:AddTile( 1, true )
			end
			if tiletype >= 49 and tiletype <= 57 then -- 49 = 1 = first checkpoint, 57 = 9 = 9th checkpoint

				highestCP = math.max(highestCP, tiletype - 48)

			elseif tiletype == 102 then -- 102 = f = finish
				
				finishList[#finishList + 1] = entity

			end
        end
		self:AddTile(self.mapX + 1, y, 111) -- 111 = void
		inputData:AddTile( 1, true )
    end

	for i = 1, #finishList do

		local comp = self:GetComponent(finishList[i], "Checkpoint", 0)
        comp:SetInt(highestCP + 1)

	end
	
	for x = 0, self.mapX + 1 do
		self:AddTile(x, self.mapY+1, 111) -- 111 = void
		inputData:AddTile( 1, true )
	end
	
	-- Add to the map size as voids have been added around the map.
	self.mapX = self.mapX + 2
	self.mapY = self.mapY + 2
	
	inputData:SetSize(self.mapX, self.mapY)
	
	PathfinderHandler.SetData(inputData)
	
	-- Create an entity that will keep track of the map size.
	local MapSizeEntities = self:GetEntities("MapSize")
	local MapEntity = nil
	if #MapSizeEntities == 0 then
		MapEntity = world:CreateNewEntity()
		world:CreateComponentAndAddTo("MapSize", MapEntity)
		world:CreateComponentAndAddTo("SyncNetwork", MapEntity)
	else
		MapEntity = MapSizeEntities[1]
	end
	self:GetComponent(MapEntity, "MapSize", 0):SetInt2(self.mapX, self.mapY)
	
	print("MapEntity size: " .. #self.entities)
	print("Water size: " .. #self.waterTiles)

	for waterA = 1, #self.waterTiles do
		
		local waterPosA = world:GetComponent(self.waterTiles[waterA], "MapPosition", 0)
		local waterDirA = world:GetComponent(self.waterTiles[waterA], "River", 0)
		local posAX, posAY = waterPosA:GetInt2()
		local dirAX, dirAY = waterDirA:GetInt2()

		--print("Water[ " .. posAX .. ", " .. posAY .. "] with direction [" .. dirAX .. ", " .. dirAY .. "]")

		for waterB = 1, #self.waterTiles do

			if waterA ~= waterB then
				local waterPosB = world:GetComponent(self.waterTiles[waterB], "MapPosition", 0)
				local waterDirB = world:GetComponent(self.waterTiles[waterB], "River", 0)
				local posBX, posBY = waterPosB:GetInt2()
				local dirBX, dirBY = waterDirB:GetInt2()

				if posAX + dirAX == posBX and posAY + dirAY == posBY then
					if dirAX ~= dirBX and dirAY ~= dirBY then

						local comp = self:GetComponent(self.waterTiles[waterB], "Model", 0)
						comp:SetModel("rivercorner", "rivercorner", 0, 0)

						--	LEFT TURN (Correct rotation)
						--if dirAX == 1 and dirBY == -1 then
						--elseif dirAX == -1 and dirBY == 1 then
						--elseif dirAY == -1 and dirBX == -1 then
						--elseif dirAY == 1 and dirBX == 1 then

						local comp = self:GetComponent(self.waterTiles[waterB], "Rotation", 0)
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

	finishList = nil
	self.waterTiles = nil
	self.entities = nil
	collectgarbage()
end

CreateMapSystem.LoadMap = function (_command, ...)
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
