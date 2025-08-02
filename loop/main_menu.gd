extends Control
signal play
signal tutor

func set_play_pos(_pos):
	$Play.global_position = _pos
	$Play.global_position.x -= 58
	$Play.global_position.y -= 24

func _on_play_pressed() -> void:
	visible = false
	play.emit()


func _on_tutorial_pressed() -> void:
	visible = false
	tutor.emit()
