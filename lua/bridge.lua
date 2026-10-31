-- Command Bridge Navigation Controls & Zero-Disconnect Persistence
-- Handles Steering Wheel, Engine Telegraph, Formspecs, and Overworld Chunk Emerge

cruiseship.bridge = {}

-- Ensure exterior vessel is loaded in memory via emerge_area if necessary
local function ensure_exterior_entity(ship_id)
    local ent = cruiseship.active_entities[ship_id]
    if ent and ent.object and ent.object:get_pos() then
        return ent
    end

    local ship = cruiseship.storage.get_ship(ship_id)
    if not ship or not ship.exterior_pos then
        return nil
    end

    local p = ship.exterior_pos
    local minp = {x = p.x - 32, y = p.y - 16, z = p.z - 32}
    local maxp = {x = p.x + 32, y = p.y + 16, z = p.z + 32}

    -- Trigger chunk loading
    if minetest.emerge_area then
        minetest.emerge_area(minp, maxp)
    end

    -- Look for existing entity in loaded objects
    for _, obj in pairs(minetest.luaentities or {}) do
        if obj.name == "cruiseship:exterior_vessel" and obj.ship_id == ship_id then
            cruiseship.active_entities[ship_id] = obj
            return obj
        end
    end

    -- If entity was destroyed or not yet revived after server restart, respawn it at persisted coords
    local staticdata = minetest.write_json({
        ship_id = ship_id,
        current_speed = ship.speed or 0,
        target_yaw = ship.target_yaw or ship.exterior_yaw or 0,
    })
    local obj = minetest.add_entity(p, "cruiseship:exterior_vessel", staticdata)
    if obj then
        obj:set_yaw(ship.exterior_yaw or 0)
        local luaent = obj:get_luaentity()
        cruiseship.active_entities[ship_id] = luaent
        return luaent
    end

    return nil
end

-- Resolve ship_id from node position if not stored in meta
local function resolve_ship_id(pos)
    local meta = minetest.get_meta(pos)
    local ship_id = meta:get_string("ship_id")
    if ship_id and ship_id ~= "" then
        return ship_id
    end

    local slot_idx = math.floor((pos.x + 100) / cruiseship.SKY_SLOT_SPACING)
    local all_ships = cruiseship.storage.get_all_ships()
    for id, sdata in pairs(all_ships) do
        if sdata.slot_index == slot_idx then
            meta:set_string("ship_id", id)
            return id
        end
    end
    return nil
end

-- Show Helm / Steering Wheel Formspec
function cruiseship.bridge.show_helm_formspec(pos, player)
    local ship_id = resolve_ship_id(pos)
    if not ship_id then
        minetest.chat_send_player(player:get_player_name(), "Ship control system offline: Unknown vessel ID.")
        return
    end

    local ship = cruiseship.storage.get_ship(ship_id)
    local current_yaw = ship and (ship.target_yaw or ship.exterior_yaw) or 0
    local heading_deg = math.floor(math.deg(current_yaw) % 360)

    local formspec = "size[8,6]" ..
        "label[0.5,0.4;=== CRUISE SHIP COMMAND BRIDGE: HELM ===]" ..
        "label[0.5,0.9;Ship: " .. minetest.formspec_escape(ship and ship.name or ship_id) .. "]" ..
        "label[0.5,1.4;Current Heading: " .. heading_deg .. "°]" ..
        "button[0.5,2.2;3.2,0.8;turn_port_30;<<< Port 30°]" ..
        "button[4.3,2.2;3.2,0.8;turn_star_30;Starboard 30° >>>]" ..
        "button[0.5,3.2;3.2,0.8;turn_port_10;< Port 10°]" ..
        "button[4.3,3.2;3.2,0.8;turn_star_10;Starboard 10° >]" ..
        "button[2.4,4.2;3.2,0.8;turn_center;Rudder Amidships (0°)]" ..
        "button[2.4,5.1;3.2,0.8;sound_horn;BLOW STEAM HORN]"

    minetest.show_formspec(player:get_player_name(), "cruiseship:helm_" .. ship_id, formspec)
end

-- Show Engine Telegraph Formspec
function cruiseship.bridge.show_telegraph_formspec(pos, player)
    local ship_id = resolve_ship_id(pos)
    if not ship_id then
        minetest.chat_send_player(player:get_player_name(), "Ship control system offline: Unknown vessel ID.")
        return
    end

    local ship = cruiseship.storage.get_ship(ship_id)
    local speed = ship and (ship.speed or 0) or 0
    local speed_str = "STOP"
    if speed >= 10 then speed_str = "FULL AHEAD (12 m/s)"
    elseif speed >= 6 then speed_str = "HALF AHEAD (7 m/s)"
    elseif speed > 0 then speed_str = "SLOW AHEAD (3.5 m/s)"
    elseif speed < 0 then speed_str = "FULL ASTERN (-3 m/s)"
    end

    local formspec = "size[8,6.5]" ..
        "label[0.5,0.4;=== CRUISE SHIP ENGINE TELEGRAPH ===]" ..
        "label[0.5,0.9;Ship: " .. minetest.formspec_escape(ship and ship.name or ship_id) .. "]" ..
        "label[0.5,1.4;Current Engine Order: " .. speed_str .. "]" ..
        "button[0.5,2.2;7.0,0.8;speed_full_ahead;FULL AHEAD (Cruising Speed 12 m/s)]" ..
        "button[0.5,3.1;7.0,0.8;speed_half_ahead;HALF AHEAD (Harbor Speed 7 m/s)]" ..
        "button[0.5,4.0;7.0,0.8;speed_slow_ahead;SLOW AHEAD (Maneuvering 3.5 m/s)]" ..
        "button[0.5,4.9;3.3,0.8;speed_stop;ALL STOP (0 m/s)]" ..
        "button[4.2,4.9;3.3,0.8;speed_reverse;FULL ASTERN (-3 m/s)]" ..
        "button[0.5,5.8;7.0,0.6;btn_dismantle;Dismantle Cruise Liner (Safe Decommission)]"

    minetest.show_formspec(player:get_player_name(), "cruiseship:telegraph_" .. ship_id, formspec)
