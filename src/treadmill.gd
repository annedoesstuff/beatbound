extends AnimatedSprite2D

@export var beats = []
@export var combo_counter = 0

@onready var beat_keeper = $"../../../BeatKeeper"
var beat_duration = 0.5 # gets changed in _ready()

func _ready() -> void:
	beats.clear()
	beat_duration = (60 / beat_keeper.Tempo) * 2 # no idea why * 2 works but it does so im not questioning it 
	#print(beat_duration)

func _process(delta: float) -> void:
	while (!beats.is_empty() && (!is_instance_valid(beats.front()) || beats.front().expired)):
		beats.pop_front()

# -------------------------
func _on_beat_keeper_whole_beat(number: Variant, exact_msec: Variant) -> void:
	if exact_msec < 0:
		return
	
	var beat_node = load("res://src/beat.tscn").instantiate()
	beat_node.beat_duration = beat_duration
	beat_node.position.x -= 152
	beat_node.position.y += 7 # center on treadmill bg
	add_child(beat_node)
	
	beats.push_back(beat_node)

func on_beat():
	if beats.is_empty():
		print("not on beat!")
		return null
	
	var current_beat = beats.front()
	
	if current_beat.on_beat:
		current_beat.play_on_beat()
	
	return current_beat

func consume_current():
	var current_beat = beats.front()
	current_beat.used = true
	
	self.combo_counter += 1

func reset_combo():
	self.combo_counter = 0
