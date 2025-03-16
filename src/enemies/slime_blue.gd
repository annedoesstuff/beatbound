extends "res://src/enemies/enemy_class.gd"

var direction = Vector2.UP

func _ready() -> void:
	max_health = 2
	damage = 1
	super()

func move():
	var current_tile = tile_map.local_to_map(global_position)
	var target_tile = current_tile + Vector2i(direction)
	
	var tile_data = tile_map.get_cell_tile_data(target_tile)
	
	if tile_data and tile_data.get_custom_data("walkable") == false:
		direction *= -1 # reverse direction
		target_tile = current_tile + Vector2i(direction)
	
	# check for player / if attack
	ray_cast.target_position = direction * 32 # point up down, left, right (tiles: 32x32)
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		print("attacking player")
		return
		
	# move slime
	if tile_map.get_cell_tile_data(target_tile).get_custom_data("walkable") != false:
		global_position = tile_map.map_to_local(target_tile)
