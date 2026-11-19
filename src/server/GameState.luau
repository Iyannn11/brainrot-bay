-- GameState keeps every number the game runs on in one place: each player's
-- cash, brainrots, slots, locks and cooldowns, the conveyor, the bases and the
-- wave. Server systems read and write it; nothing else holds game state.

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").GameConfig)
local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").BrainrotData)

local GameState = {}

-- [userId] -> player state
GameState.players = {}
-- [uid] -> every brainrot alive: { uid, character, mutation, income, cost, model,
--   location ("conveyor" | "base" | "wave"), owner (userId or nil), slot, baseIndex }
GameState.brainrots = {}
-- [uid] -> conveyor brainrot (same records as GameState.brainrots, for the cap)
GameState.conveyor = {}
-- [baseIndex] -> { owner (userId or nil), center (CFrame), slots = { [slot] = uid or nil } }
GameState.bases = {}
-- The tide wave: nextAt (os.time), active (bool), warned (bool).
GameState.wave = { nextAt = os.time() + GameConfig.WAVE_INTERVAL, active = false, warned = false }
-- Top players by cash, refreshed by the leaderboard: { { name, cash } }
GameState.topPlayers = {}
GameState.nextUid = 1

function GameState.nextBrainrotUid()
	local uid = GameState.nextUid
	GameState.nextUid += 1
	return uid
end

function GameState.multiplierOf(rebirths)
	return 1 + rebirths * GameConfig.REBIRTH_MULTIPLIER_STEP
end

function GameState.newPlayerState(player)
	return {
		player = player,
		cash = GameConfig.START_CASH,
		rebirths = 0,
		multiplier = 1,
		slotsOwned = GameConfig.START_SLOTS,
		-- [slotIndex] -> owned brainrot { uid, characterId, mutationName, income, model }
		owned = {},
		baseIndex = nil,
		lockUntil = 0,
		lockCooldownUntil = 0,
		stealCooldownUntil = 0,
		purchaseLocks = {}, -- [uid] -> os.time until which it cannot be stolen
	}
end

function GameState.getPlayer(userId)
	return GameState.players[userId]
end

function GameState.usedSlots(state)
	local count = 0
	for _ in pairs(state.owned) do
		count += 1
	end
	return count
end

function GameState.findFreeSlot(state)
	for slot = 1, state.slotsOwned do
		if state.owned[slot] == nil then
			return slot
		end
	end
	return nil
end

-- A brainrot's income at the player's current rebirth multiplier.
function GameState.incomeOf(state, character, mutation)
	return BrainrotData.incomeOf(character, mutation, state.multiplier)
end

function GameState.computeIncome(state)
	local total = 0
	for _, owned in pairs(state.owned) do
		total += owned.income
	end
	return total
end

function GameState.nextSlotCost(state)
	local index = state.slotsOwned - GameConfig.START_SLOTS + 1
	return GameConfig.SLOT_COSTS[index]
end

function GameState.isBaseLocked(state)
	return os.time() < state.lockUntil
end

function GameState.lockRemaining(state)
	return math.max(0, state.lockUntil - os.time())
end

function GameState.stealCooldownRemaining(state)
	return math.max(0, state.stealCooldownUntil - os.time())
end

function GameState.lockCooldownRemaining(state)
	return math.max(0, state.lockCooldownUntil - os.time())
end

return GameState
