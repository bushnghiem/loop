extends Node2D
signal touched

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		touched.emit()
