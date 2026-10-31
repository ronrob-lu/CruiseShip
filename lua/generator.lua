-- 200m Walkable Modern Cruise Liner Interior Generator
-- Generates a multi-deck modern luxury vessel in the allocated sky slot.
-- Length: 200 blocks (-95 to +95 in Z)
-- Beam (Width): ~28 blocks (-14 to +14 in X)
-- Multi-deck structure:
--   Deck 0 (Y=0): Keel & Gangway Entry Foyer, Luggage Storage
--   Deck 1 (Y=5): Grand Multi-Deck Atrium & Luxury Passenger Staterooms
--   Deck 2 (Y=10): Ocean Promenade & Panoramic Dining Salon
--   Deck 3 (Y=15): Sun / Lido Deck with Heated Infinity Pool, Cabanas & Loungers
--   Deck 4 (Y=19): Elevated Command Bridge, Radar Mast & Twin Modern Funnels

cruiseship.generator = {}


-- Dynamic fallback IDs for chest, bed, furnace, wood

-- Hull profile helper: returns max half-width at a given Z (-95 to +95)
local function get_hull_half_width(z)
    if z > 50 then
        -- Bow taper towards bow tip at z=95
        local factor = (95 - z) / 45.0
        return math.max(1, math.floor(13.5 * math.sin(factor * math.pi / 2)))
    elseif z < -70 then
        -- Stern rounded taper
        local factor = (z - (-95)) / 25.0
        return math.max(4, math.floor(13.5 * math.sqrt(math.max(0, factor))))
    else
        return 14
    end
end

-- Key coordinate offsets relative to slot origin
function cruiseship.generator.get_entry_pos(slot_origin)
    return {
        x = slot_origin.x,
        y = slot_origin.y + 1,
        z = slot_origin.z - 20,
    }
end

function cruiseship.generator.get_bridge_pos(slot_origin)
    return {
        x = slot_origin.x,
        y = slot_origin.y + 20,
        z = slot_origin.z + 70,
    }
end

