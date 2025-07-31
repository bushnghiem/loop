extends Node2D

signal loop
var started = false
var cw = false
var ccw = false
var three_fourths = false

func _on_pointer_loopstart(pos: Variant) -> void:
	$Beacon.global_position = pos
	$CWDetector.global_position = pos.rotated(PI/2)
	$CCWDetector.global_position = pos.rotated(-PI/2)


func _on_cw_detector_touched() -> void:
	if (!cw and !ccw):
		cw = true
		#print("going clockwise")
	elif (ccw):
		three_fourths = true
		#print("3/4ths counter clockwise")
	elif (cw):
		#print("went backwards")
		cw = false
		ccw = false
		three_fourths = false
		started = false


func _on_ccw_detector_touched() -> void:
	if (!cw and !ccw):
		ccw = true
		#print("going counter clockwise")
	elif (cw):
		three_fourths = true
		#print("3/4ths clockwise")
	elif (ccw):
		#print("went backwards")
		cw = false
		ccw = false
		three_fourths = false
		started = false


func _on_beacon_player_enter() -> void:
	if (started and (cw or ccw) and three_fourths):
		print("loop")
		loop.emit()
		cw = false
		ccw = false
		three_fourths = false
		started = false
	elif (started and (cw or ccw) and !three_fourths):
		#print("started then went backwards")
		cw = false
		ccw = false
		three_fourths = false
		started = false


func _on_beacon_player_leave() -> void:
	if !started:
		started = true
