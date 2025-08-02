extends CanvasLayer
signal play

func _on_play_pressed() -> void:
	visible = false
	play.emit()
