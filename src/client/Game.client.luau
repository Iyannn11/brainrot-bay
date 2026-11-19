-- Brainrot Bay HUD: the player's cash, income, rebirths and the wave clock sit
-- top-right and top-center, clear of Roblox's own menu buttons top-left.
-- Buttons and the L / R / B keys ask the server; the server decides.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BrainrotBayRemotes")
local lockBaseEvent = remotes:WaitForChild("LockBase")
local rebirthEvent = remotes:WaitForChild("Rebirth")
local buySlotEvent = remotes:WaitForChild("BuySlot")
local stateEvent = remotes:WaitForChild("StateUpdate")
local notifyEvent = remotes:WaitForChild("Notify")

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBayGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- "$12500" reads better as "$12,500".
local function formatMoney(amount)
	local text = tostring(math.floor(amount))
	local result = ""
	while #text > 3 do
		result = "," .. string.sub(text, -3) .. result
		text = string.sub(text, 1, -4)
	end
	return "$" .. text .. result
end

local function makeLabel(parent, name, position, size, textSize)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = position
	label.Size = size
	label.BackgroundColor3 = Color3.fromRGB(20, 40, 70)
	label.BackgroundTransparency = 0.25
	label.BorderSizePixel = 0
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = textSize
	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 0.5
	label.Text = ""
	label.Parent = parent
	return label
end

-- Top-right: cash, income, collection, rebirths.
local statsPanel = Instance.new("Frame")
statsPanel.Name = "StatsPanel"
statsPanel.AnchorPoint = Vector2.new(1, 0)
statsPanel.Position = UDim2.new(1, -12, 0, 12)
statsPanel.Size = UDim2.fromOffset(250, 132)
statsPanel.BackgroundTransparency = 1
statsPanel.Parent = gui

local cashLabel = makeLabel(statsPanel, "Cash", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 36), 26)
local incomeLabel = makeLabel(statsPanel, "Income", UDim2.fromOffset(0, 40), UDim2.new(1, 0, 0, 26), 18)
local ownedLabel = makeLabel(statsPanel, "Owned", UDim2.fromOffset(0, 70), UDim2.new(1, 0, 0, 26), 18)
local rebirthLabel = makeLabel(statsPanel, "Rebirths", UDim2.fromOffset(0, 100), UDim2.new(1, 0, 0, 26), 18)

-- Top-center: the tide wave clock.
local waveLabel = makeLabel(gui, "WaveTimer", UDim2.new(0.5, -140, 0, 12), UDim2.fromOffset(280, 34), 20)
waveLabel.AnchorPoint = Vector2.new(0.5, 0)
waveLabel.Position = UDim2.new(0.5, 0, 0, 12)

-- Right side, under the stats: the five richest players.
local boardPanel = Instance.new("Frame")
boardPanel.Name = "TopPlayers"
boardPanel.AnchorPoint = Vector2.new(1, 0)
boardPanel.Position = UDim2.new(1, -12, 0, 156)
boardPanel.Size = UDim2.fromOffset(250, 150)
boardPanel.BackgroundTransparency = 1
boardPanel.Parent = gui
local boardTitle = makeLabel(boardPanel, "Title", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 26), 18)
boardTitle.Text = "RICHEST IN THE BAY"
boardTitle.BackgroundColor3 = Color3.fromRGB(90, 60, 10)
local boardLines = {}
for i = 1, 5 do
	boardLines[i] = makeLabel(boardPanel, "Rank" .. i, UDim2.fromOffset(0, 28 + (i - 1) * 24), UDim2.new(1, 0, 0, 22), 16)
end

-- Toasts drop in under the wave clock, one at a time.
local toastLabel = makeLabel(gui, "Toast", UDim2.new(0.5, -220, 0, 56), UDim2.fromOffset(440, 34), 18)
toastLabel.AnchorPoint = Vector2.new(0.5, 0)
toastLabel.Position = UDim2.new(0.5, 0, 0, 56)
toastLabel.BackgroundTransparency = 0.4
toastLabel.Visible = false

