-- Modern Luxury Cruise Ship Interior & Exterior Nodes

local S = function(s) return s end

-- 1. Luxury Teak Deck Wood
minetest.register_node("cruiseship:deck_wood", {
    description = S("Cruise Liner Luxury Teak Deck"),
    tiles = {"cruiseship_deck_wood.png"},
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
    sounds = cruiseship.compat.get_sound("sound_wood"),
})

-- 2. Modern Hull Composite Wall
minetest.register_node("cruiseship:hull_wall", {
    description = S("Cruise Liner Reinforced Hull Panel"),
    tiles = {"cruiseship_hull_wall.png"},
    groups = {cracky = 1, level = 2},
    sounds = cruiseship.compat.get_sound("sound_metal"),
})

-- 3. Stateroom Interior Wall (clean luxury composite)
minetest.register_node("cruiseship:interior_wall", {
    description = S("Cruise Liner Stateroom Wall Panel"),
    tiles = {"cruiseship_interior_wall.png"},
    groups = {cracky = 2, oddly_breakable_by_hand = 1},
    sounds = cruiseship.compat.get_sound("sound_wood"),
})

-- 4. Luxury Stateroom Carpet
minetest.register_node("cruiseship:stateroom_carpet", {
    description = S("Cruise Liner Luxury Stateroom Carpet"),
    tiles = {"cruiseship_stateroom_carpet.png"},
    groups = {snappy = 3, flammable = 3, wool = 1},
    sounds = cruiseship.compat.get_sound("sound_wood"),
})

-- 5. Panoramic Floor-to-Ceiling Tinted Glass
minetest.register_node("cruiseship:panoramic_glass", {
    description = S("Cruise Liner Panoramic Observation Glass"),
    drawtype = "glasslike",
    tiles = {"cruiseship_panoramic_glass.png"},
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    groups = {cracky = 3, oddly_breakable_by_hand = 3},
    sounds = cruiseship.compat.get_sound("sound_glass"),
})

-- 6. Modern Balcony Glass Railing
minetest.register_node("cruiseship:glass_railing", {
    description = S("Cruise Liner Modern Glass Railing"),
    drawtype = "nodebox",
    tiles = {"cruiseship_glass_railing.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    use_texture_alpha = "blend",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}, -- glass panel & frame
        },
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5},
        },
    },
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.4, 0.5, 0.8, 0.5}, -- slightly higher collision to prevent falling overboard
        },
    },
    groups = {cracky = 3, oddly_breakable_by_hand = 2},
    sounds = cruiseship.compat.get_sound("sound_glass"),
})

-- 7. Warm Recessed Modern LED Ceiling Light
minetest.register_node("cruiseship:led_ceiling_panel", {
    description = S("Cruise Liner Recessed LED Ceiling Light"),
    tiles = {"cruiseship_led_ceiling_panel.png"},
    paramtype = "light",
    light_source = 14,
    groups = {cracky = 3, oddly_breakable_by_hand = 3},
    sounds = cruiseship.compat.get_sound("sound_glass"),
})

-- 8. Lido Deck Infinity Pool Azure Tile
minetest.register_node("cruiseship:pool_tile", {
    description = S("Cruise Liner Lido Pool Mosaic Tile"),
    tiles = {"cruiseship_pool_tile.png"},
    groups = {cracky = 2},
    sounds = cruiseship.compat.get_sound("sound_metal"),
})

-- 9. Lido Deck Pool Water (Crystal Clear Heated Water)
minetest.register_node("cruiseship:pool_water", {
    description = S("Cruise Liner Heated Pool Water"),
    drawtype = "liquid",
    tiles = {
        {
            name = "cruiseship_pool_tile.png^[colorize:#2090ff:120",
            backface_culling = false,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 2.0,
            },
        },
        {
            name = "cruiseship_pool_tile.png^[colorize:#2090ff:120",
            backface_culling = true,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 2.0,
            },
        },
    },
    use_texture_alpha = "blend",
    paramtype = "light",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    drowning = 1,
    liquidtype = "source",
    liquid_alternative_flowing = "cruiseship:pool_water",
    liquid_alternative_source = "cruiseship:pool_water",
    liquid_viscosity = 1,
    liquid_range = 0, -- static heated pool water
    post_effect_color = {a = 80, r = 30, g = 140, b = 230},
    groups = {water = 3, liquid = 3, cools_lava = 1},
})

-- 10. Modern Lounge Sofa
minetest.register_node("cruiseship:modern_sofa", {
    description = S("Cruise Liner Modern Lounge Sofa"),
    drawtype = "nodebox",
    tiles = {"cruiseship_sofa.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, -0.1, 0.5},   -- Seat cushion
            {-0.5, -0.1,  0.3, 0.5,  0.5, 0.5},   -- Backrest
            {-0.5, -0.1, -0.5,-0.3,  0.3, 0.3},   -- Left armrest
            { 0.3, -0.1, -0.5, 0.5,  0.3, 0.3},   -- Right armrest
        },
    },
    groups = {snappy = 2, oddly_breakable_by_hand = 2, flammable = 2},
    sounds = cruiseship.compat.get_sound("sound_wood"),
})