-- Procedural Interior Generation
function cruiseship.generator.generate(ship_id, slot_index)
    local c_air             = minetest.get_content_id("air")
    local c_deck_wood       = minetest.get_content_id("cruiseship:deck_wood")
    local c_hull_wall       = minetest.get_content_id("cruiseship:hull_wall")
    local c_interior_wall   = minetest.get_content_id("cruiseship:interior_wall")
    local c_carpet          = minetest.get_content_id("cruiseship:stateroom_carpet")
    local c_glass           = minetest.get_content_id("cruiseship:panoramic_glass")
    local c_railing         = minetest.get_content_id("cruiseship:glass_railing")
    local c_led             = minetest.get_content_id("cruiseship:led_ceiling_panel")
    local c_pool_tile       = minetest.get_content_id("cruiseship:pool_tile")
    local c_pool_water      = minetest.get_content_id("cruiseship:pool_water")
    local c_sofa            = minetest.get_content_id("cruiseship:modern_sofa")
    local c_chair           = minetest.get_content_id("cruiseship:deck_chair")
    local c_wheel           = minetest.get_content_id("cruiseship:steering_wheel")
    local c_telegraph       = minetest.get_content_id("cruiseship:engine_telegraph")
    local c_portal          = minetest.get_content_id("cruiseship:gangway_portal_interior")

    local node_chest = minetest.registered_nodes[cruiseship.compat.node_chest] and cruiseship.compat.node_chest or "cruiseship:deck_wood"
    local node_bed = minetest.registered_nodes[cruiseship.compat.node_bed] and cruiseship.compat.node_bed or "cruiseship:deck_wood"
    local node_furnace = minetest.registered_nodes[cruiseship.compat.node_furnace] and cruiseship.compat.node_furnace or "cruiseship:deck_wood"
    local node_wood = minetest.registered_nodes[cruiseship.compat.node_wood] and cruiseship.compat.node_wood or "cruiseship:deck_wood"

    local c_chest           = minetest.get_content_id(node_chest)
    local c_bed             = minetest.get_content_id(node_bed)
    local c_furnace         = minetest.get_content_id(node_furnace)
    local c_wood            = minetest.get_content_id(node_wood)
    local origin = cruiseship.storage.get_slot_origin(slot_index)
    local minp, maxp = cruiseship.storage.get_slot_bounds(slot_index)

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
    local param2_data = manip:get_param2_data()

    local ox = origin.x
    local oy = origin.y
    local oz = origin.z

    -- Quick helper to set node in voxel manipulator
    local function set_vox(x, y, z, cid, p2)
        local vi = area:index(x, y, z)
        data[vi] = cid
        if p2 then
            param2_data[vi] = p2
        end
    end

    -- 1. Outer Hull Shell & Keel (from z = -95 to +95, y = 0 to 18)
    for z = -95, 95 do
        local hw = get_hull_half_width(z)
        local world_z = oz + z

        for y = 0, 18 do
            local world_y = oy + y
            -- Taper hull inward near bottom (keel shape)
            local current_hw = hw
            if y < 3 then
                current_hw = math.max(2, hw - (3 - y) * 2)
            end

            for x = -current_hw, current_hw do
                local world_x = ox + x
                local is_outer = (x == -current_hw or x == current_hw or y == 0)

                if is_outer then
                    -- Exterior hull plating
                    set_vox(world_x, world_y, world_z, c_hull_wall)
                else
                    -- Interior volume (default empty air)
                    set_vox(world_x, world_y, world_z, c_air)
                end
            end
        end
    end

    -- 2. Deck Floors & Ceiling Lights
    -- Deck 0 (Foyer): y = 0 (floor at 0, ceiling at 4)
    -- Deck 1 (Atrium & Staterooms): y = 5 (floor at 5, ceiling at 9)
    -- Deck 2 (Dining & Promenade): y = 10 (floor at 10, ceiling at 14)
    -- Deck 3 (Sun Deck): y = 15 (floor at 15, open sky)

    for z = -93, 93 do
        local hw = get_hull_half_width(z)
        local world_z = oz + z

        -- Lower Deck (y = 0)
        for x = -hw + 1, hw - 1 do
            set_vox(ox + x, oy, world_z, c_deck_wood)
        end

        -- Deck 1 floor (y = 5)
        for x = -hw + 1, hw - 1 do
            set_vox(ox + x, oy + 5, world_z, c_deck_wood)
            -- Recessed ceiling lights for Deck 0
            if (z % 8 == 0) and (x == 0 or math.abs(x) == 5) then
                set_vox(ox + x, oy + 4, world_z, c_led)
            end
        end

        -- Deck 2 floor (y = 10)
        for x = -hw + 1, hw - 1 do
            set_vox(ox + x, oy + 10, world_z, c_deck_wood)
            -- Recessed ceiling lights for Deck 1
            if (z % 8 == 0) and (x == 0 or math.abs(x) == 6) then
                set_vox(ox + x, oy + 9, world_z, c_led)
            end
        end

        -- Deck 3 floor / Sun Deck (y = 15)
        for x = -hw + 1, hw - 1 do
            set_vox(ox + x, oy + 15, world_z, c_deck_wood)
            -- Recessed ceiling lights for Deck 2
            if (z % 8 == 0) and (x == 0 or math.abs(x) == 6) then
                set_vox(ox + x, oy + 14, world_z, c_led)
            end
        end
    end

    -- 3. Deck 0: Entry Foyer, Boarding Portal & Gangway Threshold
    -- Gangway doors at port (-X) and starboard (+X) and central lobby
    local foyer_z = -20
    for z = foyer_z - 6, foyer_z + 6 do
        for x = -6, 6 do
            -- Elegant carpeted welcome foyer
            set_vox(ox + x, oy, oz + z, c_carpet)
        end
    end
    -- Port side gangway portal door
    set_vox(ox - 13, oy + 1, oz + foyer_z, c_portal)
    set_vox(ox - 13, oy + 2, oz + foyer_z, c_portal)
    set_vox(ox - 13, oy + 3, oz + foyer_z, c_led)
    -- Starboard side gangway portal door
    set_vox(ox + 13, oy + 1, oz + foyer_z, c_portal)
    set_vox(ox + 13, oy + 2, oz + foyer_z, c_portal)
    set_vox(ox + 13, oy + 3, oz + foyer_z, c_led)

    -- 4. Grand Multi-Deck Atrium (z = -10 to +25)
    -- Central opening linking Deck 0, Deck 1, and Deck 2 with glass railing and stairs
    for z = -5, 20 do
        for x = -4, 4 do
            -- Cut out central lightwell
            set_vox(ox + x, oy + 5, oz + z, c_air)
            set_vox(ox + x, oy + 10, oz + z, c_air)
        end
        -- Glass railings around the open atrium void
        set_vox(ox - 4, oy + 6, oz + z, c_railing, 0)
        set_vox(ox + 4, oy + 6, oz + z, c_railing, 2)
        set_vox(ox - 4, oy + 11, oz + z, c_railing, 0)
        set_vox(ox + 4, oy + 11, oz + z, c_railing, 2)
    end
    -- Atrium end railings
    for x = -4, 4 do
        set_vox(ox + x, oy + 6, oz - 5, c_railing, 1)
        set_vox(ox + x, oy + 6, oz + 20, c_railing, 3)
        set_vox(ox + x, oy + 11, oz - 5, c_railing, 1)
        set_vox(ox + x, oy + 11, oz + 20, c_railing, 3)
    end

    -- Grand Atrium Central Staircases
    -- Stair 1: Deck 0 to Deck 1 (y = 1 to 5)
    for step = 0, 4 do
        local sz = oz + step + 1
        for sx = -1, 1 do
            for sy = 1, step + 1 do
                set_vox(ox + sx, oy + sy, sz, c_wood)
            end
        end
    end
    -- Stair 2: Deck 1 to Deck 2 (y = 6 to 10)
    for step = 0, 4 do
        local sz = oz + 15 - step
        for sx = -1, 1 do
            for sy = 6, 6 + step do
                set_vox(ox + sx, oy + sy, sz, c_wood)
            end
        end
    end

    -- 5. Deck 1: Passenger Cabins & Luxury Staterooms (z = 30 to 80 and z = -85 to -30)
    -- Layout: Central corridor (x = -2 to +2), Port & Starboard cabins with private balcony windows
    local function build_cabin(cz, is_starboard)
        local sign = is_starboard and 1 or -1
        local hw = get_hull_half_width(cz)
        local x_in = sign * 3
        local x_out = sign * (hw - 1)
        local x_start = math.min(x_in, x_out)
        local x_end = math.max(x_in, x_out)

        -- Carpet flooring
        for z = cz, cz + 4 do
            for x = x_start, x_end do
                set_vox(ox + x, oy + 5, oz + z, c_carpet)
            end
        end

        -- Partition walls
        for y = 6, 9 do
            for x = x_start, x_end do
                set_vox(ox + x, oy + y, oz + cz, c_interior_wall)
                set_vox(ox + x, oy + y, oz + cz + 4, c_interior_wall)
            end
            -- Corridor wall with doorway
            for z = cz, cz + 4 do
                if z ~= cz + 2 then
                    set_vox(ox + sign * 3, oy + y, oz + z, c_interior_wall)
                else
                    set_vox(ox + sign * 3, oy + y, oz + z, c_air) -- Door opening
                end
            end
            -- Exterior ocean balcony window
            for z = cz + 1, cz + 3 do
                set_vox(ox + sign * hw, oy + y, oz + z, c_glass)
            end
        end

        -- Stateroom Furniture: Luxury Bed, Nightstand Chest, Table
        local bed_x = sign * (hw - 2)
        set_vox(ox + bed_x, oy + 6, oz + cz + 1, c_bed)
        set_vox(ox + bed_x, oy + 6, oz + cz + 2, c_chest)
        set_vox(ox + sign * 4, oy + 6, oz + cz + 3, c_sofa)
        set_vox(ox + sign * 6, oy + 9, oz + cz + 2, c_led) -- Ceiling lamp
    end

    -- Generate staterooms along the corridors
    for z = 30, 75, 5 do
        build_cabin(z, false) -- Port
        build_cabin(z, true)  -- Starboard
    end
    for z = -85, -35, 5 do
        build_cabin(z, false)
        build_cabin(z, true)
    end

    -- 6. Deck 2: Ocean Promenade & Panoramic Dining Salon (z = -70 to +65)
    -- Wide scenic windows along the entire hull
    for z = -70, 65 do
        local hw = get_hull_half_width(z)
        -- Ocean panoramic windows
        for y = 11, 14 do
            set_vox(ox - hw, oy + y, oz + z, c_glass)
            set_vox(ox + hw, oy + y, oz + z, c_glass)
        end

        -- Dining tables and luxury seating
        if (z % 6 == 0) and math.abs(z) > 10 then
            -- Dining table
            set_vox(ox - 8, oy + 11, oz + z, c_wood)
            set_vox(ox - 8, oy + 11, oz + z - 1, c_sofa, 0)
            set_vox(ox - 8, oy + 11, oz + z + 1, c_sofa, 2)

            set_vox(ox + 8, oy + 11, oz + z, c_wood)
            set_vox(ox + 8, oy + 11, oz + z - 1, c_sofa, 0)
            set_vox(ox + 8, oy + 11, oz + z + 1, c_sofa, 2)
        end
    end

    -- 7. Deck 3: Open-Air Sun / Lido Deck (y = 15)
    -- Safety perimeter railings around the entire sun deck
    for z = -90, 85 do
        local hw = get_hull_half_width(z)
        set_vox(ox - hw, oy + 16, oz + z, c_railing, 0)
        set_vox(ox + hw, oy + 16, oz + z, c_railing, 2)
    end
    for x = -get_hull_half_width(-90), get_hull_half_width(-90) do
        set_vox(ox + x, oy + 16, oz - 90, c_railing, 1)
    end

    -- Heated Infinity Swimming Pool (z = -15 to +15, x = -6 to +6, y = 14 to 15)
    for z = -12, 12 do
        for x = -5, 5 do
            -- Pool basin
            set_vox(ox + x, oy + 14, oz + z, c_pool_tile)
            set_vox(ox + x, oy + 15, oz + z, c_pool_water)
        end
        -- Pool edge border
        set_vox(ox - 6, oy + 15, oz + z, c_pool_tile)
        set_vox(ox + 6, oy + 15, oz + z, c_pool_tile)
    end
    for x = -6, 6 do
        set_vox(ox + x, oy + 15, oz - 13, c_pool_tile)
        set_vox(ox + x, oy + 15, oz + 13, c_pool_tile)
    end

    -- Lido Sun Deck Loungers around the pool
    for z = -20, 20, 4 do
        if math.abs(z) > 13 then
            set_vox(ox - 8, oy + 16, oz + z, c_chair, 0)
            set_vox(ox - 10, oy + 16, oz + z, c_chair, 0)
            set_vox(ox + 8, oy + 16, oz + z, c_chair, 2)
            set_vox(ox + 10, oy + 16, oz + z, c_chair, 2)
        end
    end

    -- Twin Signature Aerodynamic Funnels (z = -35 and z = -55)
    local function build_funnel(fz)
        for y = 16, 26 do
            for z = fz - 4, fz + 4 do
                for x = -3, 3 do
                    local is_outer = (x == -3 or x == 3 or z == fz - 4 or z == fz + 4)
                    if is_outer then
                        set_vox(ox + x, oy + y, oz + z, c_hull_wall)
                    else
                        set_vox(ox + x, oy + y, oz + z, c_air)
                    end
                end
            end
        end
        -- Funnel top trim
        for z = fz - 4, fz + 4 do
            for x = -3, 3 do
                set_vox(ox + x, oy + 26, oz + z, c_led)
            end
        end
    end

    build_funnel(-35)
    build_funnel(-55)

    -- 8. Command Bridge & Wheelhouse (z = 60 to 75, y = 19 to 24)
    -- Forward elevated bridge with 270-degree panoramic ocean views
    for z = 60, 75 do
        for x = -9, 9 do
            -- Bridge floor
            set_vox(ox + x, oy + 19, oz + z, c_carpet)
            -- Bridge roof
            set_vox(ox + x, oy + 24, oz + z, c_hull_wall)
            if (z % 4 == 0) and (x % 4 == 0) then
                set_vox(ox + x, oy + 24, oz + z, c_led)
            end

            -- Bridge walls / Panoramic windows
            for y = 20, 23 do
                local is_forward = (z == 75)
                local is_side = (x == -9 or x == 9)
                local is_back = (z == 60)

                if is_forward or (is_side and z > 64) then
                    set_vox(ox + x, oy + y, oz + z, c_glass)
                elseif is_side or is_back then
                    if is_back and math.abs(x) <= 1 then
                        set_vox(ox + x, oy + y, oz + z, c_air) -- Bridge entrance doorway
                    else
                        set_vox(ox + x, oy + y, oz + z, c_hull_wall)
                    end
                else
                    set_vox(ox + x, oy + y, oz + z, c_air)
                end
            end
        end
    end

    -- Bridge Control Consoles: Steering Wheel & Engine Telegraph
    -- Placed at center forward position (x=0, z=73, y=20)
    set_vox(ox - 1, oy + 20, oz + 73, c_wheel, 0)
    set_vox(ox + 1, oy + 20, oz + 73, c_telegraph, 0)

    -- Stair access from Sun Deck (Deck 3) up to Command Bridge
    for step = 0, 3 do
        local bz = oz + 56 + step
        for bx = -1, 1 do
            for by = 16, 16 + step do
                set_vox(ox + bx, oy + by, bz, c_wood)
            end
        end
    end

    -- Write all voxel manipulator data back to map
    manip:set_data(data)
    manip:set_param2_data(param2_data)
    manip:write_to_map()
    manip:update_map()

    -- Set NodeMeta on Bridge Controllers
    local wheel_pos = {x = ox - 1, y = oy + 20, z = oz + 73}
    local telegraph_pos = {x = ox + 1, y = oy + 20, z = oz + 73}
    local portal_port = {x = ox - 13, y = oy + 1, z = oz + foyer_z}
    local portal_starboard = {x = ox + 13, y = oy + 1, z = oz + foyer_z}

    local meta_wheel = minetest.get_meta(wheel_pos)
    meta_wheel:set_string("ship_id", ship_id)
    meta_wheel:set_string("infotext", "Cruise Ship Steering Wheel [" .. ship_id .. "]")

    local meta_tele = minetest.get_meta(telegraph_pos)
    meta_tele:set_string("ship_id", ship_id)
    meta_tele:set_string("infotext", "Cruise Ship Engine Telegraph [" .. ship_id .. "]")

    local meta_p1 = minetest.get_meta(portal_port)
    meta_p1:set_string("ship_id", ship_id)
    meta_p1:set_string("infotext", "Gangway Exit (Port) [" .. ship_id .. "]")

    local meta_p2 = minetest.get_meta(portal_starboard)
    meta_p2:set_string("ship_id", ship_id)
    meta_p2:set_string("infotext", "Gangway Exit (Starboard) [" .. ship_id .. "]")

    minetest.log("action", "[cruiseship] 200m luxury interior generated successfully for ship: " .. ship_id .. " in slot " .. slot_index)
end
