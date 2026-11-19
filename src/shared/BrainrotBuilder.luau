-- BrainrotBuilder turns a character table into a 3D model that walks the island:
-- a body, a head with eyes, one accessory, and a floating label that reads its
-- name, rarity and money-per-second. All parts are anchored; the server moves
-- the model with PivotTo, never with physics.

local BrainrotData = require(script.Parent.BrainrotData)

local BrainrotBuilder = {}

local function makePart(name, size, color, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Shape = shape or Enum.PartType.Block
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = true
	part.CanTouch = false
	return part
end

-- One small extra part that sells the character: crown, headphones, hat...
local function addAccessory(model, kind, size, trimColor)
	local head = model:FindFirstChild("Head")
	if not head then
		return
	end
	local s = size
	if kind == "crown" then
		local crown = makePart("Crown", Vector3.new(2.2 * s, 0.7 * s, 2.2 * s), Color3.fromRGB(255, 215, 0))
		crown.Position = head.Position + Vector3.new(0, 1.1 * s, 0)
		crown.Parent = model
	elseif kind == "headphones" then
		for _, side in ipairs({ -1, 1 }) do
			local ear = makePart("Ear", Vector3.new(0.5 * s, 1.2 * s, 1.2 * s), trimColor)
			ear.Position = head.Position + Vector3.new(side * 1.3 * s, 0, 0)
			ear.Parent = model
		end
	elseif kind == "hat" then
		local hat = makePart("Hat", Vector3.new(2.6 * s, 0.5 * s, 2.6 * s), trimColor)
		hat.Position = head.Position + Vector3.new(0, 1.2 * s, 0)
		hat.Parent = model
	elseif kind == "helmet" then
		local dome = makePart("Helmet", Vector3.new(2.4 * s, 1.6 * s, 2.4 * s), Color3.fromRGB(180, 220, 255), Enum.PartType.Ball)
		dome.Transparency = 0.4
		dome.Position = head.Position + Vector3.new(0, 0.3 * s, 0)
		dome.Parent = model
	elseif kind == "band" then
		local band = makePart("Band", Vector3.new(2.3 * s, 0.5 * s, 2.3 * s), trimColor)
		band.Position = head.Position + Vector3.new(0, 0.6 * s, 0)
		band.Parent = model
	elseif kind == "cup" then
		local cup = makePart("Cup", Vector3.new(0.9 * s, 1.2 * s, 0.9 * s), Color3.fromRGB(255, 255, 255))
		cup.Position = head.Position + Vector3.new(0, 1.4 * s, 0)
		cup.Parent = model
	elseif kind == "antenna" then
		local rod = makePart("Antenna", Vector3.new(0.3 * s, 1.6 * s, 0.3 * s), trimColor)
		rod.Position = head.Position + Vector3.new(0, 1.6 * s, 0)
		rod.Parent = model
		local tip = makePart("Tip", Vector3.new(0.7 * s, 0.7 * s, 0.7 * s), Color3.fromRGB(255, 220, 0), Enum.PartType.Ball)
		tip.Position = head.Position + Vector3.new(0, 2.5 * s, 0)
		tip.Parent = model
	elseif kind == "cone" then
		local cone = makePart("Cone", Vector3.new(1.2 * s, 1.8 * s, 1.2 * s), Color3.fromRGB(230, 180, 120))
		cone.Position = head.Position + Vector3.new(0, 1.6 * s, 0)
		cone.Parent = model
	elseif kind == "wings" then
		for _, side in ipairs({ -1, 1 }) do
			local wing = makePart("Wing", Vector3.new(0.3 * s, 1.6 * s, 2.4 * s), Color3.fromRGB(255, 255, 255))
			wing.Position = head.Position + Vector3.new(side * 1.5 * s, -0.4 * s, -0.6 * s)
			wing.Parent = model
		end
	elseif kind == "spoiler" then
		local spoiler = makePart("Spoiler", Vector3.new(2.4 * s, 0.3 * s, 1.0 * s), trimColor)
		spoiler.Position = head.Position + Vector3.new(0, 0.4 * s, -1.6 * s)
		spoiler.Parent = model
	elseif kind == "sword" then
		local blade = makePart("Sword", Vector3.new(0.4 * s, 3.0 * s, 0.4 * s), Color3.fromRGB(220, 220, 230))
		blade.Position = head.Position + Vector3.new(1.8 * s, 0.4 * s, 0.6 * s)
		blade.Parent = model
	end
end

-- The floating label above the character: name, rarity, $/s, and price on the conveyor.
local function addLabel(model, character, mutation, income, priceText)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(140, 64)
	gui.StudsOffset = Vector3.new(0, 4.2, 0)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.fromScale(1, 0.42)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = character.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Parent = gui

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "Rarity"
	rarityLabel.Position = UDim2.fromScale(0, 0.42)
	rarityLabel.Size = UDim2.fromScale(1, 0.28)
	rarityLabel.BackgroundTransparency = 1
	local rarity = BrainrotData.getRarity(character.rarity)
	rarityLabel.Text = mutation.name .. " " .. character.rarity
	rarityLabel.TextColor3 = rarity.color
	rarityLabel.TextScaled = true
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.TextStrokeTransparency = 0.4
	rarityLabel.Parent = gui

	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "Money"
	moneyLabel.Position = UDim2.fromScale(0, 0.7)
	moneyLabel.Size = UDim2.fromScale(1, 0.3)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = "$" .. income .. "/s" .. priceText
	moneyLabel.TextColor3 = Color3.fromRGB(140, 255, 140)
	moneyLabel.TextScaled = true
	moneyLabel.Font = Enum.Font.GothamBold
	moneyLabel.TextStrokeTransparency = 0.4
	moneyLabel.Parent = gui

	gui.Parent = model
end

-- Builds the model. priceText is "" on a base, "  •  $500" on the conveyor.
function BrainrotBuilder.build(character, mutation, income, priceText)
	local size = character.size
	local model = Instance.new("Model")
	model.Name = character.id

	local bodyColor = character.bodyColor
	if mutation.tint then
		bodyColor = mutation.tint
	end

	local body = makePart("Body", Vector3.new(2.4 * size, 2.4 * size, 2.0 * size), bodyColor)
	body.Position = Vector3.new(0, 1.2 * size, 0)
	body.Parent = model

	local head = makePart("Head", Vector3.new(2.0 * size, 1.8 * size, 1.8 * size), character.trimColor, Enum.PartType.Ball)
	head.Position = Vector3.new(0, 3.2 * size, 0)
	head.Parent = model

	for _, side in ipairs({ -1, 1 }) do
		local eye = makePart("Eye", Vector3.new(0.35 * size, 0.5 * size, 0.2 * size), Color3.fromRGB(20, 20, 20))
		eye.Position = head.Position + Vector3.new(side * 0.45 * size, 0.2 * size, 0.9 * size)
		eye.Parent = model
	end

	addAccessory(model, character.accessory, size, character.trimColor)

	local clicker = Instance.new("ClickDetector")
	clicker.Name = "Clicker"
	clicker.MaxActivationDistance = 32
	clicker.Parent = body

	model.PrimaryPart = body
	addLabel(model, character, mutation, income, priceText or "")
	return model
end

return BrainrotBuilder
