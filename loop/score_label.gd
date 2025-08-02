extends Label
var up_speed : float = 100
var amplitude : float = 5
var oscillate_speed : float = 10
var time : float = 0
var size_scale : float = 100

func _process(delta: float) -> void:
	if (global_position.y < 0):
		global_position.y -= up_speed * delta
	else:
		global_position.y += up_speed * delta
	global_position.x += cos(time * oscillate_speed) * amplitude
	time += delta

func setup(score, type):
	if (type == 1):
		modulate.r = 0
		modulate.b = 0
		modulate.g = 255
		text = "+" + str(snapped(score, 1))
	else:
		modulate.r = 255
		modulate.b = 0
		modulate.g = 0
		text = "-" + str(snapped(score, 1))
	scale = Vector2(1 + (score / size_scale), 1 + (score / size_scale))
	scale.clampf(1.0, 10.0)

func _on_gone_timeout() -> void:
	queue_free()
