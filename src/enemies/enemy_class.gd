extends CharacterBody2D

@onready var beat_keeper = get_tree().current_scene.find_child("BeatKeeper")
@onready var tile_map = get_tree().current_scene.find_child("TilemapLayer_Logic")

@onready var ray_cast = $RayCast2D
@onready var sprite = $AnimatedSprite2D
@onready var hurt_sound_player = $SoundEffects
var hurt_sounds = [
	preload("res://assets/music/retro-hurt-1-236672.mp3"),
	preload("res://assets/music/retro-hurt-2-236675.mp3")
]
var hurt_sounds_index = 0
@onready var hearts_ui = $enemy_hearts_ui
@export var max_health = 1 # default
@export var damage = 1 # default
var current_health: int
var is_alive = true

var stunned = false

func _ready() -> void:
	beat_keeper.whole_beat.connect(_on_beat_keeper_whole_beat)
	add_to_group("enemy") #enemy group for player attack detection & dealing damage
	current_health = max_health
	hearts_ui.max_health = max_health
	hearts_ui.set_health(0) # to make it only visible once the player hits the enemy once
	sprite.play("idle")
	
# ---------------------------------
func _on_beat_keeper_whole_beat(number, exact_msec):
	if number % 2 == 0: # move every other beat
		if stunned:
			stunned = false
			sprite.play()
			return
		move()

func move():
	pass

func on_hit(damage_amount: int):
	stunned = true
	sprite.stop()
	print(">enemy lost 1 health")
	current_health -= damage_amount
	hearts_ui.set_health(current_health)
	play_hurt_sound()
	
	if current_health <= 0 and is_alive:
		print(">enemy died")
		is_alive = false
		explode()
		queue_free()
		# play death sprite

func play_hurt_sound():
	hurt_sound_player.stream = hurt_sounds[hurt_sounds_index]
	hurt_sound_player.play()
	hurt_sounds_index = (hurt_sounds_index + 1) % hurt_sounds.size()

func explode():
	# timeout timer 0.2
	var death_explosion = load("res://src/enemies/death_explosion.tscn").instantiate()
	get_tree().root.add_child(death_explosion)
	death_explosion.global_transform = global_transform
	
	var tween = death_explosion.create_tween()
	tween.tween_property(death_explosion, "scale", death_explosion.scale * 50, 1)
	await tween.finished
	death_explosion.queue_free()

func get_health():
	return current_health

# func player collision():
# 	player.take_damage(damage)
