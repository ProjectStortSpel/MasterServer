networkMessagesSystem = System()

networkMessagesSystem.Update = function(self, dt)

	--Net.Update(dt)
	
	--if Server.IsRunning() then
	--	while Server.HandlePacket() > 0 do	end
	--end
		
	--if Client.IsConnected() then
	--	while Client.HandlePacket() > 0 do	end
	--end

end
networkMessagesSystem.Initialize = function(self)
	self:SetName("Network Message System")
	self:InitializeNetworkEvents()
	
	self:AddComponentTypeToFilter("SyncNetwork", FilterType.Mandatory)
end
networkMessagesSystem.OnEntityAdded = function(self, entityId)
	--print("OnEntityAdded (LUA)")
end
networkMessagesSystem.OnEntityRemoved = function(self, entityId)
	--print("OnEntityRemoved (LUA)")
end

networkMessagesSystem.OnBannedFromServer = function(self, _ip, _port, _message)
	local entities = self:GetEntities();
	for i = 1, #entities do
		world:KillEntity(entities[i])
	end

	Net.ResetNetworkMaps()
end

networkMessagesSystem.OnDisconnectedFromServer = function(self, _ip, _port)
	local entities = self:GetEntities();
	for i = 1, #entities do
		world:KillEntity(entities[i])
	end
	
	Net.ResetNetworkMaps()
end
networkMessagesSystem.OnFailedToConnect = function(self, _ip, _port)
	local s = "[Client] Failed to connect to server " .. _ip .. ":" .. _port
	Console.Print(s)	
end
networkMessagesSystem.OnKickedFromServer = function(self, _ip, _port, _message)
	local entities = self:GetEntities();
	for i = 1, #entities do
		world:KillEntity(entities[i])
	end
	
	Net.ResetNetworkMaps()

	local s = "[Client] Kicked from server " .. _ip .. ":" .. _port .. ". Reason: " .. _message
	Console.Print(s)	
end

networkMessagesSystem.OnTimedOutFromServer = function(self, _ip, _port)
	local entities = self:GetEntities();
	for i = 1, #entities do
		world:KillEntity(entities[i])
	end
	Net.ResetNetworkMaps()
end

networkMessagesSystem.OnPlayerConnected = function(self, _ip, _port, _message)
	-- Hämta alla entiteter som har komponenten "SyncNetwork"
	-- Skicka dessa entiteter till klienten
	
	local entities = self:GetEntities();
	
	for i = 1, #entities do
		Net.SendEntity(entities[i], _ip, _port)	
		Console.Print("Send Entity: " .. entities[i])
	end	
end
