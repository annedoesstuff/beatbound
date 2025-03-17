extends "res://src/enemies/enemy_class.gd"

var direction = Vector2i(1, -1) # diagonally up-right

func _ready() -> void:
	max_health = 4
	damage = 1
	super()

func move():
	var current_tile = tile_map.local_to_map(global_position)
	var target_tile = current_tile + direction
	var tile_data = tile_map.get_cell_tile_data(target_tile)
	
	# if not walkable bounce off wall
	if tile_data and tile_data.get_custom_data("walkable") == false:
		bounce()  
		ray_cast.target_position = direction * 32
		ray_cast.force_raycast_update()
		return
	
	ray_cast.target_position = direction * 32
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		var mob = ray_cast.get_collider().owner # player or enemy
		if mob and mob.is_in_group("player"):
			print("attacking player")
			mob.on_hit(damage)
			stunned = true
			return
		elif mob and mob.is_in_group("enemy"):
			print("found other enemy")
			# TODO: what happens
			
	#move
	global_position = tile_map.map_to_local(target_tile)
	
func bounce():
	var current_tile = tile_map.local_to_map(global_position)

	var test_horizontal = current_tile + Vector2i(direction.x, 0)
	var horizontal_tile = tile_map.get_cell_tile_data(test_horizontal)
	var test_vertical = current_tile + Vector2i(0, direction.y)
	var vertical_tile = tile_map.get_cell_tile_data(test_vertical)

	# reverse X if horizontal blocked
	var reverse_x = horizontal_tile and horizontal_tile.get_custom_data("walkable") == false
	# reverse Y if vertical blocked
	var reverse_y = vertical_tile and vertical_tile.get_custom_data("walkable") == false

	# both blocked.. reverse both
	if reverse_x and reverse_y:
		var can_move_x = tile_map.get_cell_tile_data(current_tile + Vector2i(direction.x, 0))
		var can_move_y = tile_map.get_cell_tile_data(current_tile + Vector2i(0, direction.y))

		# try moving only x or y
		if can_move_x and can_move_x.get_custom_data("walkable") != false:
			direction.y *= -1  
		elif can_move_y and can_move_y.get_custom_data("walkable") != false:
			direction.x *= -1  
		else:
			direction *= -1  
	elif reverse_x:
		direction.x *= -1
		sprite.flip_h = !sprite.flip_h
	elif reverse_y:
		direction.y *= -1
	
	

	
