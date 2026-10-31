-- Exterior Moving Vessel Entity & Physics Navigation
-- Represents the moving vessel in the ocean overworld.
-- Calibrated to ~200 blocks in length.

cruiseship.entity = {}

-- Speeds in m/s:
-- Reverse: -3.0
-- Stop: 0.0
-- Slow: 3.5
-- Half: 7.0
-- Full: 12.0
cruiseship.SPEED_REVERSE = -3.0
cruiseship.SPEED_STOP = 0.0
cruiseship.SPEED_SLOW = 3.5
cruiseship.SPEED_HALF = 7.0
cruiseship.SPEED_FULL = 12.0

-- Registry of active loaded Lua entity references in world
cruiseship.active_entities = {}

-- Helper to calculate forward unit vector from Luanti yaw
-- In Minetest, yaw=0 points towards +Z, pi/2 towards -X, pi towards -Z, 3pi/2 towards +X
local function yaw_to_dir(yaw)
    return {
        x = -math.sin(yaw),
        y = 0,
        z = math.cos(yaw),
    }
end

-- Obstacle scanning function: scans ahead of the bow
local function scan_obstacles_ahead(pos, yaw, speed)
    if speed <= 0 then return false end

    -- Calibrated bow position: ship is ~200 blocks long, entity center is at midships,
    -- so bow is ~90-100 blocks forward (+dir)
    local dir = yaw_to_dir(yaw)
    local bow_dist = 95
    local scan_reach = 25 -- scan 25 blocks beyond bow
    local scan_step = 5

    for d = bow_dist, bow_dist + scan_reach, scan_step do
        local check_pos = {
            x = math.floor(pos.x + dir.x * d),
            y = math.floor(pos.y),
            z = math.floor(pos.z + dir.z * d),
        }

        -- Check surface and 1 node below surface
        for dy = -1, 1 do
            local test_pos = {x = check_pos.x, y = check_pos.y + dy, z = check_pos.z}
            local node = minetest.get_node_or_nil(test_pos)
            if node and node.name ~= "air" and node.name ~= "ignore" then
                local def = minetest.registered_nodes[node.name]
                if def and def.walkable and not def.liquidtype then
                    -- Solid terrain, ice, or obstacle detected!
                    return true, test_pos, node.name
                end
            end
        end
    end

    return false
end

