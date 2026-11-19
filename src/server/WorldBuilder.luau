-- WorldBuilder raises the whole island at server start, from data alone: sand,
-- sea, plaza, the conveyor the brainrots walk, eight player bases, palm trees,
-- the pier and the spawn. Nothing here is hand-placed in Studio, so the place
-- file stays small and the scripts stay the source of the world.

local WorldBuilder = {}

-- The layout other systems read: conveyor waypoints, base centers and slots.
WorldBuilder.layout = nil

local function makePart(name, size, color, material, transparency)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Transparency = transparency or 0
	part.Anchored = true
	part.CanCollide = true
	part.CanQuery = true
	part.CanTouch = false
	return part
end

local function place(part, position, parent)
	part.Position = position
	part.Parent = parent
	return part
end

local function buildPalm(parent, position)
	local trunk = makePart("Trunk", Vector3.new(1.2, 7, 1.2), Color3.fromRGB(140, 95, 50), Enum.Material.Wood)
	trunk.Position = position + Vector3.new(0, 3.5, 0)
	trunk.Parent = parent
	for i = 1, 5 do
		local angle = (i - 1) * (math.pi * 2 / 5)
		local leaf = makePart("Leaf", Vector3.new(1, 0.5, 4.5), Color3.fromRGB(40, 160, 70), Enum.Material.Grass)
		leaf.CFrame = CFrame.new(position + Vector3.new(0, 7.2, 0))
			* CFrame.Angles(0, angle, 0)
			* CFrame.new(0, 0.4, 2)
			* CFrame.Angles(math.rad(-25), 0, 0)
		leaf.Parent = parent
	end
end

local function buildBase(parent, index, center)
	local folder = Instance.new("Folder")
	folder.Name = "Base" .. index
	folder.Parent = parent

	local platform = makePart("Platform", Vector3.new(26, 1, 20), Color3.fromRGB(210, 180, 140), Enum.Material.Sand)
	platform.CFrame = center
	platform.Parent = folder

	local trim = makePart("Trim", Vector3.new(26.6, 0.4, 20.6), Color3.fromRGB(90, 160, 220), Enum.Material.SmoothPlastic)
	trim.CFrame = center * CFrame.new(0, -0.4, 0)
	trim.Parent = folder

	-- A floating sign that BaseManager fills with the owner's name.
	local sign = Instance.new("BillboardGui")
	sign.Name = "BaseSign"
	sign.Size = UDim2.fromOffset(120, 32)
	sign.StudsOffset = Vector3.new(0, 7, 0)
	sign.AlwaysOnTop = true
	local label = Instance.new("TextLabel")
	label.Name = "Owner"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
	label.BackgroundTransparency = 0.2
	label.Text = "Base " .. index
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = sign
	local anchor = makePart("SignPost", Vector3.new(1, 5, 1), Color3.fromRGB(120, 90, 60), Enum.Material.Wood)
	anchor.CFrame = center * CFrame.new(0, 2.5, -9)
	anchor.Parent = folder
	sign.Parent = anchor

	-- Twelve slot pads in a 3 by 4 grid, facing the plaza.
	local slots = {}
	for row = 1, 4 do
		for col = 1, 3 do
			local slotIndex = (row - 1) * 3 + col
			local pad = makePart("Pad" .. slotIndex, Vector3.new(5, 0.3, 4), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, 0.6)
			local offset = CFrame.new((col - 2) * 7, 0.7, (row - 2.5) * 4.5)
			pad.CFrame = center * offset
			pad.Parent = folder
			slots[slotIndex] = pad.Position + Vector3.new(0, 0.2, 0)
		end
	end

	return { center = center, slots = slots, folder = folder, sign = label }
end

