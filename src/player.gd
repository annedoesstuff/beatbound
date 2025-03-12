extends CharacterBody2D

@export var can_move = false

@export var tile_size = 32
var beat_window: float = 0.2 # in ms (this ± beat_window -> can_move = true)
var move_direction = Vector2.ZERO

@onready var beat_keeper = $"../BeatKeeper"
@onready var tile_map = $"../TilemapLayer_Logic"
@onready var player_sprite = $PlayerAnimatedSprite

########### [Game Functions] ############
func _ready() -> void:
	beat_keeper.play()
	player_sprite.play("idle_down")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		print("moveing right")
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("ui_left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("ui_up"):
		move(Vector2.UP)
	elif Input.is_action_just_pressed("ui_down"):
		move(Vector2.DOWN)
	
########### [MOVE] ####################
func move(direction:Vector2):
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
	
	
