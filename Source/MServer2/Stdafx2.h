#ifndef STDAFX_H
#define STDAFX_H

#include <string>
#include <ctime>

struct ServerInfo
{
	int TimeId;
	std::string Name;
	std::string IpAddress;
	short Port;
	short NoUsers;
	short NoSpectators;
	short MaxUsers;
	bool GameStarted;
	bool PasswordProtected;
	float TimeOut;

	ServerInfo()
	{
		TimeId = (int)std::time(0);
		Name = "UntitledServer";
		IpAddress = "127.0.0.1";
		Port = 0;
		NoUsers = 0;
		NoSpectators = 0;
		MaxUsers = 0;
		GameStarted = false;
		PasswordProtected = false;
	}

};


#endif