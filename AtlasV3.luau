--[[
	Name: AtlasV3.luau
	Author(s): @WATDAHECKLOL32
	Date: 2025-01-16-25 4:05:43 AM
	RunTimeContext: Shared
	Information: a Framework designed for developers to make development easy. Provides a libairy of functions.
	
	Contributors(s): @WATDAHECKLOL32
	Copyright: (C) 2025 WATDAHECKLOL32 All rights reserved.
	Licence: MIT
	Version: 1.0.0
	
	Documentation: https://scpfbluesky.github.io/Atlas-API/
	Source: https://github.com/SCPFBluesky/Atlas_FrameworkV3
	Issues: https://github.com/SCPFBluesky/Atlas_FrameworkV3/issues
]]

--!nocheck
--!native
--!optimize 2

--[=[
	@class Atlas

	The Atlas Framework.
]=]
local Atlas = {};

local Players = game:FindService("Players");
local RunService = game:GetService("RunService");
local ColllectionService = game:GetService("CollectionService");

if game:GetService("RunService"):IsServer() and not game:FindService("ReplicatedStorage"):FindFirstChild("Atlas_Remote") then
	local newRemote = Instance.new("RemoteEvent");
	
	newRemote.Name = "Atlas_Remote"	
	newRemote.Parent = game:FindService("ReplicatedStorage")

	local newRemoteFunction = Instance.new("RemoteFunction");

	newRemoteFunction.Name = "Atlas_RemoteFunction"
	newRemoteFunction.Parent = game:FindService("ReplicatedStorage")	
end;


local AtlasRemoteEvent: (RemoteEvent) = game:FindService("ReplicatedStorage"):WaitForChild("Atlas_Remote"); 
local AtlasRemoteFunction: (RemoteFunction) = game:FindService("ReplicatedStorage"):WaitForChild("Atlas_RemoteFunction");

export type Modules =  {
	{ModuleScript?}
};

export type Objects = {
	{Instance?}
};

local Modules: (Modules) = {};
local Objects: (Objects) = {};

local MuteInstanceWarn: (boolean) = false;

local IsClient = RunService:IsClient();
local IsServer = RunService:IsServer();

local print = function(...)
	print("[ATLAS/OUTPUT]: ", ...);
end;

local warn = function(...)
	warn("[ATLAS/OUTPUT]: ", ...);
end;

do
	print("Loading Atlas, this may get laggy.")

	for _,Tagged: (any) in ColllectionService:GetTagged("Atlas_Module") do
		local ModuleName = tostring(Tagged)
		Modules[ModuleName] = Tagged
	end;

	for _,Tagged: (any) in ColllectionService:GetTagged("Atlas_Object") do
		local ModuleName =  tostring(Tagged)
		Objects[ModuleName] = Tagged
	end;

	print("Loading Complete!")
end;

--[=[
    @within Atlas
    @method Atlas:Import
	@param ModuleName String -- The module you wish to require.
	@return Module -- Returns the required module.

    A neater and slower verison of require, taking a string. And then looks up in the modules table, remember if you wish to require this way the target module must have the "Atlas_Module" Tag.
]=]
function Atlas:Import(ModuleName: (any?) )
	assert(ModuleName, "Attempt to call Atlas:Import, but no module was provided.")

	repeat task.wait() until Modules[ModuleName]
	local Succ, Error = pcall(function(...) 
		return require(Modules[ModuleName]);
	end)

	if not Succ then
		warn("Module experienced an error while importing: " ..Error);
	end;
end;

--[=[
    @within Atlas
    @method Atlas:RecursiveImport
	@param ModuleName String -- The module you wish to require.
	@param InstanceToSearch Instance -- The Instance that the target module is parented too.
	@return Module -- Returns the required module.

    Allows you to require modules parented to instances that do not have the Atlas_Module tag.
]=]
function Atlas:RecursiveImport(ModuleName: (string), InstanceToSearch: (Instance))
	assert(ModuleName, "Attempt to call Atlas:RecursiveImport, but no Module name was provided.");
	assert(InstanceToSearch, "Attempt to call Atlas:RecursiveImport, but no Instance was provided.");


	local Stuff = {}

	Stuff = InstanceToSearch:GetDescendants()
	
	print(Stuff)
	for _,Instances: (ModuleScript) in Stuff do
		if Instances:IsA("ModuleScript") and tostring(Instances) == ModuleName then
			return require(Instances);
		end;
	end;
end;

--[=[
    @within Atlas
    @method Atlas:GetObject
	@param ObjectName String -- The instance you wish to find.
	@return Instance -- Returns the target instance.

    Allows you to get any object that has the Atlas_Object tag.
]=]
function Atlas:GetObject(ObjectName: (any?) )
	assert(ObjectName, "Attempt to call Atlas:GetObject, but no ObjectName was provided.")
	repeat task.wait() until Objects[ObjectName]

	return Objects[ObjectName];
end;

