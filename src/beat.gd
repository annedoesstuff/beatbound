extends Sprite2D

@onready var beat_collision = $Area2D/CollisionShape2D
@onready var tween = create_tween()
@export var on_beat = false
@export var on_crit = false
@export var expired = false
@export var used = false
@export var did_crit = false
var ready_to_free = true

func _ready() -> void:
	# Move to center with fade-in animation
	self.modulate = Color(1,1,1,0)
	tween.tween_property(self, "position:x", position.x + 76, 0.5) #change
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.15)
	await tween.finished  
	
	# Move down & fade-out animation
	tween = create_tween()
	tween.tween_property(self, "position:x", position.x + 152, 0.5)
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	queue_free()


func play_on_beat():
	if on_crit:
		did_crit = true
	
	# when hit puls big and change color to red then remove
	tween.remove_all()
	beat_collision.call_deferred("set_disabled", true) 
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.2).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:x", position.x - 5, 0.2)
	tween.tween_property(self, "modulate", Color(1.0, 0.3, 0.3, 1), 0.1)
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2(0.8,0.8), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	#self.on_crit = area.crit
	self.on_beat = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	self.on_crit = false
	self.on_beat = false
	self.expired = true
