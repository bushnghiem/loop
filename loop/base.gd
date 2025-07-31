extends Area2D
var shield : bool = false
var anti_shield : bool = false
signal hurt(amount)

func _ready() -> void:
	$AnimationPlayer.play("spin")
	$AnimationPlayer2.play("shield")

func _on_area_entered(area: Area2D) -> void:
	if (area.is_in_group("enemy")):
		if (area.is_in_group("solar") and shield):
			print("protected")
			shield = false
			$Shield.visible = false
		elif (area.is_in_group("antiwave") and anti_shield):
			print("protected")
			anti_shield = false
			$Shield2.visible = false
		else:
			$Health.damage(area.damage)
			hurt.emit(area.damage)
		if (area.has_method("destroy")):
			area.destroy()


func _on_health_zero_health() -> void:
	print("lose")


func _on_main_scene_shield() -> void:
	shield = true
	$Shield.visible = true


func _on_main_scene_anti_shield() -> void:
	anti_shield = true
	$Shield2.visible = true


func _on_main_scene_no_shield() -> void:
	shield = false
	anti_shield = false
	$Shield.visible = false
	$Shield2.visible = false
