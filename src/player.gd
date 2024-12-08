extends CharacterBody2D

@export var tile_size = 32
#@export var can_move = false
#@export var beat_window = 0.2 # how long until beat expires
var last_beat_time: float = 0.0
var grace_window: float = 200 # in ms (this ± beat_window -> can_move = true)

@onready var beat_keeper = $"../BeatKeeper"
#@onready var beat_timer = $"../BeatTimer"


########### [Game Functions] ############
func _ready() -> void:
	beat_keeper.play()

func _input(event: InputEvent) -> void:
	
	'''
	if !can_move:
		print("--BEAT MISSED---")
		return
	'''
	
	#if can_move && (Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down")):
	if is_within_grace_window() && (Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down")):
		if Input.is_action_pressed("ui_right"):
			move(Vector2.RIGHT)
		if Input.is_action_pressed("ui_left"):
			move(Vector2.LEFT)
		if Input.is_action_pressed("ui_up"):
			move(Vector2.UP)
		if Input.is_action_pressed("ui_down"):
			move(Vector2.DOWN)
	else :
		print("--missed beat--")
	'''
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
	'''
	
########### [Other] ####################
func move(direction:Vector2):
	print(direction)

########### [Beat] ####################
func is_within_grace_window() -> bool:
	return abs(Time.get_ticks_msec() - last_beat_time) <= grace_window

func _on_beat_keeper_whole_beat(number: Variant, exact_msec: Variant) -> void:
	last_beat_time = exact_msec
	print("Beat!")
	'''
	can_move = true
	beat_timer.start(beat_window)
	

func _on_beat_timer_timeout() -> void:
	can_move = false
'''
