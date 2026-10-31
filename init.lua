-- Luanti Cruise Liner ("Pocket Dimension" Architecture)
-- Modern Walkable 200m Cruise Ship Mod for Luanti / Minetest 5.x+
-- Compatible with Minetest Game, Mineclonia, and VoxeLibre

cruiseship = {}
cruiseship.modpath = minetest.get_modpath("cruiseship") or minetest.get_modpath(minetest.get_current_modname())

-- Compatibility layer for Minetest Game / Mineclonia / VoxeLibre
cruiseship.compat = {}

-- Detect game environment safely
if minetest.get_modpath("mcl_core") then
    cruiseship.compat.game = "mineclonia"
    cruiseship.compat.node_wood = "mcl_core:wood"
    cruiseship.compat.node_chest = "mcl_chests:chest"
    cruiseship.compat.node_bed = "mcl_beds:bed_red"
    cruiseship.compat.node_furnace = "mcl_furnaces:furnace"
    cruiseship.compat.sound_wood = rawget(_G, "mcl_sounds") and mcl_sounds.node_sound_wood_defaults and mcl_sounds.node_sound_wood_defaults() or nil
    cruiseship.compat.sound_glass = rawget(_G, "mcl_sounds") and mcl_sounds.node_sound_glass_defaults and mcl_sounds.node_sound_glass_defaults() or nil
    cruiseship.compat.sound_metal = rawget(_G, "mcl_sounds") and mcl_sounds.node_sound_metal_defaults and mcl_sounds.node_sound_metal_defaults() or nil
elseif minetest.get_modpath("default") then
    cruiseship.compat.game = "minetest_game"
    cruiseship.compat.node_wood = "default:wood"
    cruiseship.compat.node_chest = "default:chest"
    cruiseship.compat.node_bed = (minetest.registered_nodes and minetest.registered_nodes["beds:bed"]) and "beds:bed" or "default:wood"
    cruiseship.compat.node_furnace = "default:furnace"
    cruiseship.compat.sound_wood = rawget(_G, "default") and default.node_sound_wood_defaults and default.node_sound_wood_defaults() or nil
    cruiseship.compat.sound_glass = rawget(_G, "default") and default.node_sound_glass_defaults and default.node_sound_glass_defaults() or nil
    cruiseship.compat.sound_metal = rawget(_G, "default") and default.node_sound_metal_defaults and default.node_sound_metal_defaults() or nil
else
    -- Minimal standalone / fallback environment (e.g. devtest or custom minimal game)
    cruiseship.compat.game = "standalone"
    cruiseship.compat.node_wood = "cruiseship:deck_wood"
    cruiseship.compat.node_chest = "cruiseship:deck_wood"
    cruiseship.compat.node_bed = "cruiseship:deck_wood"
    cruiseship.compat.node_furnace = "cruiseship:deck_wood"
    cruiseship.compat.sound_wood = nil
    cruiseship.compat.sound_glass = nil
    cruiseship.compat.sound_metal = nil
end

-- Helper safe fallback for sounds
function cruiseship.compat.get_sound(key)
    return cruiseship.compat[key] or {}
end

-- Load modules
dofile(cruiseship.modpath .. "/lua/storage.lua")
dofile(cruiseship.modpath .. "/lua/nodes.lua")
dofile(cruiseship.modpath .. "/lua/generator.lua")
dofile(cruiseship.modpath .. "/lua/entity.lua")
dofile(cruiseship.modpath .. "/lua/bridge.lua")
dofile(cruiseship.modpath .. "/lua/teleport.lua")
dofile(cruiseship.modpath .. "/lua/cleanup.lua")
dofile(cruiseship.modpath .. "/lua/commands.lua")

minetest.log("action", "[cruiseship] Luanti Cruise Liner mod loaded successfully! Running on: " .. cruiseship.compat.game)
