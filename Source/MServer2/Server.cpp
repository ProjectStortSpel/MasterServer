#include "Server.h"
#include <sstream>

Server::Server()
{
	Network::NET_DEBUG = 1;
	m_server.SetServerPassword("DefaultMasterPassword");
	m_server.SetIncomingPort(5509);
	m_server.SetMaxTimeOutIntervall(60);
	m_server.SetMaxTimeOutCounter(2);

	Network::NetEvent  hook;
	hook = std::bind(&Server::OnConnectedToServer, this, std::placeholders::_1, std::placeholders::_2);
	m_server.SetOnPlayerConnected(hook);
	SDL_Log("%s \tHooking network hook \"ON_CONNECTED_TO_SERVER\"", GetLocalTime().c_str());

	hook = std::bind(&Server::OnDisconnectedFromServer, this, std::placeholders::_1, std::placeholders::_2);
	m_server.SetOnPlayerDisconnected(hook);
	SDL_Log("%s \tHooking network hook \"ON_DISCONNECTED_FROM_SERVER\"", GetLocalTime().c_str());

	hook = std::bind(&Server::OnTimedOutFromServer, this, std::placeholders::_1, std::placeholders::_2);
	m_server.SetOnPlayerTimedOut(hook);
	SDL_Log("%s \tHooking network hook \"ON_TIMED_OUT_FROM_SERVER\"", GetLocalTime().c_str());

	Network::NetMessageHook customHook;

	customHook = std::bind(&Server::OnAddToDatabase, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("ADD_TO_DATABASE", customHook);
	SDL_Log("%s \tHooking custom network hook \"ADD_TO_DATABASE\"", GetLocalTime().c_str());

	customHook = std::bind(&Server::OnRemoveFromDatabase, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("REMOVE_FROM_DATABASE", customHook);
	SDL_Log("%s \tHooking custom network hook \"REMOVE_FROM_DATABASE\"", GetLocalTime().c_str());

	customHook = std::bind(&Server::OnPlayerCountIncreased, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("PLAYER_COUNT_INCREASED", customHook);
	SDL_Log("%s \tHooking custom network hook \"PLAYER_COUNT_INCREASED\"", GetLocalTime().c_str());

	customHook = std::bind(&Server::OnPlayerCountDecreased, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("PLAYER_COUNT_DECREASED", customHook);
	SDL_Log("%s \tHooking custom network hook \"PLAYER_COUNT_DECREASED\"", GetLocalTime().c_str());

	customHook = std::bind(&Server::OnSpectatorCountIncreased, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("SPECTATOR_COUNT_INCREASED", customHook);
	SDL_Log("%s \tHooking custom network hook \"SPECTATOR_COUNT_INCREASED\"", GetLocalTime().c_str());

	customHook = std::bind(&Server::OnSpectatorCountDecreased, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("SPECTATOR_COUNT_DECREASED", customHook);
	SDL_Log("%s \tHooking custom network hook \"SPECTATOR_COUNT_DECREASED\"", GetLocalTime().c_str());

	customHook = std::bind(&Server::OnMaxPlayerCountIncreased, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("MAX_PLAYER_COUNT_INCREASED", customHook);
	SDL_Log("%s \tHooking custom network hook \"MAX_PLAYER_COUNT_INCREASED\"", GetLocalTime().c_str());

	customHook = std::bind(&Server::OnGameHasStarted, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("GAME_STARTED", customHook);
	SDL_Log("%s \tHooking custom network hook \"GAME_STARTED\"", GetLocalTime().c_str());

	customHook = std::bind(&Server::OnIsPasswordProtected, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("IS_PASSWORD_PROTECTED", customHook);
	SDL_Log("%s \tHooking custom network hook \"IS_PASSWORD_PROTECTED\"", GetLocalTime().c_str());

	customHook = std::bind(&Server::OnSetServerPort, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("SET_SERVER_PORT", customHook);
	SDL_Log("%s \tHooking custom network hook \"SET_SERVER_PORT\"", GetLocalTime().c_str());

	customHook = std::bind(&Server::OnGetServerInformation, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("GET_SERVER_LIST", customHook);
	SDL_Log("%s \tHooking custom network hook \"GET_SERVER_LIST\"", GetLocalTime().c_str());
}

Server::~Server()
{
}

bool Server::Start()
{
	m_database.ClearDatabase();
	bool result = m_server.Start();
	return result;
}

bool Server::Update(float _dt)
{
	m_server.Update(_dt);
	
	while (m_server.PopAndExecutePacket() > 0)	{}

	return true;
}

bool Server::Stop()
{
	bool result = m_server.Stop();
	m_database.ClearDatabase();
	return result;
}

void Server::OnConnectedToServer(Network::NetConnection _nc, const char* _message)
{
	SDL_Log("%s \t%s:%i: CONNECTED_TO_SERVER\n",GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());
}

void Server::OnDisconnectedFromServer(Network::NetConnection _nc, const char* _message)
{
	SDL_Log("%s \t%s:%i: DISCONNECTED_FROM_SERVER\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	//if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	//{
	//	m_database.RemoveFromDatabase(m_serverInfo[_nc.GetIpAddress()]);
	//	m_serverInfo.erase(_nc.GetIpAddress());
	//}
}

void Server::OnTimedOutFromServer(Network::NetConnection _nc, const char* _message)
{
	SDL_Log("%s \t%s:%i: TIMED_OUT_FROM_SERVER\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	m_database.RemoveFromDatabase(m_serverInfo[_nc.GetIpAddress()]);

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
		m_serverInfo.erase(_nc.GetIpAddress());
}

void Server::OnAddToDatabase(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	SDL_Log("%s \t%s:%i: ADD_TO_DATABASE\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	int port = _ph->ReadInt(_id);
	bool pwProtected = _ph->ReadByte(_id);

	m_serverInfo[_nc.GetIpAddress()] = ServerInfo();
	m_serverInfo[_nc.GetIpAddress()].IpAddress = _nc.GetIpAddress();
	m_serverInfo[_nc.GetIpAddress()].Port = port;
	m_serverInfo[_nc.GetIpAddress()].PasswordProtected = pwProtected;

	if (std::strcmp(_nc.GetIpAddress(), "127.0.0.1") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "LocalHost";
	else if (std::strcmp(_nc.GetIpAddress(), "194.47.150.44") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "Server";
	else if (std::strcmp(_nc.GetIpAddress(), "194.47.150.5") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "Erik";
	else if (std::strcmp(_nc.GetIpAddress(), "194.47.150.29") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "Niklas";
	else if (std::strcmp(_nc.GetIpAddress(), "194.47.150.48") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "Marcus";
	else if (std::strcmp(_nc.GetIpAddress(), "194.47.150.57") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "Christian";
	else if (std::strcmp(_nc.GetIpAddress(), "194.47.150.128") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "Pontus";
	else if (std::strcmp(_nc.GetIpAddress(), "194.47.150.100") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "Anders";
	else if (std::strcmp(_nc.GetIpAddress(), "193.11.186.9") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "Eriks Iphone 6";
	else if (std::strcmp(_nc.GetIpAddress(), "192.168.105.3") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "Eriks Iphone 4";
	else if (std::strcmp(_nc.GetIpAddress(), "193.11.185.227") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "Johannes";
	else if (std::strcmp(_nc.GetIpAddress(), "193.11.187.80") == 0)
		m_serverInfo[_nc.GetIpAddress()].Name = "Carl";

	m_database.AddToDatabase(m_serverInfo[_nc.GetIpAddress()]);
}

void Server::OnRemoveFromDatabase(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	SDL_Log("%s \t%s:%i: REMOVE_FROM_DATABASE\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_database.RemoveFromDatabase(m_serverInfo[_nc.GetIpAddress()]);
		m_serverInfo.erase(_nc.GetIpAddress());
	}
}

void Server::OnPlayerCountIncreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	SDL_Log("%s \t%s:%i: PLAYER_COUNT_INCREASED\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].NoUsers += 1;
		m_database.SetNoUsers(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnPlayerCountDecreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	SDL_Log("%s \t%s:%i: PLAYER_COUNT_DECREASED\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].NoUsers -= 1;
		m_database.SetNoUsers(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnSpectatorCountIncreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	SDL_Log("%s \t%s:%i: SPECTATOR_COUNT_INCREASED\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].NoSpectators += 1;
		m_database.SetNoSpectators(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnSpectatorCountDecreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	SDL_Log("%s \t%s:%i: SPECTATOR_COUNT_DECREASED\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].NoSpectators -= 1;
		m_database.SetNoSpectators(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnMaxPlayerCountIncreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	SDL_Log("%s \t%s:%i: MAX_PLAYER_COUNT_INCREASED\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].MaxUsers += 1;
		m_database.SetMaxUsers(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnGameHasStarted(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	SDL_Log("%s \t%s:%i: GAME_STARTED\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		bool started = (bool)_ph->ReadByte(_id);

		m_serverInfo[_nc.GetIpAddress()].GameStarted = started;
		m_database.SetGameStarted(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnIsPasswordProtected(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	SDL_Log("%s \t%s:%i: IS_PASSWORD_PROTECTED\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		bool started = (bool)_ph->ReadByte(_id);

		m_serverInfo[_nc.GetIpAddress()].PasswordProtected = started;
		m_database.SetPasswordProtected(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnSetServerPort(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	SDL_Log("%s \t%s:%i: SET_SERVER_PORT\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		int port = _ph->ReadInt(_id);

		m_serverInfo[_nc.GetIpAddress()].Port = port;
		m_database.SetServerPort(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnGetServerInformation(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	
	SDL_Log("%s \t%s:%i: GET_SERVER_LIST\n", GetLocalTime().c_str(), _nc.GetIpAddress(), _nc.GetPort());

	int noServers = m_serverInfo.size();

	auto id = _ph->StartPack("GET_SERVER_LIST");
	_ph->WriteInt(id, noServers); // Number of servers currently running
	
	for (auto it = m_serverInfo.begin(); it != m_serverInfo.end(); ++it)
	{
		_ph->WriteString(id,	it->second.Name.c_str());		// Name
		_ph->WriteString(id,	it->second.IpAddress.c_str());	// IpAddress
		_ph->WriteInt	(id,	it->second.Port);				// Port
		_ph->WriteShort	(id,	it->second.NoUsers);			// NoUsers
		_ph->WriteShort	(id,	it->second.MaxUsers);			// MaxUsers
		_ph->WriteShort	(id,	it->second.NoSpectators);		// NoSpectators
		_ph->WriteByte	(id,	it->second.GameStarted);		// GameStarted
		_ph->WriteByte	(id,	it->second.PasswordProtected);	// PasswordProtected
	}

	auto packetNoServers = _ph->EndPack(id);
	m_server.Send(packetNoServers, _nc);

}


std::string Server::GetLocalTime()
{
	time_t t = time(0);
	struct tm now;
	localtime_s(&now, &t);

	int hour = now.tm_hour;
	int min = now.tm_min;
	int sec = now.tm_sec;

	std::stringstream ss;
	ss << "[" << hour << ":" << min << ":" << sec << "]";

	return ss.str();

}