extends Area2D
var speed = 500
var direction = Vector2(1,0)
var velocity = Vector2(1,0)
var damage = 25
var rotation_speed = 1

func _ready() -> void:
	rotation_speed = randf_range(-4, 4)

func _process(delta: float) -> void:
	rotation = rotation + rotation_speed * delta
	global_position = global_position + velocity * delta

func destroy():
	queue_free()
