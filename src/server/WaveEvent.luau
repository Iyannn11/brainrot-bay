-- WaveEvent is the hazard that sweeps the island: every couple of minutes the
-- tide rolls in from the north sea, knocks players back toward their bases,
-- and washes a rare Ikan Ombak onto the beach for whoever clicks it first.

local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").GameConfig)
local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").BrainrotData)
local BrainrotBuilder = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").BrainrotBuilder)

local GameState = require(script.Parent.GameState)
local BaseManager = require(script.Parent.BaseManager)
local Economy = require(script.Parent.Economy)

local WaveEvent = {}

local waveWall = nil
local waveFishUid = nil

-- A player who clicks the washed-up fish claims it, free, if they have a slot.
function WaveEvent.claimWaveBrainrot(player, uid)
	if uid ~= waveFishUid then
		return
	end
	local record = GameState.brainrots[uid]
	local state = GameState.getPlayer(player.UserId)
	if not record or record.location ~= "wave" or not state then
		return
	end
	if GameState.findFreeSlot(state) == nil then
		Economy.notify(player, "Your base is full! Buy another slot first.")
		return
	end
	GameState.brainrots[uid] = record
	waveFishUid = nil
	record.income = GameState.incomeOf(state, record.character, record.mutation)
	local slot = BaseManager.placeOnBase(state, record)
	if not slot then
		return
	end
	Economy.notify(player, "You caught the Ikan Ombak from the wave!")
end

local function spawnWaveFish()
	local character = BrainrotData.WAVE_BRAINROT
	local mutation = BrainrotData.MUTATIONS[1]
	local uid = GameState.nextBrainrotUid()
	local model = BrainrotBuilder.build(character, mutation, character.income, "  •  FREE")
	model:PivotTo(CFrame.new(0, 1.4, 60))
	model.Parent = game:GetService("Workspace")
	local record = {
		uid = uid,
		character = character,
		mutation = mutation,
		income = character.income,
		cost = 0,
		model = model,
		location = "wave",
		owner = nil,
		slot = nil,
		baseIndex = nil,
	}
	GameState.brainrots[uid] = record
	waveFishUid = uid
	local detector = model:FindFirstChild("Clicker", true)
	if detector then
		detector.MouseClick:Connect(function(player)
			WaveEvent.claimWaveBrainrot(player, uid)
		end)
	end
	task.delay(45, function()
		if waveFishUid == uid and GameState.brainrots[uid] and GameState.brainrots[uid].location == "wave" then
			GameState.brainrots[uid].model:Destroy()
			GameState.brainrots[uid] = nil
			waveFishUid = nil
		end
	end)
end

-- Shoves every player near the wall back toward the south, once per pass.
local function knockPlayersBack(wallZ)
	for _, state in pairs(GameState.players) do
		local character = state.player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				local position = root.Position
				if math.abs(position.Z - wallZ) < 8 and math.abs(position.X) < 90 then
					root.AssemblyLinearVelocity = Vector3.new(0, 25, 55)
				end
			end
		end
	end
end

local function runWave()
	GameState.wave.active = true
	for _, state in pairs(GameState.players) do
		Economy.notify(state.player, "THE TIDE WAVE IS COMING! Dash back to your base!")
	end
	waveWall = Instance.new("Part")
	waveWall.Name = "TideWave"
	waveWall.Size = Vector3.new(220, 14, 4)
	waveWall.Color = Color3.fromRGB(40, 140, 220)
	waveWall.Material = Enum.Material.Water
	waveWall.Transparency = 0.3
	waveWall.Anchored = true
	waveWall.CanCollide = false
	waveWall.CanQuery = false
	waveWall.Position = Vector3.new(0, 7, -110)
	waveWall.Parent = game:GetService("Workspace")
	spawnWaveFish()
	local z = -110
	while z < 115 do
		z += GameConfig.WAVE_SPEED * 0.1
		waveWall.Position = Vector3.new(0, 7, z)
		knockPlayersBack(z)
		task.wait(0.1)
	end
	waveWall:Destroy()
	waveWall = nil
	GameState.wave.active = false
	GameState.wave.warned = false
	GameState.wave.nextAt = os.time() + GameConfig.WAVE_INTERVAL
end

-- The wave clock: warn ten seconds out, then roll the tide across the island.
function WaveEvent.startLoop()
	task.spawn(function()
		while true do
			task.wait(1)
			local now = os.time()
			if not GameState.wave.active and not GameState.wave.warned
				and GameState.wave.nextAt - now <= GameConfig.WAVE_WARNING_SECONDS then
				GameState.wave.warned = true
				for _, state in pairs(GameState.players) do
					Economy.notify(state.player, "A tide wave is coming in 10 seconds!")
				end
			end
			if not GameState.wave.active and GameState.wave.nextAt <= now then
				runWave()
			end
		end
	end)
end

return WaveEvent