--[=[
    @within Atlas
    @method Atlas:BindToRemoteEvent
	@param EventName String -- The name of the event you wish to bind the remote too.
	@param Callback  RBXScriptConnection -- The function that will be called for that specific event.

    Allows you to bind functions to the Atlas_RemoteEvent.
]=]
function Atlas:BindToRemoteEvent(EventName: (string), CallBack: (Instance) -> ()): RBXScriptConnection
	assert(EventName, "Attempt to call Atlas:BindToEvent but no eventname was provided.");
	assert(CallBack, "Attempt to call Atlas:BindToEvent but no function was provided.");

	if IsServer then
		AtlasRemoteEvent.OnServerEvent:Connect(function(Player: (Player), Event: (string), ...)
			if Event == EventName then
				CallBack(Player, ...)
			end;
		end);
	elseif IsClient then
		AtlasRemoteEvent.OnClientEvent:Connect(function(Event: (string), ...)
			if Event == EventName then
				CallBack(...)
			end;
		end);
	end;
end;

--[=[
    @within Atlas
    @method Atlas:BindToRemoteFunction
	@param EventName String -- The name of the event you wish to bind the remote function too.
	@param Callback  RBXScriptConnection -- The function that will be called for that specific event

    Allows you to bind functions to the Atlas_RemoteFunction.
]=]
function Atlas:BindToRemoteFunction(EventName: (string), CallBack: (Instance) -> ()): RBXScriptConnection
	assert(EventName, "Attempt to call BindToRemoteFunction but no EventName was provided");
	assert(CallBack, "Attempt to call BindToRemoteFunction but no function was provided.")
	if IsServer then
		AtlasRemoteFunction.OnServerInvoke = function(Player: (Player), Event: (string), ...)
			if Event == EventName then
				return CallBack(Player, ...)
			end;
		end;
	elseif IsClient then
		AtlasRemoteEvent.OnClientEvent = function(Event: (string), ...)
			return CallBack(...)
		end;
	end;
end;

do
--[=[
	@class link

	The Atlas Networking.
]=]
	local link = setmetatable({}, {__Index = Atlas});


--[=[
    @within link
    @method link:FireServer
	@param EventName String -- The event you wish to trigger.
	@return Event  RBXScriptConnection -- Returns.

    Allows you to FireServer the AtlasRemoteEvent.
]=]
function link:FireServer(EventName: (string), ...)
	if IsClient then
		return AtlasRemoteEvent:FireServer(EventName, ...);
	end;
end;

--[=[
    @within link
    @method link:FireAllClients
	@param EventName String -- The event you wish to trigger.
	@return Event  RBXScriptConnection -- Returns.

    Allows you too fire the remote to all clients.
]=]
function link:FireAllClients(EventName: (string), ...)
	if IsServer then
		return AtlasRemoteEvent:FireAllClients(EventName, ...);
	end;
end;

--[=[
    @within link
    @method link:FireAllClientsExpect
	@param EventName String -- The event you wish to trigger.
	@param Expect Player -- The expection (Remote will not be fired for this player.)
	@return Event  RBXScriptConnection -- Returns.

    Allows you too fire the remote to all clients expect for one specific client.
]=]
function link:FireAllClientsExpect(EventName: (string), Expect: (Player), ...)
		if IsServer then
		for _,Player: (Player) in Players:GetPlayers() do
			if Player ~= Expect then
				AtlasRemoteEvent:FireClient(Player, EventName, ...)
			end;
		end;
	end;
end;

--[=[
    @within link
    @method link:FireClient
	@param Player Player -- The client you wish to trigger the remote for.
	@param EventName String -- The event you wish to trigger.
	@return Event  RBXScriptConnection -- Returns.

    Allows you to fire the remote to one specific client.
]=]
function link:FireClient(Player: (Player), EventName: (string), ...)
	if IsServer then
		return AtlasRemoteEvent:FireClient(Player, EventName, ...);
	end;
end;

--[=[
	@within link
    @method link:InvokeServer
	@param EventName String -- The event you wish to trigger.
	@return Event  RBXScriptConnection -- Returns.

    Allows you to invoke the remote function on the server.
]=]
function link:InvokeServer(EventName: (string), ...)
	if IsClient then
		return AtlasRemoteFunction:InvokeServer(EventName, ...)
	end;
end;

--[=[
	@within link
    @method link:InvokeClient
	@param Player Player - The target player
	@param EventName String -- The event you wish to trigger.
	@return Event  RBXScriptConnection -- Returns.

    Allows you to invoke the remote function for one specific player.
]=]
function link:InvokeClient(Player: (Player), EventName: (string), ...)
		if IsServer then
			return AtlasRemoteFunction:InvokeClient(Player, EventName, ...);
		end;
	end;

	Atlas.network = link
end;


--[=[
	@within Atlas
    @method Atlas:NewInstance
	@param Name String - The name of the new instance
	@param Class String - The class the new instance will be
	@param ... Any - The properities of the new instance.
	@return New  Instance -- Returns the new instance.

    ALlows you to create any instance with any class.
]=]
function Atlas:NewInstance(Name: (string?), Class: (string), ...)
	assert(Class, "Attempt to call Atlas:NewInstance() but no Class was provided")

	if not Name and not MuteInstanceWarn then
		warn("No name was provided in Atlas:NewInstance, defaulting name to instance's class. Enable MuteInstanceWarn to silence.")
	end;

	local ObjectProperties = {...}

	local Instance = Instance.new(Class) 
	Instance.Name = Name or Class

	for key, value in ObjectProperties[1] or {} do
		Instance[key] = value
	end;

	local New = setmetatable({
		Instance = Instance, 
	}, { __index = Atlas });

	return New;
end;


return Atlas;
