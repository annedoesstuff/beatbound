extends CharacterBody2D

@onready var beat_keeper = get_tree().current_scene.find_child("BeatKeeper")
@onready var tile_map = get_tree().current_scene.find_child("TilemapLayer_Logic")
@onready var player_sprite = $PlayerAnimatedSprite
@onready var treadmill = $Hud/Treadmill
@onready var player_camera = $PlayerCamera

@onready var hurt_sprite = $PlayerHurtEffect/HurtSprite
@onready var hurt_timer = $PlayerHurtEffect/PlayerHurtTimer
@onready var hurt_collision = $PlayerHurtEffect/HurtArea/HurtCollision
@onready var hurt_sound = $PlayerHurtEffect/HurtSound
@onready var hurt_tween = create_tween()
var player_hurt = false

var max_health = 3
var health
var is_alive = true
@export var can_move = true
#var last_direction = Vector2.DOWN  # Default idle direction

########### [Game Functions] ############
func _ready() -> void:
	beat_keeper.whole_beat.connect(_on_beat_keeper_whole_beat)
	beat_keeper.play()
	treadmill.play("default")
	health = max_health
	player_sprite.play("idle_down")

func _process(delta: float) -> void:
	if !is_alive:
		return
	
	if !can_move:
		return
	
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
	
	# TODO: if collision detected attack instead 	
	# move player
	global_position = tile_map.map_to_local(target_tile)
	

########### [BeatKeeper] ####################
func _on_beat_keeper_whole_beat(number: Variant, exact_msec: Variant) -> void:
	print("Beat!")

########### [HURT] ##########################
#func on_hit(damage):
	#if health <= 0 and is_alive:
		#is_alive = false
		#can_move = false
		## play death sprite
		## do a death screen / camera zoom
		## exit the game
	#
	#if is_alive:
		#hurt_collision.call_deferred("set_disabled", true)
		#if !player_hurt:
			#player_hurt = true
			#hurt_timer.start()
			#player_camera._cameraShake(10)
			#hurt_sound.play()
			#hurt_sprite.visible = true
			#hurt_sprite.rotation = deg_to_rad(randf_range(-90, 90))
			#hurt_sprite.play("default")
			#play_hurt_flicker()
	#
#func play_hurt_flicker():
	#hurt_tween.tween_property(player_sprite, "modulate", Color(1,1,1,0), 0.2)
	#hurt_tween.tween_property(player_sprite, "modulate", Color(1,1,1,1), 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
#
#func _on_player_hurt_timer_timeout() -> void:
	#hurt_tween.kill()
	#hurt_sprite.visible = false
	#hurt_sprite.frame = 0
	#player_hurt = false
	#hurt_collision.call_deferred("set_disabled", false)
