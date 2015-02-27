#include "Server.h"
#include "Logger/Managers/Logger.h"
#include <sstream>

Server::Server()
{
	Logger::GetInstance().AddGroup("Network");

	Network::NET_DEBUG = 1;
	m_server.SetServerPassword("DefaultMasterPassword");
	m_server.SetIncomingPort(5509);
	m_server.SetMaxTimeOutIntervall(60);
	m_server.SetMaxTimeOutCounter(2);

	Network::NetEvent  hook;
	hook = std::bind(&Server::OnConnectedToServer, this, std::placeholders::_1, std::placeholders::_2);
	m_server.SetOnPlayerConnected(hook);
	Network::DebugLog("Hooking network hook \"ON_CONNECTED_TO_SERVER\"", LogSeverity::Info);

	hook = std::bind(&Server::OnDisconnectedFromServer, this, std::placeholders::_1, std::placeholders::_2);
	m_server.SetOnPlayerDisconnected(hook);
	Network::DebugLog("Hooking network hook \"ON_DISCONNECTED_FROM_SERVER\"", LogSeverity::Info);

	hook = std::bind(&Server::OnTimedOutFromServer, this, std::placeholders::_1, std::placeholders::_2);
	m_server.SetOnPlayerTimedOut(hook);
	Network::DebugLog("Hooking network hook \"ON_TIMED_OUT_FROM_SERVER\"", LogSeverity::Info);

	Network::NetMessageHook customHook;

	customHook = std::bind(&Server::OnAddToDatabase, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("ADD_TO_DATABASE", customHook);
	Network::DebugLog("Hooking custom network hook \"ADD_TO_DATABASE\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnRemoveFromDatabase, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("REMOVE_FROM_DATABASE", customHook);
	Network::DebugLog("Hooking custom network hook \"REMOVE_FROM_DATABASE\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnPlayerCountIncreased, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("PLAYER_COUNT_INCREASED", customHook);
	Network::DebugLog("Hooking custom network hook \"PLAYER_COUNT_INCREASED\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnPlayerCountDecreased, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("PLAYER_COUNT_DECREASED", customHook);
	Network::DebugLog("Hooking custom network hook \"PLAYER_COUNT_DECREASED\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnSpectatorCountIncreased, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("SPECTATOR_COUNT_INCREASED", customHook);
	Network::DebugLog("Hooking custom network hook \"SPECTATOR_COUNT_INCREASED\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnSpectatorCountDecreased, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("SPECTATOR_COUNT_DECREASED", customHook);
	Network::DebugLog("Hooking custom network hook \"SPECTATOR_COUNT_DECREASED\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnMaxPlayerCountIncreased, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("MAX_PLAYER_COUNT_INCREASED", customHook);
	Network::DebugLog("Hooking custom network hook \"MAX_PLAYER_COUNT_INCREASED\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnMaxPlayerCountChanged, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("MAX_PLAYER_COUNT_CHANGED", customHook);
	Network::DebugLog("Hooking custom network hook \"MAX_PLAYER_COUNT_CHANGED\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnGameHasStarted, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("GAME_STARTED", customHook);
	Network::DebugLog("Hooking custom network hook \"GAME_STARTED\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnIsPasswordProtected, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("IS_PASSWORD_PROTECTED", customHook);
	Network::DebugLog("Hooking custom network hook \"IS_PASSWORD_PROTECTED\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnSetServerPort, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("SET_SERVER_PORT", customHook);
	Network::DebugLog("Hooking custom network hook \"SET_SERVER_PORT\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnGetServerInformation, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("GET_SERVER_LIST", customHook);
	Network::DebugLog("Hooking custom network hook \"GET_SERVER_LIST\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnPingServer, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("PING_SERVER", customHook);
	Network::DebugLog("Hooking custom network hook \"PING_SERVER\"", LogSeverity::Info);

	customHook = std::bind(&Server::OnRequestDisconnect, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
	m_server.AddNetworkHook("CLIENT_REQUEST_DISCONNECT", customHook);
	Network::DebugLog("Hooking custom network hook \"CLIENT_REQUEST_DISCONNECT\"", LogSeverity::Info);

	

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

	for (auto it = m_serverInfo.begin(); it != m_serverInfo.end();)
	{
		it->second.TimeOut += _dt;
		if (it->second.TimeOut > 20.f)
		{
			m_database.RemoveFromDatabase(m_serverInfo[it->second.IpAddress]);
			m_serverInfo.erase(it++);
		}
		else
			++it;
	}

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
	Network::DebugLog("%s:%i: CONNECTED_TO_SERVER\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());
	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].TimeOut = 0.f;
	}
}

void Server::OnDisconnectedFromServer(Network::NetConnection _nc, const char* _message)
{
	Network::DebugLog("%s:%i: DISCONNECTED_FROM_SERVER\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	//if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	//{
	//	m_database.RemoveFromDatabase(m_serverInfo[_nc.GetIpAddress()]);
	//	m_serverInfo.erase(_nc.GetIpAddress());
	//}
}

void Server::OnTimedOutFromServer(Network::NetConnection _nc, const char* _message)
{
	Network::DebugLog("%s:%i: TIMED_OUT_FROM_SERVER\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());
}

void Server::OnAddToDatabase(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: ADD_TO_DATABASE\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	int port = _ph->ReadInt(_id);
	bool pwProtected = _ph->ReadByte(_id);
	char* name = _ph->ReadString(_id);

	m_serverInfo[_nc.GetIpAddress()] = ServerInfo();
	m_serverInfo[_nc.GetIpAddress()].IpAddress = _nc.GetIpAddress();
	m_serverInfo[_nc.GetIpAddress()].Port = port;
	m_serverInfo[_nc.GetIpAddress()].PasswordProtected = pwProtected;
	m_serverInfo[_nc.GetIpAddress()].TimeOut = 0.f;

	if ( !name || std::strcmp(name, "DefaultName") == 0 || strlen(name) == 0)
	{

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
	}
	else
		m_serverInfo[_nc.GetIpAddress()].Name = name;

	m_database.AddToDatabase(m_serverInfo[_nc.GetIpAddress()]);
}

void Server::OnRemoveFromDatabase(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: REMOVE_FROM_DATABASE\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_database.RemoveFromDatabase(m_serverInfo[_nc.GetIpAddress()]);
		m_serverInfo.erase(_nc.GetIpAddress());
	}
}

void Server::OnPlayerCountIncreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: PLAYER_COUNT_INCREASED\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].NoUsers += 1;
		m_database.SetNoUsers(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnPlayerCountDecreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: PLAYER_COUNT_DECREASED\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].NoUsers -= 1;
		m_database.SetNoUsers(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnSpectatorCountIncreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: SPECTATOR_COUNT_INCREASED\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].NoSpectators += 1;
		m_database.SetNoSpectators(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnSpectatorCountDecreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: SPECTATOR_COUNT_DECREASED\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].NoSpectators -= 1;
		m_database.SetNoSpectators(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnMaxPlayerCountIncreased(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: MAX_PLAYER_COUNT_INCREASED\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	//int maxPlayers = _ph->ReadInt(_id);

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].MaxUsers += 1;
		m_database.SetMaxUsers(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnMaxPlayerCountChanged(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: MAX_PLAYER_COUNT_CHANGED\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	int maxPlayers = _ph->ReadInt(_id);

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		m_serverInfo[_nc.GetIpAddress()].MaxUsers = maxPlayers;
		m_database.SetMaxUsers(m_serverInfo[_nc.GetIpAddress()]);
	}
}


void Server::OnGameHasStarted(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: GAME_STARTED\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		bool started = (bool)_ph->ReadByte(_id);

		m_serverInfo[_nc.GetIpAddress()].GameStarted = started;
		m_database.SetGameStarted(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnIsPasswordProtected(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: IS_PASSWORD_PROTECTED\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		bool started = (bool)_ph->ReadByte(_id);

		m_serverInfo[_nc.GetIpAddress()].PasswordProtected = started;
		m_database.SetPasswordProtected(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnSetServerPort(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: SET_SERVER_PORT\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	if (m_serverInfo.find(_nc.GetIpAddress()) != m_serverInfo.end())
	{
		int port = _ph->ReadInt(_id);

		m_serverInfo[_nc.GetIpAddress()].Port = port;
		m_database.SetServerPort(m_serverInfo[_nc.GetIpAddress()]);
	}
}

void Server::OnGetServerInformation(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	
	Network::DebugLog("%s:%i: GET_SERVER_LIST\n", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

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

void Server::OnPingServer(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: PING_SERVER", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());
}

void Server::OnRequestDisconnect(Network::PacketHandler* _ph, uint64_t& _id, Network::NetConnection& _nc)
{
	Network::DebugLog("%s:%i: CLIENT_REQUEST_DISCONNECT", LogSeverity::Info, _nc.GetIpAddress(), _nc.GetPort());

	auto id = _ph->StartPack("SERVER_GRANT_DISCONNECT");
	auto packet = _ph->EndPack(id);
	m_server.Send(packet, _nc);
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