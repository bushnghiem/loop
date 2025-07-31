extends Area2D
var speed = 500
var direction = Vector2(1,0)
var velocity = Vector2(1,0)
var damage = 50

func _process(delta: float) -> void:
	global_position = global_position + velocity * delta

func destroy():
	queue_free()
