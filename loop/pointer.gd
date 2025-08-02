extends Node2D
@export var center : Vector2 = Vector2.ZERO
@export var outRadius : float = 175
@export var inRadius : float = 160
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
var beaconCD : float = 0.5
var max_ammo : int = 10
var shield : bool = false
var anti_shield : bool = false
var main_menu : bool = true
var invincible = false

signal ammo_update(ammo, antiammo)
signal loopstart(pos)
signal full_charge
signal anti_full
signal stop_looping
signal hurt(amount)
signal death(position)
signal killed_rock
signal killed_anti

func _ready() -> void:
	$AnimationPlayer2.play("shield")

func play():
	ammo = 0
	anti_ammo = 0
	ammo_update.emit(ammo, anti_ammo)
	main_menu = false

func _process(delta: float) -> void:
	if !main_menu:
		if Input.is_action_pressed("primary") and !beaconed:
			if ($AttackCD.is_stopped() and ammo >= 1):
				attack()
		if Input.is_action_pressed("secondary") and !beaconed:
			if ($AttackCD.is_stopped() and anti_ammo >= 1):
				attack2()
		if Input.is_action_pressed("beacon") and $BeaconCD.is_stopped():
			if !beaconed:
				start_looping()
				$GPUParticles2D.emitting = true
				beaconed = true
		elif Input.is_action_just_released("beacon"):
			if beaconed:
				beaconed = false
				$GPUParticles2D.emitting = false
				stop_looping.emit()
				$BeaconCD.start(0.5)
		
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
			#print("halfloop")
			pass
		
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
		global_position = lerp(global_position, newPos, 0.5)
		#global_position = newPos
	else:
		var angle = Time.get_ticks_msec() / 1000.0 * 1
		var offset = Vector2(outRadius, 0).rotated(angle)
		global_position = Vector2(0, 0) + offset
		

func attack():
	var inRange = $AttackRange.get_overlapping_areas()
	for area in range(inRange.size()):
		if (inRange[area].has_method("destroy")):
			inRange[area].destroy()
			killed_rock.emit()
	$AttackCD.start(attackcd)
	$GPUParticles2D2.emitting = true
	$primary.play()
	$Timer.start(0.1)

	ammo -= 1
	ammo_update.emit(ammo, anti_ammo)

func attack2():
	var inRange = $AttackRange2.get_overlapping_areas()
	for area in range(inRange.size()):
		if (inRange[area].has_method("destroy")):
			inRange[area].destroy()
			killed_anti.emit()
	$AttackCD.start(attackcd)
	$GPUParticles2D3.emitting = true
	$secondary.play(0)
	$Timer.start(0.1)

	anti_ammo -= 1
	ammo_update.emit(ammo, anti_ammo)

func start_looping():
	stopped = true
	loopStart = currAng
	looped = false
	#print("stopped: loopStart is " + str(loopStart))
	var dist =  inRadius + ((outRadius - inRadius) / 2)
	loopstart.emit(Vector2.from_angle(loopStart) * dist)


func _on_main_scene_loop() -> void:
	ammo += 1
	if (ammo >= max_ammo):
		ammo = max_ammo
		full_charge.emit()
	ammo_update.emit(ammo, anti_ammo)


func _on_player_area_entered(area: Area2D) -> void:
	if (area.is_in_group("enemy")):
		if (area.is_in_group("solar") and shield):
			print("protected")
		elif (area.is_in_group("antiwave") and anti_shield):
			print("protected")
		else:
			if !invincible:
				$Health.damage(area.damage)
				hurt.emit(area.damage)
		if (area.has_method("die")):
			area.die()


func _on_health_zero_health() -> void:
	death.emit(global_position)
	queue_free()


func _on_attack_cd_timeout() -> void:
	pass


func _on_timer_timeout() -> void:
	$GPUParticles2D2.emitting = false
	$GPUParticles2D3.emitting = false


func _on_main_scene_antiloop() -> void:
	anti_ammo += 1
	if (anti_ammo >= max_ammo):
		anti_ammo = max_ammo
		anti_full.emit()
	ammo_update.emit(ammo, anti_ammo)


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


func _on_main_scene_invincible(boolean: Variant) -> void:
	invincible = boolean
