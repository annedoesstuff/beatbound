extends Camera2D


var shake_strength = 0.0
var shake_decay = 10.0
#@onready var tween = create_tween()
# var a: int = 2
# var b: String = "text"

#func _death_zoom():
	#tween.interpolate_property(self,"zoom", self.zoom, self.zoom - Vector2(.4,.4),1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	#tween.start()

func _cameraShake(cameraShakeAmount: float):
	shake_strength = cameraShakeAmount



func _process(delta: float):
	shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
	self.offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
