-- RebirthSystem trades everything for power: pay the rebirth price, lose your
-- cash and every brainrot on your base, and gain a permanent +50% income
-- multiplier plus a Garuda Emas that only reborn players own.

local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").BrainrotData)
local BrainrotBuilder = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").BrainrotBuilder)

local GameState = require(script.Parent.GameState)
local BaseManager = require(script.Parent.BaseManager)
local Economy = require(script.Parent.Economy)

local RebirthSystem = {}

-- Rebirths the player: reset, multiply, and grant the exclusive Garuda Emas.
function RebirthSystem.tryRebirth(player)
	local state = GameState.getPlayer(player.UserId)
	if not state then
		return
	end
	local cost = BrainrotData.rebirthCost(state.rebirths)
	if state.cash < cost then
		Economy.notify(player, "Rebirth costs $" .. cost .. ". You have $" .. state.cash .. ".")
		return
	end
	local ownedUids = {}
	for _, record in pairs(state.owned) do
		table.insert(ownedUids, record.uid)
	end
	for _, uid in ipairs(ownedUids) do
		BaseManager.removeFromBase(uid)
	end
	state.cash = 0
	if state.cashValue then
		state.cashValue.Value = 0
	end
	state.rebirths += 1
	state.multiplier = GameState.multiplierOf(state.rebirths)
	local character = BrainrotData.REBIRTH_BRAINROT
	local mutation = BrainrotData.MUTATIONS[1]
	local uid = GameState.nextBrainrotUid()
	local income = character.income * state.rebirths
	local model = BrainrotBuilder.build(character, mutation, income, "")
	model.Parent = game:GetService("Workspace")
	local record = {
		uid = uid,
		character = character,
		mutation = mutation,
		income = income,
		cost = 0,
		model = model,
		location = "base",
		owner = player.UserId,
		slot = nil,
		baseIndex = nil,
	}
	GameState.brainrots[uid] = record
	local slot = BaseManager.placeOnBase(state, record)
	if slot then
		local label = record.model:FindFirstChild("Label", true)
		if label then
			local money = label:FindFirstChild("Money")
			if money then
				money.Text = "$" .. record.income .. "/s"
			end
		end
	end
	Economy.notify(player, "REBIRTH " .. state.rebirths .. "! Income x" .. state.multiplier .. " and a Garuda Emas is yours!")
end

return RebirthSystem
