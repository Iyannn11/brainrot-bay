-- StealSystem is the threat that keeps bases honest: click a brainrot on
-- someone else's base to take it, unless their base is locked, the brainrot
-- was only just bought, you are on cooldown, or your own base is full.
-- A base lock buys twenty seconds of peace, then a long cooldown.

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").GameConfig)

local GameState = require(script.Parent.GameState)
local BaseManager = require(script.Parent.BaseManager)
local Economy = require(script.Parent.Economy)

local StealSystem = {}

-- Steals a brainrot off another player's base and walks it onto the thief's.
function StealSystem.trySteal(player, uid)
	local record = GameState.brainrots[uid]
	local thief = GameState.getPlayer(player.UserId)
	if not record or record.location ~= "base" or not thief then
		return
	end
	if record.owner == player.UserId then
		Economy.notify(player, "That brainrot is already yours.")
		return
	end
	local victim = GameState.getPlayer(record.owner)
	if not victim then
		return
	end
	if GameState.isBaseLocked(victim) then
		Economy.notify(player, victim.player.DisplayName .. "'s base is locked!")
		return
	end
	local lockedUntil = victim.purchaseLocks[uid] or 0
	if os.time() < lockedUntil then
		Economy.notify(player, "That brainrot was just bought - it cannot be stolen yet.")
		return
	end
	if GameState.stealCooldownRemaining(thief) > 0 then
		Economy.notify(player, "Steal is on cooldown for " .. GameState.stealCooldownRemaining(thief) .. "s.")
		return
	end
	if GameState.findFreeSlot(thief) == nil then
		Economy.notify(player, "Your base is full! Buy another slot first.")
		return
	end
	BaseManager.liftFromBase(record)
	record.income = GameState.incomeOf(thief, record.character, record.mutation)
	local slot = BaseManager.placeOnBase(thief, record)
	if not slot then
		return
	end
	thief.stealCooldownUntil = os.time() + GameConfig.STEAL_COOLDOWN_SECONDS
	Economy.notify(player, "You stole " .. record.character.name .. " from " .. victim.player.DisplayName .. "!")
	Economy.notify(victim.player, player.DisplayName .. " stole your " .. record.character.name .. "!")
end

-- Locks your own base against every steal for a short while.
function StealSystem.lockBase(player)
	local state = GameState.getPlayer(player.UserId)
	if not state then
		return
	end
	if GameState.isBaseLocked(state) then
		Economy.notify(player, "Your base is already locked.")
		return
	end
	if GameState.lockCooldownRemaining(state) > 0 then
		Economy.notify(player, "Base lock is on cooldown for " .. GameState.lockCooldownRemaining(state) .. "s.")
		return
	end
	state.lockUntil = os.time() + GameConfig.LOCK_DURATION_SECONDS
	state.lockCooldownUntil = os.time() + GameConfig.LOCK_DURATION_SECONDS + GameConfig.LOCK_COOLDOWN_SECONDS
	Economy.notify(player, "Base locked for " .. GameConfig.LOCK_DURATION_SECONDS .. " seconds!")
end

return StealSystem
