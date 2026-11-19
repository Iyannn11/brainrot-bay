-- Economy is the money: the one-second income tick, buying brainrots off the
-- conveyor, buying more base slots, and the snapshot the client draws its HUD
-- from. The server is the only writer of cash; the client only asks.

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").GameConfig)
local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").BrainrotData)

local GameState = require(script.Parent.GameState)
local BaseManager = require(script.Parent.BaseManager)
local Remotes = require(script.Parent.Remotes)

local Economy = {}

function Economy.notify(player, message)
	local event = Remotes.Notify
	if event then
		event:FireClient(player, message)
	end
end

function Economy.setupLeaderstats(player, state)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = state.cash
	cash.Parent = stats
	state.cashValue = cash
end

-- Every second, each brainrot on a base pays its owner.
function Economy.startIncomeLoop()
	task.spawn(function()
		while true do
			task.wait(1)
			for _, state in pairs(GameState.players) do
				local income = GameState.computeIncome(state)
				if income > 0 then
					state.cash += income
					if state.cashValue then
						state.cashValue.Value = state.cash
					end
				end
			end
		end
	end)
end

-- Refreshes the floating label once a brainrot lands on a base.
local function refreshLabel(record)
	local label = record.model:FindFirstChild("Label", true)
	if not label then
		return
	end
	local money = label:FindFirstChild("Money")
	if money then
		money.Text = "$" .. record.income .. "/s"
	end
end

-- Clicks a brainrot on the conveyor: pay its price, walk it to a free slot.
function Economy.buyBrainrot(player, uid)
	local record = GameState.brainrots[uid]
	local state = GameState.getPlayer(player.UserId)
	if not record or record.location ~= "conveyor" or not state then
		return
	end
	if state.cash < record.cost then
		Economy.notify(player, "Not enough cash for " .. record.character.name .. " ($" .. record.cost .. ")")
		return
	end
	if GameState.findFreeSlot(state) == nil then
		Economy.notify(player, "Your base is full! Buy another slot first.")
		return
	end
	state.cash -= record.cost
	if state.cashValue then
		state.cashValue.Value = state.cash
	end
	GameState.conveyor[uid] = nil
	record.income = GameState.incomeOf(state, record.character, record.mutation)
	local slot = BaseManager.placeOnBase(state, record)
	if not slot then
		state.cash += record.cost
		return
	end
	refreshLabel(record)
	Economy.notify(player, "Bought " .. record.character.name .. " for $" .. record.cost .. "!")
end

-- Buys one more base slot, up to the cap, at the escalating price.
function Economy.buySlot(player)
	local state = GameState.getPlayer(player.UserId)
	if not state then
		return
	end
	if state.slotsOwned >= GameConfig.MAX_SLOTS then
		Economy.notify(player, "Your base already has the maximum slots.")
		return
	end
	local cost = GameState.nextSlotCost(state)
	if not cost then
		return
	end
	if state.cash < cost then
		Economy.notify(player, "A new slot costs $" .. cost .. ".")
		return
	end
	state.cash -= cost
	if state.cashValue then
		state.cashValue.Value = state.cash
	end
	state.slotsOwned += 1
	Economy.notify(player, "Base slot bought! You now have " .. state.slotsOwned .. " slots.")
end

-- Everything the HUD needs, in one table, once per broadcast.
function Economy.buildSnapshot(state)
	local waveSeconds = 0
	if GameState.wave.active then
		waveSeconds = -1
	elseif GameState.wave.nextAt then
		waveSeconds = math.max(0, GameState.wave.nextAt - os.time())
	end
	return {
		cash = state.cash,
		incomePerSecond = GameState.computeIncome(state),
		brainrotsOwned = GameState.usedSlots(state),
		rebirths = state.rebirths,
		multiplier = state.multiplier,
		slotsOwned = state.slotsOwned,
		slotsUsed = GameState.usedSlots(state),
		lockRemaining = GameState.lockRemaining(state),
		lockCooldownRemaining = GameState.lockCooldownRemaining(state),
		stealCooldownRemaining = GameState.stealCooldownRemaining(state),
		rebirthCost = BrainrotData.rebirthCost(state.rebirths),
		nextSlotCost = GameState.nextSlotCost(state),
		waveSecondsLeft = waveSeconds,
		waveActive = GameState.wave.active,
		topPlayers = GameState.topPlayers,
	}
end

return Economy
