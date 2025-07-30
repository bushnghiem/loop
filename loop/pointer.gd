extends Node2D
@export var center : Vector2 = Vector2(1920/2,1080/2)
@export var outRadius : float = 300
@export var inRadius : float = 275
var prevPos : Vector2 = Vector2()
var loopStart : float = 0.0
var currAng : float = 0.0
var stopped : bool = false
var looped : bool =  false

func _process(delta: float) -> void:
	var newPos = get_global_mouse_position()

	var offset = newPos - center

	if (offset.length() > outRadius):
		newPos = center + offset.normalized() * outRadius
	elif (offset.length() < inRadius):
		newPos = center + offset.normalized() * inRadius
	
	
	if (global_position != prevPos):
		if (!$StopTimer.is_stopped()):
			$StopTimer.stop()
			#print("canceled timer")
		else:
			stopped = false
			#print("moving")
	elif ($StopTimer.is_stopped()):
		$StopTimer.start(0.5)
		#print("start timer")
	
	prevPos = global_position
	global_position = newPos


func _on_stop_timer_timeout() -> void:
	stopped = true
	loopStart = currAng
	looped = false
	print("stopped: loopStart is " + str(loopStart))
