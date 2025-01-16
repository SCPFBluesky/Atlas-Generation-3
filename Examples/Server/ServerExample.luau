--!nocheck


local Atlas = require(game:FindService("ReplicatedStorage").AtlasV3); -- In order to use Atlas, we must first require it.

-- Example 1 : Creating a new instance with Atlas and custom propertieis
local New = Atlas:NewInstance("myNewPart!", "Part",  {Parent = workspace, Color = Color3.fromRGB(255, 0, 0), Material = Enum.Material.Neon});

-- End result of Example 1: A new bright neon part created and parented to workspace with the material of neon.

-- Example 2 : Requiring an Atlas module (In order to create modules with atlas, the module MUST have the Tag of "Atlas_Module")

local ExampleModule = Atlas:Import("TestModule"); -- WARINING: USING IMPORT WITHOUT A MODULE THAT HAS THE ATLAS_MODULE TAG CAN RESULT IN SERIOUS ISSUES!

-- End result of Example 2 : Returned and Succesfully required the "TestModule"

-- Example 3 : Requiring modules WITHOUT the Atlas_Module, we need to find a module named "Settings" in ReplicatedStorage but it doesn't have the Atlas_Module tag.

local SettingsMod = Atlas:RecursiveImport("Settings", game:FindService("ServerStorage"));

-- End result of Example 3 : Succesfully required the settings module.

-- Example 4 : Binding the Atlas remote event to a specific event

Atlas:BindToRemoteEvent("touchEvent", function()
	print("Player has touched the brick!")
end);

-- End result of Example 4:  When the "touchEvent" event is fired, it will print the message.

-- Example 5 : Binding the atlas remote function to a specific event

Atlas:BindToRemoteFunction("requestPlayerUserId", function(Player: (Player) )
	return Player.UserId;
end);

-- End result of Example 5: Client gets the player's user id
