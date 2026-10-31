-- Administrative and Utility Chat Commands

minetest.register_chatcommand("spawn_cruise_ship", {
    params = "",
    description = "Spawn a 200m luxury cruise ship at your current position",
    privs = {server = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end

        local pos = player:get_pos()
        local yaw = player:get_look_horizontal()

        local success, msg_or_id = cruiseship.spawn_cruise_liner(pos, yaw)
        if success then
            return true, "Cruise Ship spawned! Ship ID: " .. msg_or_id
        else
            return false, "Failed to spawn cruise ship: " .. tostring(msg_or_id)
        end
    end,
})

minetest.register_chatcommand("clear_all_cruise_ships", {
    params = "",
    description = "Safely dismantle all active cruise ships and reset sky spaces",
    privs = {server = true},
    func = function(name, param)
        cruiseship.cleanup.clear_all_ships(name)
        return true, "All cruise ships safely cleared and sky dimension spaces reset."
    end,
})

minetest.register_chatcommand("tp_cruise_ship", {
    params = "<ship_id>",
    description = "Teleport to the sky interior of a specified cruise ship",
    privs = {teleport = true},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end

        local ship_id = string.match(param, "%S+")
        if not ship_id then
            -- If no ID given, pick first active ship
            local all_ships = cruiseship.storage.get_all_ships()
            for id, _ in pairs(all_ships) do
                ship_id = id
                break
            end
        end

        if not ship_id then
            return false, "No active cruise ships found."
        end

        cruiseship.teleport.board_ship(ship_id, player)
        return true, "Teleported to cruise ship interior: " .. ship_id
    end,
})

minetest.register_chatcommand("list_cruise_ships", {
    params = "",
    description = "List all active cruise ships and their coordinates",
    privs = {server = true},
    func = function(name, param)
        local all_ships = cruiseship.storage.get_all_ships()
        local lines = {"Active Cruise Ships:"}
        local count = 0
        for id, data in pairs(all_ships) do
            count = count + 1
            local p = data.exterior_pos or {x = 0, y = 0, z = 0}
            table.insert(lines, string.format(" - %s [%s]: Slot %d, Pos: (%.1f, %.1f, %.1f), Speed: %.1f m/s",
                data.name or "Liner", id, data.slot_index, p.x, p.y, p.z, data.speed or 0))
        end
        if count == 0 then
            return true, "No active cruise ships."
        end
        return true, table.concat(lines, "\n")
    end,
})
