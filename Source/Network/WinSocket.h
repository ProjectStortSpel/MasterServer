#ifdef WIN32

#ifndef WINSOCKET_H
#define WINSOCKET_H

#include <WinSock2.h>

#include "ISocket.h"

namespace Network
{

	class DECLSPEC WinSocket : public ISocket
	{
	public:

		WinSocket();
		WinSocket(SOCKET _socket);
		WinSocket(int _domain, int _type, int _protocol = 0);
		~WinSocket();

		bool Shutdown(void);
		bool Connect(const char* _ipAddres, const int _port);
		bool Bind(const int _port);
		bool Listen(int _backlog);
		bool CloseSocket(void);
		bool ShutdownSocket(int _how);
		ISocket* Accept(void);
		int Send(char* _buffer, int _length, int _flags = 0);
		int Receive(char* _buffer, int _length, int _flags = 0);

		bool SetNonBlocking(bool _value);
		bool SetNoDelay(bool _value);
		bool SetTimeoutDelay(int _value, bool _recv, bool _send);

	private:
		bool Initialize(void);

	private:
		SOCKET m_socket;

	};

}
#endif

#endif