-- BrainrotSpawner runs the conveyor: absurd characters stroll down the plaza
-- on their own, and a player who clicks one buys it if they can afford it and
-- have a free base slot. The same click on a base brainrot goes to stealing,
-- and on the wave's fish to claiming it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local BrainrotData = require(Shared.BrainrotData)
local BrainrotBuilder = require(Shared.BrainrotBuilder)

local GameState = require(script.Parent.GameState)
local WorldBuilder = require(script.Parent.WorldBuilder)
local Economy = require(script.Parent.Economy)
local StealSystem = require(script.Parent.StealSystem)
local WaveEvent = require(script.Parent.WaveEvent)

local BrainrotSpawner = {}

local function countConveyor()
	local count = 0
	for _ in pairs(GameState.conveyor) do
		count += 1
	end
	return count
end

-- One click on any brainrot in the world lands here, then fans out by where it is.
function BrainrotSpawner.onBrainrotClicked(player, uid)
	local record = GameState.brainrots[uid]
	if not record then
		return
	end
	if record.location == "conveyor" then
		Economy.buyBrainrot(player, uid)
	elseif record.location == "base" then
		StealSystem.trySteal(player, uid)
	elseif record.location == "wave" then
		WaveEvent.claimWaveBrainrot(player, uid)
	end
end

local function attachClick(model, uid)
	local detector = model:FindFirstChild("Clicker", true)
	if detector then
		detector.MouseClick:Connect(function(player)
			BrainrotSpawner.onBrainrotClicked(player, uid)
		end)
	end
end

function BrainrotSpawner.removeBrainrot(uid)
	local record = GameState.brainrots[uid]
	if record and record.model then
		record.model:Destroy()
	end
	GameState.brainrots[uid] = nil
	GameState.conveyor[uid] = nil
end

-- Walks the model down the waypoints, then despawns it at the gate.
local function walkBrainrot(record)
	task.spawn(function()
		local waypoints = WorldBuilder.layout.waypoints
		local index = 1
		while record.model.Parent ~= nil and record.location == "conveyor" do
			local target = waypoints[index]
			if not target then
				break
			end
			local position = record.model:GetPivot().Position
			local toTarget = target - position
			local distance = toTarget.Magnitude
			if distance < 0.5 then
				index += 1
				if index > #waypoints then
					break
				end
			else
				local direction = toTarget.Unit
				local step = math.min(distance, GameConfig.WALK_SPEED * 0.05)
				local newPosition = position + direction * step
				record.model:PivotTo(CFrame.lookAt(newPosition, newPosition + direction))
				task.wait(0.05)
			end
		end
		if record.location == "conveyor" then
			BrainrotSpawner.removeBrainrot(record.uid)
		end
	end)
end

function BrainrotSpawner.spawnBrainrot()
	if countConveyor() >= GameConfig.MAX_ON_CONVEYOR then
		return
	end
	local character = BrainrotData.rollCharacter()
	local mutation = BrainrotData.rollMutation()
	local uid = GameState.nextBrainrotUid()
	local model = BrainrotBuilder.build(character, mutation, character.income * mutation.multiplier, "  •  $" .. character.cost)
	local start = WorldBuilder.layout.waypoints[1]
	model:PivotTo(CFrame.new(start))
	model.Parent = Workspace
	local record = {
		uid = uid,
		character = character,
		mutation = mutation,
		income = character.income * mutation.multiplier,
		cost = character.cost,
		model = model,
		location = "conveyor",
		owner = nil,
		slot = nil,
		baseIndex = nil,
	}
	GameState.brainrots[uid] = record
	GameState.conveyor[uid] = record
	attachClick(model, uid)
	walkBrainrot(record)
end

-- The conveyor never stops: a fresh brainrot every few seconds.
function BrainrotSpawner.startLoop()
	task.spawn(function()
		while true do
			task.wait(GameConfig.SPAWN_INTERVAL)
			BrainrotSpawner.spawnBrainrot()
		end
	end)
end

return BrainrotSpawner