local function showToast(text)
	toastLabel.Text = text
	toastLabel.Visible = true
	task.delay(4, function()
		toastLabel.Visible = false
	end)
end

-- Bottom-right: the three actions. Text shows cost or cooldown live.
local function makeButton(name, position, text)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = UDim2.fromOffset(190, 44)
	button.BackgroundColor3 = Color3.fromRGB(30, 90, 160)
	button.BorderSizePixel = 0
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 17
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.Parent = gui
	return button
end

local lockButton = makeButton("LockBase", UDim2.new(1, -202, 1, -158), "Lock Base (L)")
local rebirthButton = makeButton("Rebirth", UDim2.new(1, -202, 1, -106), "Rebirth (R)")
local slotButton = makeButton("BuySlot", UDim2.new(1, -202, 1, -54), "Buy Slot (B)")

lockButton.MouseButton1Click:Connect(function()
	lockBaseEvent:FireServer()
end)
rebirthButton.MouseButton1Click:Connect(function()
	rebirthEvent:FireServer()
end)
slotButton.MouseButton1Click:Connect(function()
	buySlotEvent:FireServer()
end)

-- Keys do the same as the buttons. ContextActionService, not InputBegan:
-- the default camera owns the arrow keys, and this still sees L, R and B.
local function onLockAction(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		lockBaseEvent:FireServer()
	end
end
local function onRebirthAction(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		rebirthEvent:FireServer()
	end
end
local function onSlotAction(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		buySlotEvent:FireServer()
	end
end
ContextActionService:BindAction("BrainrotLock", onLockAction, false, Enum.KeyCode.L)
ContextActionService:BindAction("BrainrotRebirth", onRebirthAction, false, Enum.KeyCode.R)
ContextActionService:BindAction("BrainrotSlot", onSlotAction, false, Enum.KeyCode.B)

-- One snapshot from the server redraws the whole HUD.
local function updateHud(state)
	cashLabel.Text = formatMoney(state.cash)
	incomeLabel.Text = formatMoney(state.incomePerSecond) .. "/s income"
	ownedLabel.Text = "Brainrots: " .. state.brainrotsOwned .. " / " .. state.slotsOwned .. " slots"
	rebirthLabel.Text = "Rebirths: " .. state.rebirths .. "  (x" .. state.multiplier .. ")"
	if state.waveActive then
		waveLabel.Text = "TIDE WAVE! Get to your base!"
		waveLabel.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
	elseif state.waveSecondsLeft > 0 then
		waveLabel.Text = "Tide wave in " .. state.waveSecondsLeft .. "s"
		waveLabel.BackgroundColor3 = Color3.fromRGB(20, 40, 70)
	else
		waveLabel.Text = "The bay is calm..."
		waveLabel.BackgroundColor3 = Color3.fromRGB(20, 40, 70)
	end
	if state.lockRemaining > 0 then
		lockButton.Text = "Locked: " .. state.lockRemaining .. "s"
	elseif state.lockCooldownRemaining > 0 then
		lockButton.Text = "Lock ready in " .. state.lockCooldownRemaining .. "s"
	else
		lockButton.Text = "Lock Base (L)"
	end
	rebirthButton.Text = "Rebirth (R)  •  " .. formatMoney(state.rebirthCost)
	if state.nextSlotCost then
		slotButton.Text = "Buy Slot (B)  •  " .. formatMoney(state.nextSlotCost)
	else
		slotButton.Text = "Slots maxed out!"
	end
	for i = 1, 5 do
		local entry = state.topPlayers[i]
		if entry then
			boardLines[i].Text = i .. ". " .. entry.name .. "  " .. formatMoney(entry.cash)
		else
			boardLines[i].Text = i .. ". ---"
		end
	end
end

stateEvent.OnClientEvent:Connect(updateHud)
notifyEvent.OnClientEvent:Connect(showToast)
