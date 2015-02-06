PickBoxSystem = System()

PickBoxSystem.Initialize = function(self)
	--	Set Name
	self:SetName("PickBoxSystem")
	
	--	Toggle EntitiesAdded
	self:UsingUpdate()

	--	Set Filter
	self:AddComponentTypeToFilter("Position", FilterType.Mandatory)
	self:AddComponentTypeToFilter("Scale", FilterType.Mandatory)
	self:AddComponentTypeToFilter("PickBox", FilterType.Mandatory)
end

PickBoxSystem.Update = function(self, dt, taskIndex, taskCount)
	-- Fetch Aspect ratio from graphics:
	local AspectX, AspectY = GraphicDevice.GetAspectRatio()

	-- Get touch position for ray
	local tX, tY = GraphicDevice.GetTouchPosition()

	-- Calc view space ray dir
	local rX = tX * AspectX * -2
	local rY = tY * AspectY * -2
	
	local t = -10000000
	local newhit = nil
	local hit = false
	
	---- intersect section
	local entities = self:GetEntities()
	for i = 1, #entities do
		local entity = entities[i]
		
		local scale = self:GetComponent(entity, "Scale", 0)
		local position = self:GetComponent(entity, "Position", 0)
		local pickbox = self:GetComponent(entity, "PickBox", 0)
		
		-- Get the pickbox size
		local halfwidth = pickbox:GetFloat(0) * 0.5
		local halfheight = pickbox:GetFloat(1) * 0.5
		
		-- Get scale and multiply with halfsize
		local sX, sY, sZ = scale:GetFloat3()
		halfwidth = halfwidth * sX
		halfheight = halfheight * sY
		
		-- Get position of object
		local X, Y, Z = position:GetFloat3()
		
		-- Calc ray distance from Z
		local hitX = rX * Z
		local hitY = rY * Z
		
		-- check if pickbox is hit
		if Z < 0.1 and Z > t then
			if hitX > X-halfwidth and hitX < X+halfwidth then
				if hitY > Y-halfheight and hitY < Y+halfheight then
						hit = true
						newhit = entity
						t = Z
				end
			end
		end
	end
	if hit == true then
		-- ADD OnPickBoxHit to newhit
		if not world:EntityHasComponent(newhit, "OnPickBoxHit") then
			world:CreateComponentAndAddTo("OnPickBoxHit", newhit)
		end
		-- Clear OnPickBoxHit from other entities
		local entities = self:GetEntities("OnPickBoxHit")
		for i = 1, #entities do
			local entity = entities[i]
			if entity ~= newhit then
				if world:EntityHasComponent(entity, "OnPickBoxHit") then
					world:RemoveComponentFrom("OnPickBoxHit", entity)
				end
			end
		end
	else
		-- Clear OnPickBoxHit from entities
		local entities = self:GetEntities("OnPickBoxHit")
		for i = 1, #entities do
			local entity = entities[i]
			world:RemoveComponentFrom("OnPickBoxHit", entity)
		end
	end
end
