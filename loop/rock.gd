extends Area2D
var speed = 500

func _process(delta: float) -> void:
	global_position = global_position + speed * Vector2(1,0)

func destroy():
	queue_free()
