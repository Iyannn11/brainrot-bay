-- Brainrot Bay bootstrap: builds the island, wires the systems, and greets
-- every player with a base, a save and a running economy. Nothing here runs
-- before the world exists: the layout is built first, then the loops start.

local Players = game:GetService("Players")

local GameState = require(script.GameState)
local WorldBuilder = require(script.WorldBuilder)
local BaseManager = require(script.BaseManager)
local Economy = require(script.Economy)
local StealSystem = require(script.StealSystem)
local RebirthSystem = require(script.RebirthSystem)
local BrainrotSpawner = require(script.BrainrotSpawner)
local WaveEvent = require(script.WaveEvent)
local DataStore = require(script.DataStore)
local Leaderboard = require(script.Leaderboard)
local Remotes = require(script.Remotes)

-- The island first: every system below reads WorldBuilder.layout.
WorldBuilder.build()
print("[Brainrot Bay] Island built: 8 bases, conveyor, pier and palms ready.")

-- Player joins: fresh state, a base, leaderstats, then their save if one exists.
local function onPlayerAdded(player)
	local state = GameState.newPlayerState(player)
	GameState.players[player.UserId] = state
	Economy.setupLeaderstats(player, state)
	BaseManager.claimBase(state)
	DataStore.loadPlayer(player, state)
	Economy.notify(player, "Welcome to Brainrot Bay! Click a brainrot on the conveyor to buy it.")
	print("[Brainrot Bay] " .. player.Name .. " joined on base " .. tostring(state.baseIndex))
end

-- Player leaves: save, then free the base and clear its brainrots.
local function onPlayerRemoving(player)
	local state = GameState.getPlayer(player.UserId)
	if state then
		DataStore.savePlayer(player, state)
		BaseManager.releaseBase(state)
		GameState.players[player.UserId] = nil
	end
	print("[Brainrot Bay] " .. player.Name .. " left.")
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

-- Client buttons talk back through these three remotes; the server validates all.
Remotes.LockBase.OnServerEvent:Connect(function(player)
	StealSystem.lockBase(player)
end)
Remotes.Rebirth.OnServerEvent:Connect(function(player)
	RebirthSystem.tryRebirth(player)
end)
Remotes.BuySlot.OnServerEvent:Connect(function(player)
	Economy.buySlot(player)
end)

-- The game's heartbeat: income, conveyor, waves, saves and the HUD feed.
Economy.startIncomeLoop()
BrainrotSpawner.startLoop()
WaveEvent.startLoop()
DataStore.startAutosave()
Leaderboard.startLoop()
print("[Brainrot Bay] All systems running. Good luck out there!")
