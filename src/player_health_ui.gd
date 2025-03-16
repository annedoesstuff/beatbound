extends Control

@export var heart_full_texture: Texture2D
@export var heart_empty_texture: Texture2D

@onready var hearts = $HBoxContainer.get_children()

func update_health(current_health: int, max_health: int):
	for i in range(max_health):
		if i < current_health:
			hearts[i].texture = heart_full_texture
		else:
			hearts[i].texture = heart_empty_texture
