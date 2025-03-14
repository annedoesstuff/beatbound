extends CharacterBody2D

@onready var beat_keeper = $"../BeatKeeper"
@onready var tile_map = $"../TilemapLayer_Logic"
 

@onready var player_sprite = $PlayerAnimatedSprite
@onready var treadmill = $Hud/Treadmill

########### [Game Functions] ############
func _ready() -> void:
	beat_keeper.play()
	treadmill.play("default")
	#player_sprite.play("idle_down")

func _process(delta: float) -> void:
	
	if (Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_down")):
		var beat = treadmill.on_beat()
		if beat && beat.on_beat:
			print("input")
			if Input.is_action_just_pressed("ui_right"):
				move(Vector2.RIGHT)
			elif Input.is_action_just_pressed("ui_left"):
				move(Vector2.LEFT)
			elif Input.is_action_just_pressed("ui_up"):
				move(Vector2.UP)
			elif Input.is_action_just_pressed("ui_down"):
				move(Vector2.DOWN)
			
			treadmill.consume_current()
		
	
########### [MOVE] ####################
func move(direction:Vector2):
	# animation
	player_sprite.play("move_down")
	print("moving")
	
	# get tiles
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x, 
		current_tile.y + direction.y,
	)
	# get custom data layer (walkable - layer 0) from target tile
	var tile_data: TileData = tile_map.get_cell_tile_data(target_tile)
	
	if tile_data.get_custom_data("walkable") == false:
		print("cannot move there")
		return
	# move player
	global_position = tile_map.map_to_local(target_tile)
	

########### [BeatKeeper] ####################
func _on_beat_keeper_whole_beat(number: Variant, exact_msec: Variant) -> void:
	print("Beat!")
	
	
