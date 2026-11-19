-- BaseManager owns the eight bases ringing the plaza: who owns which one, which
-- slot each brainrot stands on, and moving a brainrot onto or off a base.

local GameState = require(script.Parent.GameState)
local WorldBuilder = require(script.Parent.WorldBuilder)

local BaseManager = {}

-- Hands the player the first free base and writes their name on its sign.
function BaseManager.claimBase(state)
	for index, base in ipairs(WorldBuilder.layout.bases) do
		if GameState.bases[index] == nil or GameState.bases[index].owner == nil then
			GameState.bases[index] = { owner = state.player.UserId, center = base.center, slots = {} }
			state.baseIndex = index
			base.sign.Text = state.player.DisplayName .. "'s Base"
			return index
		end
	end
	return nil
end

-- Moves a bought (or stolen, or granted) brainrot onto a free slot pad.
-- Returns the slot index, or nil when the base is full.
function BaseManager.placeOnBase(state, record)
	local slot = GameState.findFreeSlot(state)
	if not slot then
		return nil
	end
	local base = WorldBuilder.layout.bases[state.baseIndex]
	if not base then
		return nil
	end
	local padPosition = base.slots[slot]
	record.location = "base"
	record.owner = state.player.UserId
	record.slot = slot
	record.baseIndex = state.baseIndex
	record.model:PivotTo(CFrame.new(padPosition))
	state.owned[slot] = record
	GameState.bases[state.baseIndex].slots[slot] = record.uid
	state.purchaseLocks[record.uid] = os.time() + 30
	return slot
end

-- Lifts a brainrot off its base without destroying it (a steal hands it over).
function BaseManager.liftFromBase(record)
	local ownerState = GameState.getPlayer(record.owner)
	if ownerState and record.slot then
		ownerState.owned[record.slot] = nil
		ownerState.purchaseLocks[record.uid] = nil
	end
	if record.baseIndex and GameState.bases[record.baseIndex] then
		GameState.bases[record.baseIndex].slots[record.slot] = nil
	end
	record.slot = nil
	record.baseIndex = nil
end

-- Destroys a brainrot that leaves the game (sold by a rebirth, or its owner left).
function BaseManager.removeFromBase(uid)
	local record = GameState.brainrots[uid]
	if not record then
		return
	end
	BaseManager.liftFromBase(record)
	if record.model then
		record.model:Destroy()
	end
	GameState.brainrots[uid] = nil
end

-- Frees a base when its owner leaves: every brainrot on it is destroyed.
function BaseManager.releaseBase(state)
	if not state.baseIndex then
		return
	end
	local ownedUids = {}
	for _, record in pairs(state.owned) do
		table.insert(ownedUids, record.uid)
	end
	for _, uid in ipairs(ownedUids) do
		BaseManager.removeFromBase(uid)
	end
	local base = WorldBuilder.layout.bases[state.baseIndex]
	if base then
		base.sign.Text = "Base " .. state.baseIndex
	end
	GameState.bases[state.baseIndex] = nil
	state.baseIndex = nil
end

return BaseManager
