extends CanvasLayer
signal play
signal tutor

func _on_play_pressed() -> void:
	visible = false
	play.emit()


func _on_tutorial_pressed() -> void:
	visible = false
	tutor.emit()
