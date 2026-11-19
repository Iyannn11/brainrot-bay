-- Remotes creates the RemoteEvents the client and server talk through, once,
-- under ReplicatedStorage. Server modules require this file; the client waits
-- for the folder and then for each event by name.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = ReplicatedStorage:FindFirstChild("BrainrotBayRemotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "BrainrotBayRemotes"
	folder.Parent = ReplicatedStorage
	for _, name in ipairs({ "LockBase", "Rebirth", "BuySlot", "StateUpdate", "Notify" }) do
		local event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = folder
	end
end

local Remotes = {}
for _, event in ipairs(folder:GetChildren()) do
	if event:IsA("RemoteEvent") then
		Remotes[event.Name] = event
	end
end

return Remotes
