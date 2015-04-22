//#include "stdafx.h"
#include "SQLConnection.h"

#include <sstream>
#include <iostream>



SQLConnection::SQLConnection()
	:m_connectionString(), m_serverIp("127.0.0.1"), m_serverPort(3306), m_database("stortspelservers"), m_userName("BTH"), m_password("STORTSPEL")
{
	otl_connect::otl_initialize();
}

SQLConnection::SQLConnection(const char* _serverIp, int _serverPort, char* _database, char* _username, char* _password)
	: m_connectionString(), m_serverIp(_serverIp), m_serverPort(_serverPort), m_database(_database), m_userName(_username), m_password(_password)
{
	otl_connect::otl_initialize();
}

SQLConnection::~SQLConnection()
{
}

void SQLConnection::OpenConnection()
{
	// If the conenction string is empty fill it with information
	if (m_connectionString.empty())
	{
		std::stringstream ss;
		ss << "DRIVER={MySQL ODBC 5.3 ANSI Driver};SERVER=" << m_serverIp << ";PORT=" << m_serverPort << ";DATABASE=" << m_database << ";USER=" << m_userName << ";PASSWORD=" << m_password << ";";
		m_connectionString = ss.str();
	}

	try
	{
		// Try to connect to the database
		m_connection.rlogon(m_connectionString.c_str());
	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}

}
void SQLConnection::CloseConnection()
{
	// Close the connection
	m_connection.logoff();
}

void SQLConnection::AddToDatabase(ServerInfo& _info)
{
	OpenConnection();

	try
	{
		// Delete all servers which are using the same IpAddress and Port as this one, but does not have the same timeId as this one
		otl_stream sqlDelete(
			10,
			"DELETE FROM currentlyonline WHERE TimeId<>:TimeId<int> AND IpAddress=:IpAddress<char[30]>",
			m_connection);

		sqlDelete << _info.TimeId << _info.IpAddress.c_str();


		// Insert the new server to the database
		otl_stream stream(
			10,
			"INSERT INTO currentlyonline values(:TimeId<int>, :Name<char[30]>, :IpAddress<char[30]>, :Port<int>, :NoUsers<int>, :MaxUsers<int>, :NoSpectators<int>, :GameStarted<char[3]>, :PasswordProtected<char[3]>)",
			m_connection);

		stream << (int)_info.TimeId << _info.Name.c_str() << _info.IpAddress.c_str() << (int)_info.Port << (int)_info.NoUsers << (int)_info.MaxUsers << (int)_info.NoSpectators << (char)_info.GameStarted << (char)_info.PasswordProtected;

	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}


	CloseConnection();
}
void SQLConnection::RemoveFromDatabase(ServerInfo& _info)
{
	OpenConnection();

	try
	{
		// Delete all servers which are using the same IpAddress and Port as this one
		otl_stream sqlDelete(
			10,
			"DELETE FROM currentlyonline WHERE TimeId=:TimeId<int>",
			m_connection);

		sqlDelete << _info.TimeId;

	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}

	CloseConnection();
}

void SQLConnection::ClearDatabase()
{
	OpenConnection();

	try
	{
		// Delete all servers which are using the same IpAddress and Port as this one
		otl_cursor::direct_exec(
			m_connection,
			"DELETE FROM currentlyonline",
			otl_exception::disabled);
	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}

	CloseConnection();
}

void SQLConnection::SetName(ServerInfo& _info)
{
	OpenConnection();

	try
	{
		// Updates the server's name of the with this Ip and Port
		otl_stream sqlDelete(
			10,
			"UPDATE currentlyonline SET Name=:Name<int> WHERE TimeId=:TimeId<int>",
			m_connection);

		sqlDelete << _info.Name.c_str() << _info.TimeId;

	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}

	CloseConnection();
}
void SQLConnection::SetNoUsers(ServerInfo& _info)
{
	OpenConnection();

	try
	{
		// Updates the number of users currently in the server
		otl_stream sqlDelete(
			10,
			"UPDATE currentlyonline SET NoUsers=:NoUsers<int> WHERE TimeId=:TimeId<int>",
			m_connection);

		sqlDelete << (int)_info.NoUsers << _info.TimeId;

	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}

	CloseConnection();
}
void SQLConnection::SetMaxUsers(ServerInfo& _info)
{
	OpenConnection();

	try
	{
		// Updates the number of max users allowed in the server
		otl_stream sqlDelete(
			10,
			"UPDATE currentlyonline SET MaxUsers=:MaxUsers<int> WHERE TimeId=:TimeId<int>",
			m_connection);

		sqlDelete << (int)_info.MaxUsers << _info.TimeId;

	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}

	CloseConnection();
}
void SQLConnection::SetNoSpectators(ServerInfo& _info)
{
	OpenConnection();

	try
	{
		// Updates the number of spectators currently in the game
		otl_stream sqlDelete(
			10,
			"UPDATE currentlyonline SET NoSpectators=:NoSpectators<int> WHERE TimeId=:TimeId<int>",
			m_connection);

		sqlDelete << (int)_info.NoSpectators << _info.TimeId;

	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}

	CloseConnection();
}
void SQLConnection::SetGameStarted(ServerInfo& _info)
{
	OpenConnection();

	try
	{
		// Updates the number of spectators currently in the game
		otl_stream sqlDelete(
			10,
			"UPDATE currentlyonline SET GameStarted=:GameStarted<int> WHERE TimeId=:TimeId<int>",
			m_connection);

		sqlDelete << (int)_info.GameStarted << _info.TimeId;

	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}

	CloseConnection();
}
void SQLConnection::SetPasswordProtected(ServerInfo& _info)
{
	OpenConnection();

	try
	{
		// Updates the number of spectators currently in the game
		otl_stream sqlDelete(
			10,

			"UPDATE currentlyonline SET PasswordProtected=:PasswordProtected<int> WHERE TimeId=:TimeId<int>",
			m_connection);
		sqlDelete << (int)_info.PasswordProtected << _info.TimeId;

	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}

	CloseConnection();
}
void SQLConnection::SetServerPort(ServerInfo& _info)
{
	OpenConnection();

	try
	{
		// Updates the number of spectators currently in the game
		otl_stream sqlDelete(
			10,

			"UPDATE currentlyonline SET Port=:Port<int> WHERE TimeId=:TimeId<int>",
			m_connection);
		sqlDelete << (int)_info.Port << _info.TimeId;

	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}

	CloseConnection();
}

int SQLConnection::Login()
{
	OpenConnection();
	int userId = -1;

	try
	{
		// Updates the number of spectators currently in the game
		otl_stream sqlLogin(
			200,

			"SELECT UserId FROM users WHERE Username=:Username<char[15]> AND Password=:Password<char[31]>",
			m_connection);

		std::string pw = "qwertyuiopasdfghjklzxcvbnmqwer";
		int size = pw.size();

		sqlLogin << "ThePettsoN";
		sqlLogin << "qwertyuiopasdfghjklzxcvbnmqwer";

		while (!sqlLogin.eof())
		{
			sqlLogin >> userId;
		}

	}
	catch (otl_exception& e)
	{
		std::cout << e.msg;
	}

	CloseConnection();
	
	return userId;
}