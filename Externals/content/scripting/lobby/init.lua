GameRunning = false;


-- Components
package.path = package.path .. ";../../../Externals/content/scripting/lobby/components/?.lua"
require "components"
require "buttoncomponents"
require "menucomponents"
require "servercomponents"

package.path = package.path .. ";../../../Externals/content/scripting/shared/components/?.lua"
require "interfacecomponents"
require "textrendercomponents"
require "lightcomponents"
require "cameracomponents"
require "components"

-- Systems
package.path = package.path .. ";../../../Externals/content/scripting/lobby/systems/?.lua"
require "systems"


--if Server then
	require "serverlobbysystem"
	require "serverconnectsystem"
--end

--if Client then
	require "clientlobbysystem"
	require "clientconnectsystem"
--end
package.path = package.path .. ";../../../Externals/content/scripting/lobby/systems/interfacesystems/?.lua"
require "gameinterfacesystem"
require "gamemenusystem"
require "optionmenusystem"
require "connectmenusystem"
require "hostmenusystem"

package.path = package.path .. ";../../../Externals/content/scripting/shared/systems/?.lua"
require "pickboxsystem"
require "hoversizesystem"
require "addtexttotexturesystem"
require "parentsystem"

-- Templates
package.path = package.path .. ";../../../Externals/content/scripting/lobby/templates/?.lua"
require "templates"

worldCreator:AddSystemGroup()
worldCreator:AddSystemToCurrentGroup(StartUpSystem)

worldCreator:AddSystemToCurrentGroup(ParentSystem)
worldCreator:AddSystemToCurrentGroup(PickBoxSystem)
worldCreator:AddSystemToCurrentGroup(HoverSizeSystem)
worldCreator:AddSystemToCurrentGroup(AddTextToTextureSystem)

--if Server then
	worldCreator:AddSystemToCurrentGroup(ServerLobbySystem)
	worldCreator:AddSystemToCurrentGroup(ServerConnectSystem)
--end

--if Client then
	worldCreator:AddSystemToCurrentGroup(ClientLobbySystem)
	worldCreator:AddSystemToCurrentGroup(ClientConnectSystem)
--end

worldCreator:AddSystemToCurrentGroup(GameInterfaceSystem)
worldCreator:AddSystemToCurrentGroup(GameMenuSystem)
worldCreator:AddSystemToCurrentGroup(OptionMenuSystem)
worldCreator:AddSystemToCurrentGroup(ConnectMenuSystem)
worldCreator:AddSystemToCurrentGroup(HostMenuSystem)