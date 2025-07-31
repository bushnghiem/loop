extends Node2D
@export var center : Vector2 = Vector2.ZERO
@export var outRadius : float = 175
@export var inRadius : float = 150
@export var beacon : Node
var stoplen : float = 1.0
var prevPos : Vector2 = Vector2()
var loopStart : float = 0.0
var currAng : float = 0.0
var stopped : bool = false
var looped : bool = false
var ammo : int = 0
var anti_ammo : int = 0
var attackcd : float = 0.5
var beaconed : bool = false

signal loopstart(pos)
signal stop_looping

func _process(delta: float) -> void:
	if Input.is_action_pressed("primary"):
		if ($AttackCD.is_stopped() and ammo >= 1):
			attack()
	if Input.is_action_pressed("secondary"):
		if ($AttackCD.is_stopped() and anti_ammo >= 1):
			attack2()
	if Input.is_action_pressed("beacon"):
		if !beaconed:
			start_looping()
			beaconed = true
	elif Input.is_action_just_released("beacon"):
		if beaconed:
			beaconed = false
			stop_looping.emit()
	
	var newPos = get_global_mouse_position()

	var offset = newPos - center

	if (offset.length() > outRadius):
		newPos = center + offset.normalized() * outRadius
	elif (offset.length() < inRadius):
		newPos = center + offset.normalized() * inRadius
	
	var newAng = (newPos - center).angle()
	if newAng < 0:
		newAng = PI + (PI + newAng)
	currAng = newAng
	var normalized_a = Vector2.ZERO
	if beacon != null:
		normalized_a = beacon.global_position.normalized()
		
	var normalized_b = global_position.normalized()
	# Get the angle in radians
	# Calculate the dot product
	var dot_product = normalized_a.dot(normalized_b)
	var angle_radians = acos(dot_product)
	#print(angle_radians)
	if (angle_radians >= 3 && angle_radians < PI + 0.14159 ):
		print("halfloop")
	
	if (global_position != prevPos):
		if (!$StopTimer.is_stopped()):
			$StopTimer.stop()
			#print("canceled timer")
		else:
			stopped = false
			#print("moving")
	elif ($StopTimer.is_stopped()):
		$StopTimer.start(stoplen)
		#print("start timer")
	
	prevPos = global_position
	global_position = newPos

func attack():
	var inRange = $AttackRange.get_overlapping_areas()
	for area in range(inRange.size()):
		if (inRange[area].has_method("destroy")):
			inRange[area].destroy()
	$AttackCD.start(attackcd)
	$Timer.start(0.1)
	$Sprite2D2.visible = true
	ammo -= 1

func attack2():
	var inRange = $AttackRange2.get_overlapping_areas()
	for area in range(inRange.size()):
		if (inRange[area].has_method("destroy")):
			inRange[area].destroy()
	$AttackCD.start(attackcd)
	$Timer.start(0.1)
	$Sprite2D2.visible = true
	anti_ammo -= 1

func start_looping():
	stopped = true
	loopStart = currAng
	looped = false
	#print("stopped: loopStart is " + str(loopStart))
	loopstart.emit(Vector2.from_angle(loopStart) * outRadius)


func _on_main_scene_loop() -> void:
	ammo += 1


func _on_player_area_entered(area: Area2D) -> void:
	if (area.is_in_group("enemy")):
		if (area.has_method("destroy")):
			$Health.damage(area.damage)
			area.destroy()


func _on_health_zero_health() -> void:
	print("protector death")


func _on_attack_cd_timeout() -> void:
	pass


func _on_timer_timeout() -> void:
	$Sprite2D2.visible = false


func _on_main_scene_antiloop() -> void:
	anti_ammo += 1
