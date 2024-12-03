extends CharacterBody2D

@export var tile_size = 32
@export var can_move = false
@export var beat_window = 0.5 # how long until beat expires

@onready var beat_keeper = $"../BeatKeeper"
@onready var beat_timer = $"../BeatTimer"


########### [Game Functions] ############
func _ready() -> void:
	beat_keeper.play()
	position.y = 50

func _input(event: InputEvent) -> void:
	if can_move:
		velocity = Vector2.ZERO
		if Input.is_action_pressed("ui_right"):
			velocity.x = tile_size
			print("GO RIGHT ->")
		else:
			velocity = Vector2.ZERO
			print("MISSED")
		
		set_velocity(velocity)
		move_and_slide()

########### [Other] ####################


########### [Beat] ####################
func _on_beat_keeper_whole_beat(number: Variant, exact_msec: Variant) -> void:
	can_move = true
	beat_timer.start(beat_window)
	print("Beat!")

func _on_beat_timer_timeout() -> void:
	can_move = false
