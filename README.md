# 🎵🔥 BeatBound 🔥🎵

A rhythm-based dungeon crawler built with **Godot 4**, inspired by *Crypt of the NecroDancer*.  
Originally developed for a university course on Computer Graphics — received a perfect score (woohoo!!).

> Move and attack **to the beat** in a grid-based dungeon! Timing is everything.

![Gameplay Screenshot](./images/gameplay-preview.png) <!-- Replace with actual image path -->

#### How to Run
1. Clone this repo
2. Open `project.godot` in Godot 4.2+
3. Press Play ▶
---

## Table of Contents
1. [What Is Crypt of the NecroDancer?](#what-is-crypt-of-the-necrodancer)
2. [Tilemap System](#tilemap-system)
3. [BeatKeeper Loop](#beatkeeper-loop)
4. [Entities & Combat](#entities--combat)
5. [Rendering & Visuals](#rendering--visuals)
6. [Ordering & Layers](#ordering--layers)

---

## What Is Crypt of the NecroDancer?

*A rogue-like rhythm game where every action — movement, attack, enemy behavior — must sync with the music’s beat. Mess up the timing, and you're toast. Nail it, and you're a dancing death machine.*

BeatBound captures this core loop in Godot, featuring beat-based input detection, procedurally reactive enemies, and layered 2D lighting.

---

## 🧱 Tilemap System

### Initial Design
Designed mockups in Figma.  
Created a 32×32 pixel tile system with depth (walls have a top & side), which was **hard to maintain** manually.

![Tilemap Sketch](./images/tilemap-sketch.png)

### Problem
- Top + side of walls are different sprites.
- Manual tile placement was error-prone and didn't update when digging tiles.

![Frustrating Manual Tiles](./images/problem-tiles.png)

### Solution: Terrain System
Used **Godot's TileMap Terrain** to auto-place wall-top combinations based on a bitmask.

- Automatically updates when digging.
- Paint-like workflow.

![Terrain System Demo](./images/terrain-demo.png)

### Data Layers
Added custom tile data:
- `walkable: bool`
- `diggable: bool`

These are used in movement, pathfinding, and digging logic.

![Data Layer Example](./images/data-layer.png)

### Logic Layer
Implemented an invisible TileMap that represents logic — such as where walls or walkable tiles are — separate from the visual layer.

Visual layers:
- Floor
- Wall
- Dirt
- Items

---

## 🕺 BeatKeeper Loop

### Audio + BPM Sync
Used [`ynot01/Godot-BeatKeeper`](https://github.com/ynot01/Godot-BeatKeeper).  
Provides a signal every full beat, based on the BPM of a given track.

### Treadmill System
On each beat, spawn a `BeatNode` that travels across a lane — like a treadmill of beats.

```gdscript
func _on_beat_keeper_whole_beat(number: Variant, exact_msec: Variant) -> void:
	if exact_msec < 0: return
	
	var beat_node = preload("res://src/beat.tscn").instantiate()
	beat_node.beat_duration = beat_duration
	beat_node.position = Vector2(-152, 7)  # Adjusted to center
	add_child(beat_node)
	beats.push_back(beat_node)
```
### BeatNode Detection
- Player input is only valid if it's on beat.
- BeatNodes animate into a target zone using Tween.
- Collision with a central zone marks the input as “on beat”.
```gdscript
# Tween into center, fade in/out
func _ready() -> void:
	tween.tween_property(self, "position:x", position.x + 76, beat_duration)
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.15)
	# more tween logic...
```
```gdscript
# Detect input timing
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.has_meta("crit"):
		self.on_crit = area.crit
	self.on_beat = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	self.on_crit = false
	self.on_beat = false
	self.expired = true
```

---

## 🧍 Entities & Combat
### Player
- `AnimatedSprite2D` with idle, walk, and attack states.
- Moves via raycasts.
- Checks for `walkable` from tilemap data.
- Attacks if enemy is detected.

```gdscript
func move(direction: Vector2):
	var current_tile = tile_map.local_to_map(global_position)
	var target_tile = current_tile + direction
	var tile_data = tile_map.get_cell_tile_data(target_tile)
	
	if not tile_data.get_custom_data("walkable"):
		return
	
	ray_cast.target_position = direction * 32
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		attack(direction)
	else:
		global_position = tile_map.map_to_local(target_tile)
```
### Enemies
Base enemy class with overrideable movement/attack behavior.
**Enemy Types:**
- Blue Slime: 2 HP, moves up/down every beat.
- Pink Slime: 1 HP, horizontal movement every 3rd beat, 2 damage.
- Mummy: 4 HP, diagonal movement.

---

### 🌌 Rendering & Visuals
- VFX for attacks, critical hits, and beat indicators.
- CanvasModulate for global darkness.
- Occlusion Layer for shadow-casting tiles.
- 2D Point Lights for torches & player light.
- CPUParticles2D for hits, movement trails, etc.
- Game Over screen, bones, holes, and cave props.

---

### 🧭 Ordering & Layers
Used `Z-index` and `YSort` to layer elements:
| Z-index | Layer             |
| ------- | ----------------- |
| 0       | Floor, Side Tiles |
| 1       | Player/Enemies    |
| 2       | Top Tiles         |
| 3       | UI Elements       |