-- 11. Sun Lido Deck Lounger Chair
minetest.register_node("cruiseship:deck_chair", {
    description = S("Cruise Liner Sun Deck Lounger"),
    drawtype = "nodebox",
    tiles = {"cruiseship_deck_chair.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.4, -0.5, -0.5,  0.4, -0.2, 0.5},  -- Reclined pad
            {-0.4, -0.2,  0.2,  0.4,  0.3, 0.5},  -- Elevated headrest
            {-0.45, -0.5, -0.5, -0.35, -0.3, 0.5}, -- Left rail
            { 0.35, -0.5, -0.5,  0.45, -0.3, 0.5}, -- Right rail
        },
    },
    groups = {snappy = 2, oddly_breakable_by_hand = 2},
    sounds = cruiseship.compat.get_sound("sound_wood"),
})

-- 12. Bridge Command Steering Wheel
minetest.register_node("cruiseship:steering_wheel", {
    description = S("Cruise Liner Bridge Steering Wheel"),
    drawtype = "nodebox",
    tiles = {"cruiseship_steering_wheel.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.2, -0.5, -0.2,  0.2, 0.2, 0.2}, -- pedestal
            {-0.4,  0.0, -0.05, 0.4, 0.8, 0.05},-- helm wheel
        },
    },
    groups = {cracky = 2, oddly_breakable_by_hand = 1},
    sounds = cruiseship.compat.get_sound("sound_metal"),
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        cruiseship.bridge.show_helm_formspec(pos, clicker)
    end,
})

-- 13. Bridge Engine Telegraph
minetest.register_node("cruiseship:engine_telegraph", {
    description = S("Cruise Liner Bridge Engine Telegraph"),
    drawtype = "nodebox",
    tiles = {"cruiseship_engine_telegraph.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}, -- brass column
            {-0.3,   0.3, -0.15, 0.3,  0.8, 0.15}, -- telegraph dial
            {-0.05,  0.7, -0.1,  0.05, 1.0, 0.1},  -- throttle lever
        },
    },
    groups = {cracky = 2, oddly_breakable_by_hand = 1},
    sounds = cruiseship.compat.get_sound("sound_metal"),
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        cruiseship.bridge.show_telegraph_formspec(pos, clicker)
    end,
})

-- 14. Gangway Portal (Interior threshold to overworld ocean)
minetest.register_node("cruiseship:gangway_portal_interior", {
    description = S("Cruise Liner Gangway Exit (To Ocean Vessel)"),
    drawtype = "glasslike",
    tiles = {"cruiseship_gangway_door.png"},
    paramtype = "light",
    light_source = 8,
    walkable = false,
    use_texture_alpha = "blend",
    groups = {cracky = 3, oddly_breakable_by_hand = 3},
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        cruiseship.teleport.exit_to_overworld(pos, clicker)
    end,
})

-- 15. The Cruise Ship Deployer Item
minetest.register_craftitem("cruiseship:ship_item", {
    description = S("Modern Cruise Liner (200m Luxury Vessel)\nRight-click on ocean water to deploy"),
    inventory_image = "cruiseship_ship_item.png",
    wield_image = "cruiseship_ship_item.png",
    stack_max = 1,
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end
        local pos = pointed_thing.above
        local node_under = minetest.get_node(pointed_thing.under)
        -- Can be deployed on water or near sea level
        local success, msg_or_id = cruiseship.spawn_cruise_liner(pos, placer:get_look_horizontal())
        if success then
            minetest.chat_send_player(placer:get_player_name(), "Cruise liner deployed! Use the gangway or bridge to navigate.")
            itemstack:take_item()
            return itemstack
        else
            minetest.chat_send_player(placer:get_player_name(), "Could not deploy ship: " .. tostring(msg_or_id))
            return itemstack
        end
    end,
})

-- 16. Cruise Liner Spawn Egg
minetest.register_craftitem("cruiseship:spawn_egg", {
    description = S("Cruise Liner Spawn Egg\nRight-click on ocean water or surface to commission 200m Cruise Ship"),
    inventory_image = "cruiseship_spawn_egg.png",
    wield_image = "cruiseship_spawn_egg.png",
    stack_max = 64,
    groups = {spawn_egg = 1},
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end
        local pos = pointed_thing.above
        local success, msg_or_id = cruiseship.spawn_cruise_liner(pos, placer:get_look_horizontal())
        if success then
            minetest.chat_send_player(placer:get_player_name(), "Cruise liner commissioned! Ship ID: " .. tostring(msg_or_id))
            if not minetest.is_creative_enabled or not minetest.is_creative_enabled(placer:get_player_name()) then
                itemstack:take_item()
            end
            return itemstack
        else
            minetest.chat_send_player(placer:get_player_name(), "Could not spawn ship: " .. tostring(msg_or_id))
            return itemstack
        end
    end,
})
