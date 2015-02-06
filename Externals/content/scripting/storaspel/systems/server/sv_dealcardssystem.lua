DealCardsSystem = System()
DealCardsSystem.DealCard = false
DealCardsSystem.FirstDeal = true

DealCardsSystem.Initialize = function ( self )
	self:SetName("DealCardsSystem")
	self:AddComponentTypeToFilter("DealCards", FilterType.RequiresOneOf)
	self:AddComponentTypeToFilter("Player", FilterType.RequiresOneOf)
	self:AddComponentTypeToFilter("AI", FilterType.RequiresOneOf)
	--self:AddComponentTypeToFilter("Unit", FilterType.RequiresOneOf)
	self:AddComponentTypeToFilter("CardAction", FilterType.RequiresOneOf)
	self:AddComponentTypeToFilter("UsedCard", FilterType.Excluded)
	self:AddComponentTypeToFilter("CardStep", FilterType.Excluded)
	self:AddComponentTypeToFilter("DealtCard", FilterType.Excluded)
	self:AddComponentTypeToFilter("IsSpectator", FilterType.Excluded)
end

DealCardsSystem.OnEntityAdded = function(self, entityId)
		
	if world:EntityHasComponent( entityId, "DealCards") then
		local numCards = world:GetComponent( entityId, "DealCards", "NumCards"):GetInt()
		self:DealCards(numCards)

		world:KillEntity( entityId )

	end
	
end

DealCardsSystem.OnEntityRemoved = function(self, entityId)

end

DealCardsSystem.DealCards = function (self, numCards)

	local players = self:GetEntities("Player")
	--local players = self:GetEntities("Unit")
	local aiPlayers = self:GetEntities("AI")
	local cards = self:GetEntities("Card")
	local cardsLeft = #cards
	--print("DealCards")
	--print("Numplayer: " .. #players)
	--print("NumCards: " .. cardsLeft)
	--print("NumCardsToDeal: " .. numCards)
	
	print("")
	
	for i = 1, #players do
		
		if world:EntityHasComponent(players[i], "HasSelectedCards") then
			world:RemoveComponentFrom("HasSelectedCards", players[i])
		end
		
		local pickingStartedID = Net.StartPack("Client.RemotePickingStarted")
		Net.WriteInt(pickingStartedID, players[i])
		Net.Broadcast(pickingStartedID)
	
		local ip = world:GetComponent(players[i], "NetConnection", "IpAddress"):GetString()
		local port = world:GetComponent(players[i], "NetConnection", "Port"):GetInt()

		
		print("IP:   " .. ip)
		print("Port: " .. port)
		print("NumCards:" .. numCards)
		print("")
		for j = 1, numCards do

			local cardIndex = math.random(1, cardsLeft)
			local card = cards[cardIndex]
			
			world:CreateComponentAndAddTo("DealtCard", card)
			world:SetComponent(card, "DealtCard", "PlayerEntityId", players[i])
			
			Net.SendEntity(card, ip, port)	
			
			table.remove(cards, cardIndex)
			cardsLeft = cardsLeft - 1
		end
		
		--Net.Send(Net.StartPack("Client.SelectCards"), ip, port)
	end
	
	for i = 1, #aiPlayers do
		
		if world:EntityHasComponent(aiPlayers[i], "HasSelectedCards") then
			world:RemoveComponentFrom("HasSelectedCards", aiPlayers[i])
		end
		
		for j = 1, numCards do

			local cardIndex = math.random(1, cardsLeft)
			local card = cards[cardIndex]
			
			world:CreateComponentAndAddTo("DealtCard", card)
			if not world:EntityHasComponent(card, "AICard") then
				world:CreateComponentAndAddTo("AICard", card)
			end
			world:SetComponent(card, "DealtCard", "PlayerEntityId", aiPlayers[i])
			
			table.remove(cards, cardIndex)
			cardsLeft = cardsLeft - 1
		end
	end
		
	--	Notify players about timer
	local newId = world:CreateNewEntity();
	world:CreateComponentAndAddTo("OnPickingPhase", newId);
	
end

Net.Receive("Server.SelectCards", 
	function( id, ip, port )	

		print("Client selected cards:")
		print("")

		local selectedCards = { }
		local player
		for i = 1, 5 do

			local card = Net.ReadInt(id)
			if  world:EntityHasComponent(card, "DealtCard") then
			
				player = world:GetComponent(card, "DealtCard", "PlayerEntityId"):GetInt()
				local playerIp = world:GetComponent(player, "NetConnection", "IpAddress"):GetString()
				local playerPort = world:GetComponent(player, "NetConnection", "Port"):GetInt()

				
				if playerIp == ip and playerPort == port then
					
					table.insert(selectedCards, card)

				else
					--Net.Send(Net.StartPack("Client.SelectCards"), ip, port)
					return
				end

			else
				--Net.Send(Net.StartPack("Client.SelectCards"), ip, port)
				return
			end

		end	

		local unit = world:GetComponent(player, "UnitEntityId", "Id"):GetInt()

		local playerIp = world:GetComponent(player, "NetConnection", "IpAddress"):GetString()
		local playerPort = world:GetComponent(player, "NetConnection", "Port"):GetInt()
		
		world:CreateComponentAndAddTo("HasSelectedCards", player)
		
		for i = 1, 5 do
			local action = world:GetComponent(selectedCards[i], "CardAction", "Action"):GetString()
			local prio = world:GetComponent(selectedCards[i], "CardPrio", "Prio"):GetInt()
			print("Action: " .. action .. " - Prio: " .. prio)

			world:RemoveComponentFrom("DealtCard", selectedCards[i])
			world:CreateComponentAndAddTo("CardStep", selectedCards[i])
			world:SetComponent(selectedCards[i], "CardStep", "Step", i)
			world:SetComponent(selectedCards[i], "CardStep", "UnitEntityId", unit)



			Net.SendEntityKill(selectedCards[i], playerIp, playerPort)
			
		end
		local pickingDoneID = Net.StartPack("Client.RemotePickingDone")
		Net.WriteInt(pickingDoneID, player)
		Net.Broadcast(pickingDoneID)
		
		world:CreateComponentAndAddTo("UnitSelectedCards", unit)

		local id = world:CreateNewEntity()
		world:CreateComponentAndAddTo("NotifyStartNewRound", id)

	end
)