extends Area2D

signal death(score, position)

var speed : float = 500.0
var direction : Vector2 = Vector2(1,0)
var velocity : Vector2 = Vector2(1,0)
var damage : float = 25.0
var rotation_speed : float = 1.0
var score : float = 20
var bounces : int = 1
var acceleration : Vector2

func _ready() -> void:
	rotation_speed = randf_range(-4, 4)
	acceleration = velocity

func _process(delta: float) -> void:
	rotation = rotation + rotation_speed * delta
	global_position = global_position + velocity * delta
	if bounces == 0:
		velocity += acceleration * delta
	

func destroy():
	if bounces > 0:
		bounces -= 1
		velocity = velocity * -2
		rotation_speed = rotation_speed * randf_range(-4, 4)
	else:
		$CollisionShape2D.disabled
		$AnimationPlayer.play("death")
		velocity = velocity * randf_range(-4, -2)
		rotation_speed = rotation_speed * randf_range(-4, 4)

func die():
	queue_free()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	death.emit(score, global_position)
	queue_free()
