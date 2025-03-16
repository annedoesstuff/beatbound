extends Control

@export var max_health = 5 # overwritten by enemy_class.gd
var current_health
@onready var heart_container = $HBoxContainer


func _ready() -> void:
	current_health = max_health
	update_hearts()


func update_hearts():
	for i in range(heart_container.get_child_count()):
		heart_container.get_child(i).visible = i < current_health

func set_health(new_health):
	current_health = max(new_health, 0) # not negative
	update_hearts()