minetest.register_entity("cruiseship:exterior_vessel", {
    initial_properties = {
        visual = "mesh",
        mesh = "cruiseship.obj",
        textures = {
            "cruiseship_texture.png",
            "cruiseship_texture.png",
            "cruiseship_texture.png",
        },
        -- Visual scale calibrated so 18 units mesh length = ~200 blocks in world
        -- 200 / 18.046 ≈ 11.08
        visual_size = {x = 11.0, y = 11.0, z = 11.0},
        physical = true,
        collide_with_objects = true,
        collisionbox = {-14, -3, -95, 14, 15, 95},
        selectionbox = {-15, -3, -95, 15, 20, 95},
        pointable = true,
        static_save = true,
        glow = 3,
    },

    ship_id = nil,
    current_speed = 0,
    target_yaw = 0,
    timer = 0,
    sound_timer = 0,
    wave_sound_handle = nil,

    on_activate = function(self, staticdata, dtime_s)
        self.object:set_armor_groups({immortal = 1})

        if staticdata and staticdata ~= "" then
            local data = minetest.parse_json(staticdata)
            if type(data) == "table" and data.ship_id then
                self.ship_id = data.ship_id
                self.current_speed = data.current_speed or 0
                self.target_yaw = data.target_yaw or 0
                if data.target_yaw then
                    self.object:set_yaw(data.target_yaw)
                end
            end
        end

        if self.ship_id then
            cruiseship.active_entities[self.ship_id] = self
        end
    end,

    get_staticdata = function(self)
        return minetest.write_json({
            ship_id = self.ship_id,
            current_speed = self.current_speed,
            target_yaw = self.target_yaw,
        })
    end,

    on_step = function(self, dtime)
        self.timer = self.timer + dtime
        self.sound_timer = self.sound_timer + dtime

        local pos = self.object:get_pos()
        if not pos then return end

        local yaw = self.object:get_yaw() or 0

        -- 1. Smooth Yaw Interpolation
        if self.target_yaw and math.abs(self.target_yaw - yaw) > 0.005 then
            -- Normalize angle difference
            local diff = (self.target_yaw - yaw)
            while diff > math.pi do diff = diff - 2 * math.pi end
            while diff < -math.pi do diff = diff + 2 * math.pi end

            local turn_rate = 0.25 * dtime -- realistic turning inertia for 200m vessel
            if math.abs(diff) < turn_rate then
                yaw = self.target_yaw
            else
                yaw = yaw + (diff > 0 and turn_rate or -turn_rate)
            end
            self.object:set_yaw(yaw)
        end

        -- 2. Obstacle Scanning (every 0.5s)
        if self.timer >= 0.5 then
            self.timer = 0

            if self.current_speed > 0 then
                local obstacle_found, obst_pos, obst_name = scan_obstacles_ahead(pos, yaw, self.current_speed)
                if obstacle_found then
                    -- Emergency All Stop & Sound Horn
                    self.current_speed = 0
                    self.object:set_velocity({x = 0, y = 0, z = 0})
                    minetest.sound_play("rms_menotics_horn", {
                        pos = pos,
                        gain = 1.0,
                        max_hear_distance = 250,
                    })
                    minetest.chat_send_all("[Cruise Ship " .. tostring(self.ship_id) .. "] Obstacle detected ahead (" .. tostring(obst_name) .. ")! Emergency Stop executed and steam horn sounded.")
                end
            end

            -- Update storage with current overworld position & yaw
            if self.ship_id then
                cruiseship.storage.update_ship(self.ship_id, {
                    exterior_pos = pos,
                    exterior_yaw = yaw,
                    speed = self.current_speed,
                    target_yaw = self.target_yaw,
                })
            end
        end

        -- 3. Velocity and Buoyancy physics
        -- Keep vessel stabilized at sea level (water surface)
        local dir = yaw_to_dir(yaw)
        local target_vx = dir.x * self.current_speed
        local target_vz = dir.z * self.current_speed

        -- Slight vertical stabilization
        local current_vel = self.object:get_velocity() or {x = 0, y = 0, z = 0}
        local vy = 0
        local water_node = minetest.get_node_or_nil(pos)
        if water_node and water_node.name and string.find(water_node.name, "water") then
            -- Gently float towards surface
            vy = 0.5
        elseif pos.y < 0.5 then
            vy = 0.2
        end

        self.object:set_velocity({
            x = target_vx,
            y = vy,
            z = target_vz,
        })

        -- 4. Ambient ocean wave sounds when in motion
        if self.sound_timer >= 6.0 and math.abs(self.current_speed) > 0.5 then
            self.sound_timer = 0
            minetest.sound_play("cruiseship_waves", {
                pos = pos,
                gain = 0.6,
                max_hear_distance = 120,
            })
        end
    end,

    on_rightclick = function(self, clicker)
        if not clicker or not clicker:is_player() then return end
        if not self.ship_id then return end

        -- Seamless Boarding Portal: teleport into ship's sky interior
        cruiseship.teleport.board_ship(self.ship_id, clicker)
    end,

    on_punch = function(self, puncher)
        if not puncher or not puncher:is_player() then return end
        local player_name = puncher:get_player_name()

        -- Allow dismantling with confirmation or bridge console
        minetest.chat_send_player(player_name, "To steer or dismantle Cruise Liner [" .. tostring(self.ship_id) .. "], board via right-click and proceed to the forward Command Bridge.")
    end,
})

-- Central Ship Spawner
function cruiseship.spawn_cruise_liner(pos, yaw)
    local ship_id = "ship_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))

    -- 1. Allocate Sky Dimension Slot
    local slot_index = cruiseship.storage.allocate_slot(ship_id)
    if not slot_index then
        return false, "No sky realm slots available!"
    end

    -- 2. Generate 200m Walkable Sky Interior
    cruiseship.generator.generate(ship_id, slot_index)

    -- 3. Spawn Exterior Moving Entity in Overworld
    local ent_pos = {x = pos.x, y = pos.y, z = pos.z}
    local staticdata = minetest.write_json({
        ship_id = ship_id,
        current_speed = 0,
        target_yaw = yaw or 0,
    })

    local obj = minetest.add_entity(ent_pos, "cruiseship:exterior_vessel", staticdata)
    if not obj then
        cruiseship.storage.free_slot(ship_id)
        return false, "Failed to spawn exterior vessel entity!"
    end

    obj:set_yaw(yaw or 0)

    -- 4. Register in Persistent Storage
    cruiseship.storage.register_ship(ship_id, slot_index, ent_pos, yaw or 0)

    -- Blow welcoming horn on ship commissioning
    minetest.sound_play("rms_menotics_horn", {
        pos = ent_pos,
        gain = 1.0,
        max_hear_distance = 300,
    })

    return true, ship_id
end
