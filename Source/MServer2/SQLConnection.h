#ifndef SQLCONNECTION_H
#define SQLCONNECTION_H

#include "Stdafx2.h"
#include "../Network/Packet.h"

#define OTL_ODBC
#include <otlv4.h>


class SQLConnection
{
public:
	SQLConnection();
	SQLConnection(const char* _serverIp, int _serverPort, char* _database, char* _username, char* _password);
	~SQLConnection();

	void AddToDatabase(ServerInfo& _info);
	void RemoveFromDatabase(ServerInfo& _info);
	void ClearDatabase();

	void SetName(ServerInfo& _info);
	void SetNoUsers(ServerInfo& _info);
	void SetMaxUsers(ServerInfo& _info);
	void SetNoSpectators(ServerInfo& _info);
	void SetGameStarted(ServerInfo& _info);
	void SetPasswordProtected(ServerInfo& _info);
	void SetServerPort(ServerInfo& _info);
	int Login();

private:

	void OpenConnection();
	void CloseConnection();

	otl_connect m_connection;

	std::string m_connectionString;
	std::string m_serverIp;
	std::string m_database;
	std::string m_userName;
	std::string m_password;
	int m_serverPort;
};

#endif