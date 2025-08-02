extends "res://anti_matter.gd"
var disapear = false

func _process(delta: float) -> void:
	rotation = rotation + rotation_speed * delta
	global_position = global_position + velocity * delta
	if disapear:
		var color = $Sprite2D.get_self_modulate()
		var invisible = color
		invisible.a = 0
		color = lerp(color, invisible, 0.01)
		$Sprite2D.set_self_modulate(color)

func destroy():
	$CollisionShape2D.disabled
	velocity = velocity * randf_range(-4, -2)
	rotation_speed = rotation_speed * randf_range(-4, 4)
	death.emit(score, global_position)
	queue_free()

func die():
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	print("seen")
	disapear = true
