extends CharacterBody2D

@onready var beat_keeper = get_tree().current_scene.find_child("BeatKeeper")
@onready var tile_map = get_tree().current_scene.find_child("TilemapLayer_Logic")

@onready var sprite = $AnimatedSprite2D
@export var max_health = 1 # default
@export var damage = 1 # default
var current_health: int

var is_alive = true

func _ready() -> void:
	current_health = max_health
	sprite.play("idle")
	
# ---------------------------------

func on_hit(damage_amount: int):
	print(">enemy lost 1 health")
	current_health -= damage_amount
	
	if current_health <= 0 and is_alive:
		print(">enemy died")
		is_alive = false
		explode()
		# play death sprite

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