function WorldBuilder.build()
	local workspace = game:GetService("Workspace")
	local island = Instance.new("Folder")
	island.Name = "BrainrotBay"
	island.Parent = workspace

	-- Sand island on top of the sea.
	local sand = makePart("Sand", Vector3.new(220, 2, 220), Color3.fromRGB(240, 220, 160), Enum.Material.Sand)
	place(sand, Vector3.new(0, 0, 0), island)
	local sea = makePart("Sea", Vector3.new(500, 1, 500), Color3.fromRGB(40, 140, 220), Enum.Material.Water, 0.25)
	sea.CanCollide = false -- falling off the island drops you into the bay, not onto the water
	place(sea, Vector3.new(0, 0.1, 0), island)

	-- Central plaza: a round stage where the conveyor crosses.
	local plaza = makePart("Plaza", Vector3.new(0.6, 34, 34), Color3.fromRGB(200, 190, 170), Enum.Material.Concrete, 0)
	plaza.Shape = Enum.PartType.Cylinder
	plaza.CFrame = CFrame.new(0, 0.95, 0) * CFrame.Angles(0, 0, math.rad(90))
	place(plaza, Vector3.new(0, 0.95, 0), island)

	-- The conveyor walkway the brainrots stroll down, south to north.
	local path = makePart("ConveyorPath", Vector3.new(8, 0.3, 140), Color3.fromRGB(70, 70, 80), Enum.Material.Concrete)
	place(path, Vector3.new(0, 1.15, 0), island)
	local gateLeft = makePart("Gate", Vector3.new(1, 8, 1), Color3.fromRGB(255, 170, 30), Enum.Material.Neon)
	place(gateLeft, Vector3.new(-4.5, 5, 72), island)
	local gateRight = makePart("Gate", Vector3.new(1, 8, 1), Color3.fromRGB(255, 170, 30), Enum.Material.Neon)
	place(gateRight, Vector3.new(4.5, 5, 72), island)
	local gateTop = makePart("Gate", Vector3.new(10, 1, 1), Color3.fromRGB(255, 170, 30), Enum.Material.Neon)
	place(gateTop, Vector3.new(0, 9, 72), island)

	-- The pier runs south into the sea, past the spawn.
	for i = 1, 6 do
		local plank = makePart("PierPlank", Vector3.new(6, 0.5, 3), Color3.fromRGB(150, 110, 70), Enum.Material.Wood)
		place(plank, Vector3.new(0, 1.2, 96 + i * 3.2), island)
	end

	-- Palm trees around the rim, plus rocks and bushes for depth.
	local palmSpots = {
		Vector3.new(-80, 1, -60), Vector3.new(80, 1, -60), Vector3.new(-90, 1, 10),
		Vector3.new(90, 1, 10), Vector3.new(-70, 1, 70), Vector3.new(70, 1, 70),
		Vector3.new(-40, 1, -85), Vector3.new(40, 1, -85), Vector3.new(-95, 1, -40),
		Vector3.new(95, 1, -40),
	}
	for _, spot in ipairs(palmSpots) do
		buildPalm(island, spot)
	end
	for i = 1, 8 do
		local rock = makePart("Rock", Vector3.new(3, 2, 3), Color3.fromRGB(140, 140, 140), Enum.Material.Slate)
		rock.Shape = Enum.PartType.Ball
		local angle = math.rad(i * 45 + 15)
		place(rock, Vector3.new(math.cos(angle) * 100, 2, math.sin(angle) * 100), island)
	end

	-- Eight bases in a ring around the plaza, each facing the center.
	local bases = {}
	for i = 1, 8 do
		local angle = (i - 1) * (math.pi * 2 / 8) + math.pi / 8
		local x = math.cos(angle) * 58
		local z = math.sin(angle) * 58
		local facing = CFrame.new(x, 1.5, z) * CFrame.Angles(0, -angle + math.pi / 2 + math.pi, 0)
		bases[i] = buildBase(island, i, facing)
	end

	-- Spawn point on the plaza's south edge.
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "BaySpawn"
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = Vector3.new(0, 1.6, 82)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = island

	local waypoints = {}
	for z = -68, 68, 20 do
		table.insert(waypoints, Vector3.new(0, 1.4, z))
	end

	WorldBuilder.layout = {
		waypoints = waypoints,
		bases = bases,
		spawnCFrame = CFrame.new(0, 3, 82),
	}
	return WorldBuilder.layout
end

return WorldBuilder
