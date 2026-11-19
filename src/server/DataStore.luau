-- DataStore saves each player's progress: cash, rebirths, slots and the
-- brainrots on their base. Every call is wrapped in pcall, so when Studio's
-- API access is off the game just plays without saving, never errors.

local DataStoreService = game:GetService("DataStoreService")
local GameState = require(script.Parent.GameState)
local BaseManager = require(script.Parent.BaseManager)

local DataStore = {}

local store = nil
local function getStore()
	if store then
		return store
	end
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore("BrainrotBay_v1")
	end)
	if ok then
		store = result
	end
	return store
end

local function keyFor(userId)
	return "player_" .. userId
end

-- Loads a save and rebuilds the player's base from it; returns true on success.
function DataStore.loadPlayer(player, state)
	local dataStore = getStore()
	if not dataStore then
		return false
	end
	local ok, saved = pcall(function()
		return dataStore:GetAsync(keyFor(player.UserId))
	end)
	if not ok or type(saved) ~= "table" then
		return false
	end
	state.cash = saved.cash or state.cash
	state.rebirths = saved.rebirths or 0
	state.multiplier = GameState.multiplierOf(state.rebirths)
	state.slotsOwned = saved.slotsOwned or state.slotsOwned
	if state.cashValue then
		state.cashValue.Value = state.cash
	end
	local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").BrainrotData)
	local BrainrotBuilder = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").BrainrotBuilder)
	for _, entry in ipairs(saved.owned or {}) do
		local character = BrainrotData.getCharacter(entry.characterId)
		if character then
			local mutation = BrainrotData.MUTATIONS[1]
			for _, candidate in ipairs(BrainrotData.MUTATIONS) do
				if candidate.name == entry.mutationName then
					mutation = candidate
				end
			end
			local uid = GameState.nextBrainrotUid()
			local income = GameState.incomeOf(state, character, mutation)
			local model = BrainrotBuilder.build(character, mutation, income, "")
			model.Parent = game:GetService("Workspace")
			local record = {
				uid = uid,
				character = character,
				mutation = mutation,
				income = income,
				cost = character.cost,
				model = model,
				location = "base",
				owner = player.UserId,
				slot = nil,
				baseIndex = nil,
			}
			GameState.brainrots[uid] = record
			BaseManager.placeOnBase(state, record)
			local label = record.model:FindFirstChild("Label", true)
			if label then
				local money = label:FindFirstChild("Money")
				if money then
					money.Text = "$" .. record.income .. "/s"
				end
			end
		end
	end
	return true
end

-- Writes the player's progress. Never errors: a failed save is just skipped.
function DataStore.savePlayer(player, state)
	local dataStore = getStore()
	if not dataStore then
		return false
	end
	local owned = {}
	for _, record in pairs(state.owned) do
		table.insert(owned, { characterId = record.character.id, mutationName = record.mutation.name })
	end
	local data = {
		cash = state.cash,
		rebirths = state.rebirths,
		slotsOwned = state.slotsOwned,
		owned = owned,
	}
	local ok = pcall(function()
		dataStore:SetAsync(keyFor(player.UserId), data)
	end)
	return ok
end

-- Saves every online player on a timer, so a crash loses at most a minute.
function DataStore.startAutosave()
	local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").GameConfig)
	task.spawn(function()
		while true do
			task.wait(GameConfig.AUTOSAVE_SECONDS)
			for _, state in pairs(GameState.players) do
				DataStore.savePlayer(state.player, state)
			end
		end
	end)
end

return DataStore
