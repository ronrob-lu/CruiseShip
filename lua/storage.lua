-- Persistent Multi-Ship Sky Dimension Storage & Slot Manager
-- luanti cruise liner pocket dimension slot allocation

cruiseship.storage = {}

local mod_storage = minetest.get_mod_storage()
local STORAGE_KEY_SLOTS = "active_slots"
local STORAGE_KEY_SHIPS = "ships_registry"

-- Slot architecture configuration
cruiseship.SKY_BASE_Y = 25000
cruiseship.SKY_SLOT_SPACING = 350
cruiseship.SHIP_LENGTH = 200
cruiseship.SHIP_WIDTH = 30
cruiseship.SHIP_HEIGHT = 32

-- In-memory cache of state
local state = {
    slots = {},  -- slot_index -> { ship_id = string, allocated_at = number }
    ships = {},  -- ship_id -> { slot_index = number, exterior_pos = vector, exterior_yaw = number, speed = number, target_yaw = number, name = string }
}

-- Load from mod_storage on startup
function cruiseship.storage.init()
    local raw_slots = mod_storage:get_string(STORAGE_KEY_SLOTS)
    if raw_slots and raw_slots ~= "" then
        local decoded = minetest.parse_json(raw_slots)
        if type(decoded) == "table" then
            state.slots = decoded
        end
    end

    local raw_ships = mod_storage:get_string(STORAGE_KEY_SHIPS)
    if raw_ships and raw_ships ~= "" then
        local decoded = minetest.parse_json(raw_ships)
        if type(decoded) == "table" then
            state.ships = decoded
        end
    end
end

-- Save to mod_storage
local function save()
    mod_storage:set_string(STORAGE_KEY_SLOTS, minetest.write_json(state.slots))
    mod_storage:set_string(STORAGE_KEY_SHIPS, minetest.write_json(state.ships))
end

-- Calculate base coordinates for a given slot index
function cruiseship.storage.get_slot_origin(slot_index)
    return {
        x = slot_index * cruiseship.SKY_SLOT_SPACING,
        y = cruiseship.SKY_BASE_Y,
        z = 0,
    }
end

-- Get bounding box for a slot
function cruiseship.storage.get_slot_bounds(slot_index)
    local origin = cruiseship.storage.get_slot_origin(slot_index)
    local minp = {
        x = origin.x - 25,
        y = origin.y - 4,
        z = origin.z - 105,
    }
    local maxp = {
        x = origin.x + 25,
        y = origin.y + cruiseship.SHIP_HEIGHT + 5,
        z = origin.z + 105,
    }
    return minp, maxp
end

-- Allocate a fresh or recycled slot
function cruiseship.storage.allocate_slot(ship_id)
    -- Find lowest free slot index (starting at 1)
    local slot_index = 1
    while state.slots[tostring(slot_index)] ~= nil do
        slot_index = slot_index + 1
    end

    local str_idx = tostring(slot_index)
    state.slots[str_idx] = {
        ship_id = ship_id,
        allocated_at = os.time(),
    }
    return slot_index
end

-- Register a new ship
function cruiseship.storage.register_ship(ship_id, slot_index, exterior_pos, exterior_yaw)
    state.ships[ship_id] = {
        ship_id = ship_id,
        slot_index = slot_index,
        exterior_pos = {
            x = math.floor(exterior_pos.x * 100) / 100,
            y = math.floor(exterior_pos.y * 100) / 100,
            z = math.floor(exterior_pos.z * 100) / 100,
        },
        exterior_yaw = exterior_yaw or 0,
        speed = 0,
        target_yaw = exterior_yaw or 0,
        name = "RMS Sovereign of the Seas (" .. string.sub(ship_id, 1, 6) .. ")",
    }
    save()
end

-- Get ship data
function cruiseship.storage.get_ship(ship_id)
    return state.ships[ship_id]
end

-- Update ship data
function cruiseship.storage.update_ship(ship_id, fields)
    if not state.ships[ship_id] then return end
    for k, v in pairs(fields) do
        state.ships[ship_id][k] = v
    end
    save()
end

-- Free a slot and unregister ship
function cruiseship.storage.free_slot(ship_id)
    local ship = state.ships[ship_id]
    if not ship then return nil end

    local slot_index = ship.slot_index
    state.slots[tostring(slot_index)] = nil
    state.ships[ship_id] = nil
    save()
    return slot_index
end

-- Get all active ships
function cruiseship.storage.get_all_ships()
    return state.ships
end

-- Clear all data (admin)
function cruiseship.storage.clear_all()
    state.slots = {}
    state.ships = {}
    save()
end

-- Initialize storage immediately on file execution
cruiseship.storage.init()
