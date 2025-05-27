# 🎵🔥 BeatBound 🔥🎵

A rhythm-based dungeon crawler built with **Godot 4**, inspired by *Crypt of the NecroDancer*.  
Originally developed for a university course on Computer Graphics — received a perfect score (woohoo!!).

> Move and attack **to the beat** in a grid-based dungeon! Timing is everything.

#### How to Run
1. Clone this repo
2. Open in Godot 4.2+
3. Press Play :)
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

### Problem
- Top + side of walls are different sprites.
- Manual tile placement was error-prone and didn't update when digging tiles.

### Solution: Terrain System
Used **Godot's TileMap Terrain** to auto-place wall-top combinations based on a bitmask.

- Automatically updates when digging.
- Paint-like workflow.

![Screenshot 2024-12-04 113209](https://github.com/user-attachments/assets/e90384e5-a3ec-4f20-977a-dee6d9d97f69)
![Screenshot 2025-03-17 222927](https://github.com/user-attachments/assets/916f8c95-907d-4348-a367-053c7bab59a3)


### Data Layers
Added custom tile data:
- `walkable: bool`
- `diggable: bool`

These are used in movement, pathfinding, and digging logic.

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

![Screenshot 2025-03-17 223637](https://github.com/user-attachments/assets/50060990-65e0-4633-8624-b9274f8846da)

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

![Screenshot 2025-03-18 085734](https://github.com/user-attachments/assets/56641209-aa37-4796-a811-87fac5eeb8f6)

- `AnimatedSprite2D` with idle, walk, hurt, and attack states.
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

![Screenshot 2025-03-18 082624](https://github.com/user-attachments/assets/1ff5d575-bd3a-4b4d-a10c-0483574065b2)

**Enemy Types:**
- Blue Slime: 2 HP, moves up/down every beat.
- Pink Slime: 1 HP, horizontal movement every 3rd beat, 2 damage.
- Mummy: 4 HP, diagonal movement.

---

### 🌌 Rendering & Visuals
- VFX for attacks, critical hits, and beat indicators.
- CanvasModulate for global darkness.
- Occlusion Layer for shadow-casting tiles.
  
  ![Screenshot 2025-03-17 122122](https://github.com/user-attachments/assets/112252a2-b9e0-4dab-9354-ffe0cf00194b)
![Screenshot 2025-03-18 084607](https://github.com/user-attachments/assets/3498cc68-6181-4f7a-ac16-85d3f2270e21)
- 2D Point Lights for torches & player light.
  
  ![Screenshot 2025-03-17 222628](https://github.com/user-attachments/assets/505940a5-3019-4b5b-8f59-b92b74018fe7)
- CPUParticles2D for hits, movement trails, etc.
  
![Screenshot 2025-03-18 084259](https://github.com/user-attachments/assets/2377c8d0-a527-4ffe-af93-cb06ff48ae20)

- Game Over screen, bones, holes, and cave props.

![Screenshot 2025-03-18 085119](https://github.com/user-attachments/assets/2e006da8-c7aa-4aec-b109-43df1d60f038)
![Screenshot 2025-03-18 085232](https://github.com/user-attachments/assets/e4f527e1-d908-4a47-a1b4-fdb022a05cb3)
![Screenshot 2025-03-17 154626](https://github.com/user-attachments/assets/5745a169-3d2f-4d97-b9ed-de6b89ec30cf)

---

### 🧭 Ordering & Layers
Used `Z-index` and `YSort` to layer elements:
| Z-index | Layer             |
| ------- | ----------------- |
| 0       | Floor, Side Tiles |
| 1       | Player/Enemies    |
| 2       | Top Tiles         |
| 3       | UI Elements       |

![Screenshot 2025-03-18 083630](https://github.com/user-attachments/assets/74a3ae5e-bac6-4d98-aea1-3aa620786c23)








