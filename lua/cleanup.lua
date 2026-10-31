-- Dismantling, Cargo Safety, and Cleanup Logic
-- Scans interior for player luggage, drops items safely, wipes sky blocks back to air,
-- drops cruiseship:ship_item for the player, and recycles slot.

cruiseship.cleanup = {}


function cruiseship.cleanup.dismantle_ship(ship_id, player)
    local c_air = minetest.get_content_id("air")
    local ship = cruiseship.storage.get_ship(ship_id)
    if not ship then
        if player then
            minetest.chat_send_player(player:get_player_name(), "Ship [" .. tostring(ship_id) .. "] not found in registry!")
        end
        return false
    end

    local slot_index = ship.slot_index
    local origin = cruiseship.storage.get_slot_origin(slot_index)
    local minp, maxp = cruiseship.storage.get_slot_bounds(slot_index)
    local exterior_pos = ship.exterior_pos

    -- 1. Scan for cargo containers & luggage (chests, furnaces, player items)
    local dropped_items_count = 0
    local drop_pos = exterior_pos or (player and player:get_pos()) or {x = 0, y = 1, z = 0}

    -- Scan nodes with metadata (inventories)
    for z = minp.z, maxp.z do
        for y = minp.y, maxp.y do
            for x = minp.x, maxp.x do
                local p = {x = x, y = y, z = z}
                local meta = minetest.get_meta(p)
                if meta then
                    local inv = meta:get_inventory()
                    if inv then
                        for listname, list in pairs(inv:get_lists()) do
                            for _, stack in ipairs(list) do
                                if not stack:is_empty() then
                                    minetest.add_item(drop_pos, stack)
                                    dropped_items_count = dropped_items_count + stack:get_count()
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. Wipe sky realm blocks back to empty air using VoxelManip
    local manip = minetest.get_voxel_manip()
    if not manip and VoxelManip then
        manip = VoxelManip()
    end
    if not manip then
        error("Failed to acquire VoxelManipulator")
    end
    local emerged_min, emerged_max = manip:read_from_map(minp, maxp)
    local area = VoxelArea:new({MinEdge = emerged_min, MaxEdge = emerged_max})
    local data = manip:get_data()

    for z = minp.z, maxp.z do
        for y = minp.y, maxp.y do
            for x = minp.x, maxp.x do
                local vi = area:index(x, y, z)
                data[vi] = c_air
            end
        end
    end

    manip:set_data(data)
    manip:write_to_map()
    manip:update_map()

    -- 3. Teleport any players inside this sky slot back to overworld safe drop_pos
    local players = minetest.get_connected_players()
    for _, p in ipairs(players) do
        local ppos = p:get_pos()
        if ppos and ppos.x >= minp.x and ppos.x <= maxp.x and
           ppos.y >= minp.y and ppos.y <= maxp.y and
           ppos.z >= minp.z and ppos.z <= maxp.z then
            p:set_pos(drop_pos)
            minetest.chat_send_player(p:get_player_name(), "Ship dismantled! You have been safely returned to the ocean surface.")
        end
    end

    -- 4. Delete the exterior moving vessel entity
    local ent = cruiseship.active_entities[ship_id]
    if ent and ent.object then
        ent.object:remove()
    else
        -- Search loaded entities
        for _, obj in pairs(minetest.luaentities or {}) do
            if obj.name == "cruiseship:exterior_vessel" and obj.ship_id == ship_id then
                obj.object:remove()
            end
        end
    end
    cruiseship.active_entities[ship_id] = nil

    -- 5. Drop the ship deployer item for player
    minetest.add_item(drop_pos, "cruiseship:ship_item 1")

    -- 6. Free slot in storage
    cruiseship.storage.free_slot(ship_id)

    if player then
        minetest.chat_send_player(player:get_player_name(),
            "Ship [" .. ship_id .. "] decommissioned successfully! Sky slot " .. slot_index ..
            " cleared. " .. dropped_items_count .. " cargo items recovered.")
    end

    return true
end

-- Clear all active cruise ships (Emergency/Admin reset)
function cruiseship.cleanup.clear_all_ships(sender_name)
    local all_ships = cruiseship.storage.get_all_ships()
    local count = 0

    for id, sdata in pairs(all_ships) do
        cruiseship.cleanup.dismantle_ship(id, nil)
        count = count + 1
    end

    cruiseship.storage.clear_all()

    local msg = "All cruise ships (" .. count .. ") have been purged and all sky slots reset."
    minetest.log("action", "[cruiseship] " .. msg)
    if sender_name then
        minetest.chat_send_player(sender_name, msg)
    end
end
