-- Brainrot Bay cast: every character is invented for this game, with its own
-- name, rarity, price and money-per-second. No name or character comes from
-- Steal a Brainrot or any other commercial game.

local BrainrotData = {}

-- Rarity ladder, cheapest first. Color tints the character's label and body trim.
BrainrotData.RARITIES = {
	{ name = "Common", color = Color3.fromRGB(120, 200, 90), weight = 40 },
	{ name = "Rare", color = Color3.fromRGB(80, 160, 255), weight = 28 },
	{ name = "Epic", color = Color3.fromRGB(190, 90, 255), weight = 16 },
	{ name = "Legendary", color = Color3.fromRGB(255, 170, 30), weight = 10 },
	{ name = "Mythic", color = Color3.fromRGB(255, 70, 120), weight = 5 },
	{ name = "Secret", color = Color3.fromRGB(40, 40, 40), weight = 1 },
}

-- Mutations roll when a brainrot spawns: same character, multiplied income.
BrainrotData.MUTATIONS = {
	{ name = "Normal", multiplier = 1, chance = 0.86, tint = nil },
	{ name = "Golden", multiplier = 2, chance = 0.10, tint = Color3.fromRGB(255, 215, 0) },
	{ name = "Diamond", multiplier = 5, chance = 0.03, tint = Color3.fromRGB(120, 230, 255) },
	{ name = "Rainbow", multiplier = 10, chance = 0.01, tint = Color3.fromRGB(255, 120, 220) },
}

-- The cast. bodyColor tints the body, trimColor the head and trim,
-- accessory picks the extra part BrainrotBuilder adds.
BrainrotData.CHARACTERS = {
	{ id = "bebek-dj", name = "Bebek DJ", rarity = "Common", cost = 50, income = 2,
		bodyColor = Color3.fromRGB(255, 220, 80), trimColor = Color3.fromRGB(255, 140, 40),
		accessory = "headphones", size = 1.0, blurb = "Quacks the beat, drops the bass." },
	{ id = "nasi-ninja", name = "Nasi Goreng Ninja", rarity = "Common", cost = 120, income = 4,
		bodyColor = Color3.fromRGB(230, 190, 120), trimColor = Color3.fromRGB(200, 60, 60),
		accessory = "band", size = 1.0, blurb = "Fried rice. Silent. Deadly tasty." },
	{ id = "kapten-kelapa", name = "Kapten Kelapa", rarity = "Rare", cost = 400, income = 12,
		bodyColor = Color3.fromRGB(150, 105, 50), trimColor = Color3.fromRGB(255, 255, 255),
		accessory = "hat", size = 1.1, blurb = "Sails the bay in half a shell." },
	{ id = "kucing-angkasa", name = "Kucing Angkasa", rarity = "Rare", cost = 750, income = 20,
		bodyColor = Color3.fromRGB(180, 180, 200), trimColor = Color3.fromRGB(120, 90, 220),
		accessory = "helmet", size = 1.0, blurb = "Meows from low orbit." },
	{ id = "paus-kopi", name = "Paus Kopi", rarity = "Epic", cost = 2000, income = 55,
		bodyColor = Color3.fromRGB(90, 140, 220), trimColor = Color3.fromRGB(90, 60, 30),
		accessory = "cup", size = 1.5, blurb = "Brews espresso in the deep sea." },
	{ id = "durian-raja", name = "Durian Raja", rarity = "Epic", cost = 3500, income = 90,
		bodyColor = Color3.fromRGB(190, 220, 70), trimColor = Color3.fromRGB(255, 215, 0),
		accessory = "crown", size = 1.2, blurb = "King of fruit. Smells like victory." },
	{ id = "robot-rujak", name = "Robot Rujak", rarity = "Legendary", cost = 9000, income = 220,
		bodyColor = Color3.fromRGB(160, 170, 180), trimColor = Color3.fromRGB(255, 80, 80),
		accessory = "antenna", size = 1.3, blurb = "Serves spicy salad at 9000 RPM." },
	{ id = "hiu-eskrim", name = "Hiu Es Krim", rarity = "Legendary", cost = 15000, income = 350,
		bodyColor = Color3.fromRGB(140, 200, 255), trimColor = Color3.fromRGB(255, 180, 200),
		accessory = "cone", size = 1.4, blurb = "Melts hearts. And itself. Slowly." },
	{ id = "naga-indomie", name = "Naga Indomie", rarity = "Mythic", cost = 45000, income = 900,
		bodyColor = Color3.fromRGB(255, 200, 60), trimColor = Color3.fromRGB(220, 60, 40),
		accessory = "wings", size = 1.7, blurb = "A noodle dragon, extra pedas." },
	{ id = "kura-turbo", name = "Kura-Kura Turbo", rarity = "Mythic", cost = 70000, income = 1400,
		bodyColor = Color3.fromRGB(90, 180, 90), trimColor = Color3.fromRGB(255, 120, 0),
		accessory = "spoiler", size = 1.4, blurb = "Slow shell. Illegal speed." },
	{ id = "stroberi-samurai", name = "Stroberi Samurai", rarity = "Secret", cost = 160000, income = 3200,
		bodyColor = Color3.fromRGB(255, 70, 90), trimColor = Color3.fromRGB(200, 200, 210),
		accessory = "sword", size = 1.5, blurb = "Slices berries. And fate." },
	{ id = "raja-semesta", name = "Raja Semesta", rarity = "Secret", cost = 250000, income = 5000,
		bodyColor = Color3.fromRGB(60, 50, 120), trimColor = Color3.fromRGB(255, 215, 0),
		accessory = "crown", size = 1.8, blurb = "Rules every bay in every universe." },
}

