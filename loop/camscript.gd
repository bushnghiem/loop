extends Camera2D
@export var shakeFade: float = 5.0
var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var target_position: Vector2 =  Vector2.ZERO

func apply_shake(strength):
	shake_strength = strength

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
	position = lerp(position, target_position, 0.1)
	position += randomOffset()
