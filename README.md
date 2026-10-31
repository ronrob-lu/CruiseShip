# 🚢 Luanti Cruise Liner: 200m Luxury Walkable Ocean Vessel
### *The Ultimate High-Seas Luxury Experience for Luanti & Minetest*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
[![Engine: Luanti / Minetest 5.x+](https://img.shields.io/badge/Luanti-5.x+-00d2ff.svg)](https://www.luanti.org)
[![Compatibility: Universal](https://img.shields.io/badge/Compatibility-Minetest%20Game%20%7C%20Mineclonia%20%7C%20VoxeLibre-brightgreen.svg)](#cross-game-compatibility)

---

## 🌊 Welcome Aboard the Crown Jewel of the Ocean

Transform your voxel world into a world-class luxury destination! The **Luanti Cruise Liner** mod brings an unprecedented, **200-meter fully walkable modern cruise ship** to Luanti (formerly Minetest).

Engineered with revolutionary **"Dual-Plane Pocket Dimension"** architecture, you can now experience full-speed ocean navigation and unrestricted multi-deck exploration—**with zero lag, zero entity-desync, and zero falling through blocks**.

Whether you're running a bustling multiplayer vacation resort, embarking on grand server voyages, or commandeering the helm from the high-tech navigation bridge, this mod sets a whole new benchmark for maritime adventure in block-based gaming.

---

## ✨ Standout Features

### 🌟 Revolutionary Pocket Dimension Architecture
- **Dual-Plane Simulation**: An elegant 200m exterior 3D hull cuts through the real ocean waves, while the entire 5-deck, fully decorated luxury interior is housed within a dedicated Sky Realm coordinate slot ($Y = 25,000$).
- **Lag-Free Multiplayer Stability**: Walk, jump, relax, decorate staterooms, and explore at full cruising speed without rubber-banding or collision clipping!
- **Seamless Boarding & Disembarking**: Walk up to the ocean vessel and right-click to instantly step through the grand foyer. When you're ready to leave, exit through either port or starboard gangway doors to arrive back in the ocean at the ship's live real-world coordinates and heading.

### ⚓ 5 Expansive, Fully Walkable Decks
Every meter of this 200m luxury vessel has been intricately designed and procedurally populated with custom blocks, furniture, and amenities:
1. **Deck 0 (Foyer & Keel)**: Welcoming boarding foyer, grand entrance carpets, and twin port/starboard ocean gangway access portals.
2. **Deck 1 (Staterooms & Grand Atrium)**: Elegant private passenger cabins outfitted with double beds, personal storage lockers, lounge chairs, warm recessed lighting, and floor-to-ceiling ocean-view balcony windows.
3. **Deck 2 (Ocean Promenade & Dining Salon)**: Sweeping panoramic glass observation decks, luxury leather sofas, and an oceanfront dining salon overlooking the open waters.
4. **Deck 3 (Open-Air Lido & Sun Deck)**: Heated infinity swimming pool with sparkling azure mosaic tiling, loungers, full-perimeter modern glass safety railings, and iconic aerodynamic twin cruise funnels.
5. **Deck 4 (Command Bridge & Wheelhouse)**: Forward elevated 270° bridge station with brass engine telegraphs, functional ship's steering helm, and panoramic forward ocean visibility.

### 🎮 Interactive Navigation Controls
Take direct command of your 200-meter flagship right from the bridge console:
- **Engine Order Telegraph**:
  - `FULL AHEAD` (12 m/s – Maximum Cruising Speed)
  - `HALF AHEAD` (7 m/s – Harbor Cruising)
  - `SLOW AHEAD` (3.5 m/s – Precision Maneuvering)
  - `ALL STOP` (0 m/s – Idle & Anchored)
  - `FULL ASTERN` (-3 m/s – Reverse Propulsion)
- **Precision Helm Steering**:
  - Incremental rudder adjustments: Port/Starboard 10° or 30°
  - Rudder Amidships quick-align (0° True North)
  - Realistic maritime turning inertia and smooth yaw interpolation
- **Atmospheric Soundscapes & Steam Horn**:
  - Blast the resonant steam horn to signal departures or navigate heavy fog.
  - Realistic humming propulsion engines and ambient ocean wake audio.

### 🛡️ Smart Sonar & Obstacle Collision Avoidance
- **Automated Bow Sonar**: Active forward scanning detects approaching shorelines, solid terrain, and reefs up to 120 meters out.
- **Emergency All-Stop Protocol**: If an imminent collision is detected, the engine instantly disengages to full stop and sounds the emergency steam horn, protecting your ship from beaching.

### 📦 Smart Decommissioning & Zero-Loss Cargo Safety
- Need to reposition or store your ship? Use the bridge telegraph to safely dismantle the vessel.
- **Cargo-Safe Scanner**: All passenger chests, furnaces, stateroom inventories, and luggage are safely preserved and returned onto the ocean surface alongside your reusable ship deployer item.

---

## 🧭 Multi-Deck Layout Guide

```
                         [ COMMAND BRIDGE & RADAR ]
                                 (Deck 4)
                                    |
  [ TWIN FUNNELS ]        [ HEATED INFINITY POOL ]       [ SUN LOUNGERS ]
========================================================================== (Deck 3: Sun Deck)
  [ PANORAMIC DINING SALON ]     [ MULTI-DECK ATRIUM ]   [ PROMENADE ]
========================================================================== (Deck 2: Promenade)
  [ STATEROOMS (STBD) ]          [ OPEN VOID & RAILS ]   [ STATEROOMS (PORT) ]
========================================================================== (Deck 1: Staterooms)
  [ GANGWAY PORTAL ]             [ GRAND ENTRANCE ]      [ GANGWAY PORTAL ]
========================================================================== (Deck 0: Foyer)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ OCEAN SURFACE ] ~~~~~~~~~~~~~~~~~~~~~~~~
```

---

## 🚀 Getting Started

### 1. Commissioning Your Vessel
There are three convenient ways to launch your cruise liner:

1. **Cruise Liner Deployer Item (`cruiseship:ship_item`)**:
   - Hold the item in your hand and right-click on any ocean water surface.
   - The vessel will deploy facing your look direction.
2. **Spawn Egg (`cruiseship:spawn_egg`)**:
   - Great for creative mode and server admins. Right-click any water node to commission a ship.
3. **Chat Command**:
   - `/spawn_cruise_ship` (requires `server` privilege).

### 2. Boarding the Ship
- Approach the exterior vessel in the ocean.
- **Right-click the ship's hull**: You will be immediately welcomed aboard in the Deck 0 foyer!

### 3. Commanding the Ship
1. Head up the central atrium staircases to **Deck 4 (Command Bridge)**.
2. **Right-click the Steering Wheel** to open the Navigation Helm formspec:
   - Steer Port or Starboard.
   - Check your current digital heading in degrees.
   - Blow the steam horn!
3. **Right-click the Engine Telegraph** to set engine speed:
   - Select Slow, Half, or Full Ahead.
   - Your vessel in the ocean will smoothly accelerate, creating realistic ocean waves!

### 4. Disembarking
- Walk to either the **Port** (left) or **Starboard** (right) gangway doors on Deck 0.
- Right-click the gangway portal. You will seamlessly materialize back in the overworld right by the ship's hull at its updated ocean location.

---

## 🛠️ Chat Commands Reference

| Command | Privileges | Description |
| :--- | :--- | :--- |
| `/spawn_cruise_ship` | `server` | Spawns a 200m luxury cruise liner at your current position and orientation. |
| `/list_cruise_ships` | `server` | Displays all active vessels, slot allocations, speeds, and coordinates. |
| `/tp_cruise_ship [ship_id]` | `teleport` | Teleports you directly to the interior bridge/foyer of an active vessel. |
| `/clear_all_cruise_ships` | `server` | Decommissions all active vessels, clears sky slots, and recycles memory. |

---

## 🌐 Cross-Game Compatibility

The Luanti Cruise Liner mod has been engineered with built-in zero-dependency fallbacks and native adapters:

- **Minetest Game (`default`, `doors`, `beds`, `stairs`)**: Fully supported with native teak, cherry, and pine integration.
- **Mineclonia / VoxeLibre (`mcl_core`, `mcl_chests`, `mcl_beds`, `mcl_furnaces`)**: Seamless automatic node mapping and sound profile translation.
- **Minimal / Standalone Environments**: Fully self-contained! If run without external games, custom standalone textures and nodes provide full out-of-the-box functionality.

---

## 📐 Technical Specifications

- **Vessel Length**: 200 blocks (~200 meters)
- **Vessel Beam (Width)**: 28–30 blocks
- **Vessel Height**: 32 blocks (Keel to Bridge Mast)
- **Top Cruising Speed**: 12 m/s (~23.3 knots)
- **Sky Realm Coordinate Base**: $Y = 25,000$ (Spaced 350 blocks apart along X-axis per slot)
- **Mapgen Engine**: High-performance asynchronous `VoxelManip` procedural interior generation.
- **Persistence**: Mod-storage backed JSON registry surviving server restarts and player disconnects.

---

## 📜 Credits & License

- **Code**: Licensed under the open-source **MIT License** © 2026 Jules.
- **3D Ship Exterior Model**: Based on Cruise Ship low-poly assets by **Quaternius** ([quaternius.com](https://quaternius.com/)), released under **CC0 1.0 Universal Public Domain**.
- **Audio & Sound Effects**: Custom maritime hydro-acoustics and steam horn licensed under **CC0 1.0 Public Domain**.
- **Textures**: Custom hand-crafted 16x16 / 32x32 textures licensed under **MIT / CC0 1.0**.

For full license terms and legal text, please refer to [LICENSE.md](LICENSE.md).

---

<p align="center">
  <b>⚓ Bon Voyage! Experience the oceans of Luanti like never before. ⚓</b>
</p>
