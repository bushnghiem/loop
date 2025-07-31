extends Node2D
signal player_enter
signal player_leave
@export var center : Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	var newAng = (global_position - center).angle()
	rotation = newAng

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		player_enter.emit()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		player_leave.emit()
