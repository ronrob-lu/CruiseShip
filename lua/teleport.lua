-- Seamless Dual-Plane Boarding & Exit Teleportation
-- Translates between exterior overworld moving vessel and static sky interior

cruiseship.teleport = {}

-- Board ship: Teleport from overworld exterior to sky interior foyer
function cruiseship.teleport.board_ship(ship_id, player)
    local ship = cruiseship.storage.get_ship(ship_id)
    if not ship then
        minetest.chat_send_player(player:get_player_name(), "Ship data not found in registry!")
        return
    end

    local slot_origin = cruiseship.storage.get_slot_origin(ship.slot_index)
    local entry_pos = cruiseship.generator.get_entry_pos(slot_origin)

    -- Play entrance chime/atmosphere
    minetest.sound_play("cruiseship_engine", {
        to_player = player:get_player_name(),
        gain = 0.5,
    })

    player:set_pos(entry_pos)
    -- Face forward down the grand foyer towards the central atrium (+Z)
    player:set_look_horizontal(0)

    minetest.chat_send_player(player:get_player_name(), "Welcome aboard " .. tostring(ship.name) .. "! Enjoy your cruise.")
end

-- Exit ship: Teleport from sky interior gangway back to exterior vessel in the ocean
-- Crucial: Player exits in the new direction/position of the ship!
function cruiseship.teleport.exit_to_overworld(portal_pos, player)
    local meta = minetest.get_meta(portal_pos)
    local ship_id = meta:get_string("ship_id")

    if not ship_id or ship_id == "" then
        -- Attempt to find ship by slot coordinates
        local slot_idx = math.floor((portal_pos.x + 100) / cruiseship.SKY_SLOT_SPACING)
        local all_ships = cruiseship.storage.get_all_ships()
        for id, data in pairs(all_ships) do
            if data.slot_index == slot_idx then
                ship_id = id
                break
            end
        end
    end

    if not ship_id or ship_id == "" then
        minetest.chat_send_player(player:get_player_name(), "Unable to resolve ship reference for exit door!")
        return
    end

    local ship = cruiseship.storage.get_ship(ship_id)
    if not ship then
        minetest.chat_send_player(player:get_player_name(), "Ship registry records missing!")
        return
    end

    -- Query active exterior entity or use persisted position
    local exterior_pos = nil
    local exterior_yaw = ship.exterior_yaw or 0

    local ent = cruiseship.active_entities[ship_id]
    if ent and ent.object and ent.object:get_pos() then
        exterior_pos = ent.object:get_pos()
        exterior_yaw = ent.object:get_yaw() or exterior_yaw
    else
        exterior_pos = ship.exterior_pos
    end

    if not exterior_pos then
        minetest.chat_send_player(player:get_player_name(), "Exterior vessel coordinates unavailable.")
        return
    end

    -- Calculate gangway exit offset rotated to match exterior vessel's yaw
    -- In ship coordinate space, gangway exit is at starboard/port side (e.g. x = +15, y = +1, z = -20)
    local local_offset_x = 15.0
    local local_offset_z = -15.0

    -- Rotate by exterior vessel yaw
    local cos_y = math.cos(exterior_yaw)
    local sin_y = math.sin(exterior_yaw)

    local world_offset_x = local_offset_x * cos_y + local_offset_z * sin_y
    local world_offset_z = -local_offset_x * sin_y + local_offset_z * cos_y

    local exit_world_pos = {
        x = exterior_pos.x + world_offset_x,
        y = exterior_pos.y + 1.5,
        z = exterior_pos.z + world_offset_z,
    }

    -- Teleport player to the overworld vessel exterior
    player:set_pos(exit_world_pos)
    -- Rotate player to face outward perpendicular to the ship's heading
    player:set_look_horizontal(exterior_yaw + math.pi / 2)

    minetest.chat_send_player(player:get_player_name(), "You disembarked from the cruise ship at: (" ..
        math.floor(exit_world_pos.x) .. ", " ..
        math.floor(exit_world_pos.y) .. ", " ..
        math.floor(exit_world_pos.z) .. ") heading: " ..
        math.floor(math.deg(exterior_yaw)) .. "°")
end
