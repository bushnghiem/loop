extends Area2D
var shield : bool = false
var anti_shield : bool = false
var invincible = false
signal hurt(amount)
signal shields_update(shield, antishield)
signal protected
signal game_over
signal blocked_wave
signal blocked_solar

func _ready() -> void:
	$AnimationPlayer.play("spin")
	$AnimationPlayer2.play("shield")

func _on_area_entered(area: Area2D) -> void:
	if (area.is_in_group("enemy")):
		if (area.is_in_group("solar") and shield):
			blocked_solar.emit()
			protected.emit()
			shields_update.emit(shield, anti_shield)
		elif (area.is_in_group("antiwave") and anti_shield):
			blocked_wave.emit()
			protected.emit()
			shields_update.emit(shield, anti_shield)
		else:
			if !invincible:
				$Health.damage(area.damage)
				hurt.emit(area.damage)
		if (area.has_method("die")):
			area.die()


func _on_health_zero_health() -> void:
	
	game_over.emit()


func _on_main_scene_shield() -> void:
	shield = true
	$Shield.visible = true
	shields_update.emit(shield, anti_shield)


func _on_main_scene_anti_shield() -> void:
	anti_shield = true
	$Shield2.visible = true
	shields_update.emit(shield, anti_shield)


func _on_main_scene_no_shield() -> void:
	shield = false
	anti_shield = false
	$Shield.visible = false
	$Shield2.visible = false
	shields_update.emit(shield, anti_shield)


func _on_main_scene_invincible(boolean: Variant) -> void:
	invincible = boolean
