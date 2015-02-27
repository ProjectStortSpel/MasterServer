#ifndef SERVER_H
#define SERVER_H

#include "Network/Network.h"
#undef main

#include "SQLConnection.h"

class Server
{



public:
	Server();
	~Server();

	bool Start();
	bool Stop();
	bool Update(float _dt);

private:
	void OnConnectedToServer(Network::NetConnection _nc, const char* _message);
	void OnDisconnectedFromServer(Network::NetConnection _nc, const char* _message);
	void OnTimedOutFromServer(Network::NetConnection _nc, const char* _message);

	void OnAddToDatabase(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);
	void OnRemoveFromDatabase(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);

	void OnPlayerCountIncreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);
	void OnPlayerCountDecreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);
	
	void OnSpectatorCountIncreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);
	void OnSpectatorCountDecreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);

	void OnMaxPlayerCountIncreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);
	void OnMaxPlayerCountDecreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);
	void OnMaxPlayerCountChanged(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);

	void OnIsPasswordProtected(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);
	void OnGameHasStarted(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);
	void OnSetServerPort(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);

	void OnGetServerInformation(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);

	void OnPingServer(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);

	void OnRequestDisconnect(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc);

	std::string GetLocalTime();

private:

	SQLConnection	m_database;
	Network::ServerNetwork m_server;
	std::map<std::string, ServerInfo> m_serverInfo;
};

#endif