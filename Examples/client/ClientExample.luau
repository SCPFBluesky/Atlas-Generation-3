--!nocheck

task.wait(1);

local Atlas = require(game:FindService("ReplicatedStorage").AtlasV3);
local Network = Atlas.network;

local Players = game:FindService("Players");

local brick = workspace.Baseplate;

-- Client Example 1: Firing a remote event to the server when a player touches a brick

brick.Touched:Connect(function(otherPart: (BasePart) )
	local Plr = Players:GetPlayerFromCharacter(otherPart.Parent);
	
	if Plr and Plr.Character then
		Network:FireServer("touchEvent");
	end;
end);

-- End result of Example 2: Remote fires when the playert touches the brick

-- Client example 2: Invoking the server to request the player's UserID

local a = Network:InvokeServer("requestPlayerUserId");
print(a)

-- End result of Client Example 2: The server returns the player's UserID
