extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if (area.is_in_group("enemy")):
		if (area.has_method("destroy")):
			$Health.damage(area.damage)
			area.destroy()


func _on_health_zero_health() -> void:
	print("lose")
