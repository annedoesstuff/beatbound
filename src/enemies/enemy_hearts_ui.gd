extends Control

@onready var hearts = $HBoxContainer.get_children()
@onready var hearts_container = $HBoxContainer
@export var heart_full_texture: Texture2D
@export var heart_empty_texture: Texture2D


func set_health(max_health: int):
	for i in range(hearts_container.get_child_count()):
		hearts_container.get_child(i).visible = i < max_health

func update_health(current_health: int, max_health: int):
	for i in range(max_health):
		if i < current_health:
			hearts[i].texture = heart_full_texture
		else:
			hearts[i].texture = heart_empty_texture
	