-- The tide wave carries this one: free to whoever clicks it first.
BrainrotData.WAVE_BRAINROT = {
	id = "ikan-ombak", name = "Ikan Ombak", rarity = "Epic", cost = 0, income = 800,
	bodyColor = Color3.fromRGB(60, 180, 255), trimColor = Color3.fromRGB(255, 255, 255),
	accessory = "wings", size = 1.3, blurb = "Rode in on the big wave.",
}

-- Every rebirth grants this exclusive brainrot, stronger each rebirth.
BrainrotData.REBIRTH_BRAINROT = {
	id = "garuda-emas", name = "Garuda Emas", rarity = "Mythic", cost = 0, income = 1500,
	bodyColor = Color3.fromRGB(255, 200, 40), trimColor = Color3.fromRGB(200, 40, 40),
	accessory = "wings", size = 1.6, blurb = "Born again, shinier than before.",
}

function BrainrotData.getRarity(name)
	for _, rarity in ipairs(BrainrotData.RARITIES) do
		if rarity.name == name then
			return rarity
		end
	end
	return BrainrotData.RARITIES[1]
end

function BrainrotData.getCharacter(id)
	for _, character in ipairs(BrainrotData.CHARACTERS) do
		if character.id == id then
			return character
		end
	end
	return nil
end

function BrainrotData.charactersOfRarity(name)
	local list = {}
	for _, character in ipairs(BrainrotData.CHARACTERS) do
		if character.rarity == name then
			table.insert(list, character)
		end
	end
	return list
end

-- Weighted rarity roll for the conveyor, then a random character of that rarity.
function BrainrotData.rollCharacter()
	local total = 0
	for _, rarity in ipairs(BrainrotData.RARITIES) do
		total += rarity.weight
	end
	local roll = math.random() * total
	for _, rarity in ipairs(BrainrotData.RARITIES) do
		roll -= rarity.weight
		if roll <= 0 then
			local pool = BrainrotData.charactersOfRarity(rarity.name)
			return pool[math.random(1, #pool)]
		end
	end
	return BrainrotData.CHARACTERS[1]
end

-- Mutation roll: most brainrots are Normal, a few come gilded.
function BrainrotData.rollMutation()
	local roll = math.random()
	local running = 0
	for _, mutation in ipairs(BrainrotData.MUTATIONS) do
		running += mutation.chance
		if roll <= running then
			return mutation
		end
	end
	return BrainrotData.MUTATIONS[1]
end

function BrainrotData.incomeOf(character, mutation, rebirthMultiplier)
	return math.floor(character.income * mutation.multiplier * rebirthMultiplier + 0.5)
end

function BrainrotData.rebirthCost(rebirths)
	return math.floor(50000 * (rebirths + 1) * (rebirths + 1))
end

return BrainrotData