end

-- Formspec Event Handler
minetest.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()

    -- 1. Helm Formspec
    if string.find(formname, "^cruiseship:helm_") then
        local ship_id = string.sub(formname, 17)
        local ent = ensure_exterior_entity(ship_id)
        local ship = cruiseship.storage.get_ship(ship_id)
        local current_yaw = ship and (ship.target_yaw or ship.exterior_yaw) or 0

        if fields.turn_port_30 then
            local new_yaw = current_yaw - math.rad(30)
            if ent then ent.target_yaw = new_yaw end
            cruiseship.storage.update_ship(ship_id, {target_yaw = new_yaw})
            minetest.chat_send_player(player_name, "Helm: Bearing Port 30° (Heading " .. math.floor(math.deg(new_yaw) % 360) .. "°)")
        elseif fields.turn_star_30 then
            local new_yaw = current_yaw + math.rad(30)
            if ent then ent.target_yaw = new_yaw end
            cruiseship.storage.update_ship(ship_id, {target_yaw = new_yaw})
            minetest.chat_send_player(player_name, "Helm: Bearing Starboard 30° (Heading " .. math.floor(math.deg(new_yaw) % 360) .. "°)")
        elseif fields.turn_port_10 then
            local new_yaw = current_yaw - math.rad(10)
            if ent then ent.target_yaw = new_yaw end
            cruiseship.storage.update_ship(ship_id, {target_yaw = new_yaw})
            minetest.chat_send_player(player_name, "Helm: Bearing Port 10° (Heading " .. math.floor(math.deg(new_yaw) % 360) .. "°)")
        elseif fields.turn_star_10 then
            local new_yaw = current_yaw + math.rad(10)
            if ent then ent.target_yaw = new_yaw end
            cruiseship.storage.update_ship(ship_id, {target_yaw = new_yaw})
            minetest.chat_send_player(player_name, "Helm: Bearing Starboard 10° (Heading " .. math.floor(math.deg(new_yaw) % 360) .. "°)")
        elseif fields.turn_center then
            if ent then ent.target_yaw = 0 end
            cruiseship.storage.update_ship(ship_id, {target_yaw = 0})
            minetest.chat_send_player(player_name, "Helm: Rudder Amidships (Heading 0° True North)")
        elseif fields.sound_horn then
            if ent and ent.object then
                minetest.sound_play("rms_menotics_horn", {
                    pos = ent.object:get_pos(),
                    gain = 1.0,
                    max_hear_distance = 300,
                })
            end
            -- Also play sound inside bridge
            minetest.sound_play("rms_menotics_horn", {
                to_player = player_name,
                gain = 0.8,
            })
            minetest.chat_send_all("[RMS Sovereign / " .. ship_id .. "] *BURSTS STEAM HORN*")
        end
        return true
    end

    -- 2. Telegraph Formspec
    if string.find(formname, "^cruiseship:telegraph_") then
        local ship_id = string.sub(formname, 22)
        local ent = ensure_exterior_entity(ship_id)

        local target_speed = nil
        local speed_name = nil

        if fields.speed_full_ahead then
            target_speed = cruiseship.SPEED_FULL
            speed_name = "FULL AHEAD"
        elseif fields.speed_half_ahead then
            target_speed = cruiseship.SPEED_HALF
            speed_name = "HALF AHEAD"
        elseif fields.speed_slow_ahead then
            target_speed = cruiseship.SPEED_SLOW
            speed_name = "SLOW AHEAD"
        elseif fields.speed_stop then
            target_speed = cruiseship.SPEED_STOP
            speed_name = "ALL STOP"
        elseif fields.speed_reverse then
            target_speed = cruiseship.SPEED_REVERSE
            speed_name = "FULL ASTERN"
        elseif fields.btn_dismantle then
            cruiseship.cleanup.dismantle_ship(ship_id, player)
            minetest.close_formspec(player_name, formname)
            return true
        end

        if target_speed ~= nil then
            if ent then
                ent.current_speed = target_speed
            end
            cruiseship.storage.update_ship(ship_id, {speed = target_speed})
            minetest.chat_send_player(player_name, "Engine Telegraph rung: " .. speed_name .. " (" .. target_speed .. " m/s)")

            -- Sound telegraph bell / horn burst on departure or speed change
            if ent and ent.object then
                minetest.sound_play("rms_menotics_horn", {
                    pos = ent.object:get_pos(),
                    gain = 0.7,
                    max_hear_distance = 250,
                })
            end
            minetest.sound_play("cruiseship_engine", {
                to_player = player_name,
                gain = 0.6,
            })
        end
        return true
    end
end)
