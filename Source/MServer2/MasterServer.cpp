#include "Server.h"
#include "FrameCounter.h"
//#include "SQLConnection.h"


Server g_server;

BOOL WINAPI ConsoleHandlerRoutine(DWORD dvCtrolType)
{
	switch (dvCtrolType)
	{
	case CTRL_CLOSE_EVENT:
	case CTRL_BREAK_EVENT:
	case CTRL_C_EVENT:
	case CTRL_SHUTDOWN_EVENT:
		g_server.Stop();
		return 0;
	
	default:
		return 0;
	}
}

int main(int argc, char** argv)
{
	Network::NET_DEBUG = 1;
	SetConsoleCtrlHandler(ConsoleHandlerRoutine, TRUE);

	Utility::FrameCounter frameCounter;

	SDL_Log("Starting MasterServer");

	if (!g_server.Start())
		SDL_LogError(SDL_LOG_CATEGORY_SYSTEM, "Failed to start server. Exiting application");

	while (true)
	{
		float dt = frameCounter.GetDeltaTime();
		g_server.Update(dt);
		frameCounter.Tick();
	}

	SDL_Log("Stopping MasterServer");
	g_server.Stop();
	return 0;
}