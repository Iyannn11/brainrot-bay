-- Brainrot Bay tuning: every number the game balances on lives here.
-- Server modules read these values; the client never needs them.

local GameConfig = {}

-- Starting money for a brand-new player.
GameConfig.START_CASH = 100

-- Bases: every player starts with 4 slots and can buy up to 12.
GameConfig.START_SLOTS = 4
GameConfig.MAX_SLOTS = 12
-- Cost of the next slot, by how many the player already owns (slot 5..12).
GameConfig.SLOT_COSTS = { 500, 1500, 4000, 10000, 25000, 60000, 150000, 400000 }

-- Conveyor: a new brainrot walks in every few seconds, at most this many at once.
GameConfig.SPAWN_INTERVAL = 4
GameConfig.MAX_ON_CONVEYOR = 8
GameConfig.WALK_SPEED = 6 -- studs per second along the conveyor

-- A brainrot bought less than this long ago cannot be stolen yet.
GameConfig.PURCHASE_LOCK_SECONDS = 30
-- After a successful steal, the thief waits this long before stealing again.
GameConfig.STEAL_COOLDOWN_SECONDS = 60
-- Base lock: blocks every steal for this long, then this long a cooldown.
GameConfig.LOCK_DURATION_SECONDS = 20
GameConfig.LOCK_COOLDOWN_SECONDS = 90

-- The tide wave: every 150 s, warned 10 s ahead, then it sweeps the island.
GameConfig.WAVE_INTERVAL = 150
GameConfig.WAVE_WARNING_SECONDS = 10
GameConfig.WAVE_SPEED = 18 -- studs per second across the island

-- Rebirth: cash needed grows with the rebirth count; each rebirth adds +50% income.
GameConfig.REBIRTH_BASE_COST = 50000
GameConfig.REBIRTH_MULTIPLIER_STEP = 0.5

-- Saving: autosave cadence and the DataStore name.
GameConfig.AUTOSAVE_SECONDS = 90
GameConfig.DATASTORE_NAME = "BrainrotBay_v1"

return GameConfig
