extends Node2D

signal loop
signal antiloop
signal shield
signal anti_shield
signal no_shield
signal update_year(year)
signal solarWarning
signal antiWaveWarning

const abyss : Vector2 = Vector2(10000,10000)
var started : bool = false
var cw : bool = false
var ccw : bool = false
var three_fourths : bool = false
var combo : int = 0
var comboCD : float = 1.0
var shield_duration : float = 1.0
var year = 2050
@export var rock: PackedScene
@export var antimatter: PackedScene

func _ready() -> void:
	spawn(1)

func spawn(type):
	# Create a new instance of the Mob scene.
	var newthing
	if (type == 1):
		newthing = rock.instantiate()
	elif (type == 2):
		newthing = antimatter.instantiate()

	# Choose a random location on Path2D.
	var rock_pos = $Path2D/PathFollow2D
	rock_pos.progress_ratio = randf()

	# Set the mob's position to the random location.
	newthing.global_position = rock_pos.global_position

	# Set the mob's direction perpendicular to the path direction.
	var direction = rock_pos.global_position.direction_to(Vector2.ZERO)
	# Add some randomness to the direction.
	#direction += randf_range(-PI / 4, PI / 4)
	newthing.rotation = randf_range(-PI / 4, PI / 4)

	# Choose the velocity for the mob.
	var velocity = randf_range(100, 200)
	newthing.velocity = velocity * direction
	

	# Spawn the mob by adding it to the Main scene.
	add_child(newthing)

func _on_pointer_loopstart(pos: Variant) -> void:
	$Beacon.global_position = pos
	$CWDetector.global_position = pos.rotated(PI/2)
	$CCWDetector.global_position = pos.rotated(-PI/2)
	reset_beacon()


func _on_cw_detector_touched() -> void:
	if (!cw and !ccw):
		cw = true
		#print("going clockwise")
	elif (ccw):
		three_fourths = true
		#print("3/4ths counter clockwise")
	elif (cw):
		#print("went backwards")
		reset_beacon()


func _on_ccw_detector_touched() -> void:
	if (!cw and !ccw):
		ccw = true
		#print("going counter clockwise")
	elif (cw):
		three_fourths = true
		#print("3/4ths clockwise")
	elif (ccw):
		#print("went backwards")
		reset_beacon()


func _on_beacon_player_enter() -> void:
	if (started and cw and three_fourths):
		#print("cw loop")
		loop.emit()
		reset_beacon()
		combo += 1
		if combo > 1:
			shield.emit()
		$LoopCombo.start(comboCD)
	elif(started and ccw and three_fourths):
		#print("ccw loop")
		antiloop.emit()
		reset_beacon()
		combo += 1
		if combo > 1:
			anti_shield.emit()
		$LoopCombo.start(comboCD)
	elif (started and (cw or ccw) and !three_fourths):
		#print("started then went backwards")
		reset_beacon()

func reset_beacon():
	cw = false
	ccw = false
	three_fourths = false
	started = false

func _on_beacon_player_leave() -> void:
	if !started:
		started = true


func _on_mob_spawn_timeout() -> void:
	spawn(randi_range(1, 2))


func _on_pointer_stop_looping() -> void:
	$Beacon.global_position = abyss
	$CWDetector.global_position = abyss
	$CCWDetector.global_position = abyss
	reset_beacon()


func _on_loop_combo_timeout() -> void:
	combo = 0
	$ShieldOff.start(shield_duration)


func _on_wave_time_timeout() -> void:
	var rand_type = randi_range(1, 2)
	if (rand_type == 1):
		solarWarning.emit()
		$SolarTimer.start()
	elif (rand_type == 2):
		antiWaveWarning.emit()
		$AntiWaveTimer.start()
	var rand_time = randi_range(10, 30)
	$WaveTimer.start(rand_time)


func _on_shield_off_timeout() -> void:
	no_shield.emit()


func _hurt(amount: Variant) -> void:
	$Camera2D.apply_shake(amount)


func _on_clock_timeout() -> void:
	year += 5
	update_year.emit(year)


func _on_solar_timer_timeout() -> void:
	$AnimationPlayer.play("solar_flare")


func _on_anti_wave_timer_timeout() -> void:
	$AnimationPlayer.play("anti_wave")
