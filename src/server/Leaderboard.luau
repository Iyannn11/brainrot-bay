-- Leaderboard ranks every player by cash for the HUD's top five, and pushes
-- each player their own snapshot (cash, income, locks, wave timer) twice a
-- second, so the HUD is always the server's truth, never a client guess.

local GameState = require(script.Parent.GameState)
local Economy = require(script.Parent.Economy)
local Remotes = require(script.Parent.Remotes)

local Leaderboard = {}

-- Sorts every online player by cash and keeps the richest five.
function Leaderboard.refreshTop()
	local ranked = {}
	for _, state in pairs(GameState.players) do
		table.insert(ranked, { name = state.player.DisplayName, cash = state.cash })
	end
	table.sort(ranked, function(a, b)
		return a.cash > b.cash
	end)
	local top = {}
	for i = 1, math.min(5, #ranked) do
		top[i] = ranked[i]
	end
	GameState.topPlayers = top
end

-- Sends every player their snapshot, and the top five with it.
function Leaderboard.broadcastStates()
	Leaderboard.refreshTop()
	local event = Remotes.StateUpdate
	if not event then
		return
	end
	for _, state in pairs(GameState.players) do
		event:FireClient(state.player, Economy.buildSnapshot(state))
	end
end

function Leaderboard.startLoop()
	task.spawn(function()
		while true do
			task.wait(2)
			Leaderboard.broadcastStates()
		end
	end)
end

return Leaderboard
