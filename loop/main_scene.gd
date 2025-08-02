extends Node2D

signal loop
signal antiloop
signal shield
signal anti_shield
signal no_shield
signal update_year(year)
signal solarWarning
signal antiWaveWarning
signal update_score(_score)
signal update_combo(_combo)
signal invincible(boolean)
signal tutormessage(message)


const abyss : Vector2 = Vector2(10000,10000)
var started : bool = false
var cw : bool = false
var ccw : bool = false
var three_fourths : bool = false
var combo : int = 0
var comboCD : float = 2.0
var shield_duration : float = 1.0
var year : float = 2050
var score : float = 0
var scoreMulti : float = 1.0
var shield_score : float = 50
var modifier_count : int = 0
var modifier_threshold : int = 10
var spawn_time : float = 2.0
var wave_time_min : float = 10
var wave_time_max : float = 30
var tutorial_stage : int = 0
var tutormode : bool = false

@export var rock: PackedScene
@export var antimatter: PackedScene
@export var scoreLabel: PackedScene
@export var deathParticle: PackedScene

var killed_rocks = 0
var killed_anti = 0
var blocked_solar = 0
var blocked_wave = 0
var cw_loops = 0
var ccw_loops = 0


func _ready() -> void:
	$maintheme.play()
	$AnimationPlayer2.play("down")

func _process(delta: float) -> void:
	if $Pointer != null:
		$MainMenu.set_play_pos($Pointer.global_position)

func play():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$UI.visible = true
	$menunoise.play()
	$MobSpawn.start()
	$WaveTimer.start()
	$Clock.start()
	no_shield.emit()
	combo = 0
	update_combo.emit(combo)
	$ShieldOff.stop()
	$LoopCombo.stop()
	killed_rocks = 0
	killed_anti = 0
	blocked_solar = 0
	blocked_wave = 0
	cw_loops = 0
	ccw_loops = 0
	score = 0
	update_score.emit(score)


func tutorial():
	if tutorial_stage == 0:
		$UI.visible = true
		$menunoise.play()
		invincible.emit(true)
		tutormode = true
		tutorial_stage += 1
	elif tutorial_stage == 1:
		if cw_loops >= 10:
			$menunoise.play()
			tutorial_stage += 1
	elif tutorial_stage == 2:
		if killed_rocks >= 5:
			$menunoise.play()
			tutorial_stage += 1
	elif tutorial_stage == 3:
		if ccw_loops >= 10:
			$menunoise.play()
			tutorial_stage += 1
	elif tutorial_stage == 4:
		if killed_anti >= 5:
			$menunoise.play()
			tutorial_stage += 1
	elif tutorial_stage == 5:
		if blocked_solar >= 5:
			$menunoise.play()
			tutorial_stage += 1
	elif tutorial_stage == 6:
		if blocked_wave >= 5:
			$menunoise.play()
			tutorial_stage += 1
	

func spawn(type):
	# Create a new instance of the Mob scene.
	var newthing
	if (type == 1):
		newthing = rock.instantiate()
	elif (type == 2):
		newthing = antimatter.instantiate()
		
	newthing.death.connect(enemyDeath)

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
		$loop.pitch_scale = 0.5 + (combo / 5)
		$loop.volume_db = (combo / 5)
		$loop.play()
		cw_loops += 1
		if tutorial_stage == 1:
			tutormessage.emit("Build Charge by pressing Spacebar.\nDo Clockwise loops around\nthe planet to build charge.\nDo 10 Clockwise Loops\n" + str(cw_loops) + " / 10")
		update_combo.emit(combo)
	elif(started and ccw and three_fourths):
		#print("ccw loop")
		antiloop.emit()
		reset_beacon()
		combo += 1
		if combo > 1:
			anti_shield.emit()
		$LoopCombo.start(comboCD)
		$loop.pitch_scale = 0.5 + (combo / 5)
		$loop.volume_db = (combo / 5)
		$loop.play()
		ccw_loops += 1
		if tutorial_stage == 3:
			tutormessage.emit("Do 10 Counter Clockwise Loops\nwhile holding SpaceBar.\nEach one builds anti-charge.\n" + str(ccw_loops) + " / 10")
		update_combo.emit(combo)
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
	$MobSpawn.start(spawn_time)


func _on_pointer_stop_looping() -> void:
	$Beacon.global_position = abyss
	$CWDetector.global_position = abyss
	$CCWDetector.global_position = abyss
	reset_beacon()


func _on_loop_combo_timeout() -> void:
	combo = 0
	update_combo.emit(combo)
	$ShieldOff.start(shield_duration)


func _on_wave_time_timeout() -> void:
	var rand_type = randi_range(1, 2)
	if (rand_type == 1):
		solarWarning.emit()
		$SolarTimer.start()
	elif (rand_type == 2):
		antiWaveWarning.emit()
		$AntiWaveTimer.start()
	var rand_time = randi_range(wave_time_min, wave_time_max)
	$WaveTimer.start(rand_time)


func _on_shield_off_timeout() -> void:
	no_shield.emit()


func _hurt(amount: Variant) -> void:
	$hit.play()
	$Camera2D.apply_shake(amount)


func _on_clock_timeout() -> void:
	year += 5
	update_year.emit(year)
	modifier_count += 1
	modifier_count = modifier_count % modifier_threshold
	if modifier_count == 0:
		spawn_time = spawn_time * 0.9
		wave_time_min = wave_time_min * 0.9
		wave_time_max = wave_time_max * 0.9
		scoreMulti += 1
		#print("next level")


func _on_solar_timer_timeout() -> void:
	$solarflare.play(5.0)
	$AnimationPlayer.play("solar_flare")


func _on_anti_wave_timer_timeout() -> void:
	$antiwave.play()
	$AnimationPlayer.play("anti_wave")

func enemyDeath(_score, _position):
	score += _score * scoreMulti * (combo + 1)
	update_score.emit(score)
	createScoreLabel(_score * scoreMulti * (combo + 1), _position, 1)

func createScoreLabel(_score, _position, type):
	var newScore = scoreLabel.instantiate()
	newScore.setup(_score, type)
	newScore.global_position = _position
	add_child(newScore)

func _on_base_protected() -> void:
	score += shield_score * scoreMulti * (combo + 1)
	update_score.emit(score)


func _on_base_game_over() -> void:
	$AnimationPlayer3.play("boom")
	$boom.play()


func _on_pointer_death(position: Variant) -> void:
	$moondeath.play()
	var particle = deathParticle.instantiate()
	particle.global_position = position
	add_child(particle)


func _on_pointer_hurt(amount: Variant) -> void:
	createScoreLabel(amount, $Pointer.global_position, 2)
	$UI.lower_moon_health(amount)


func _on_base_hurt(amount: Variant) -> void:
	createScoreLabel(amount, $Base.global_position, 2)
	$UI.lower_base_health(amount)


func _on_pointer_killed_rock() -> void:
	killed_rocks += 1
	if tutorial_stage == 2:
		tutormessage.emit("Destroy 5 Asteroids.\nLeft click to do a blast.\nTakes one charge\nCan't do it while building charge\n" + str(killed_rocks) + " / 5")


func _on_pointer_killed_anti() -> void:
	killed_anti += 1
	if tutorial_stage == 4:
		tutormessage.emit("Destroy 5 Anti-Matter Clusters.\nRight click to do an anti-blast\n" + str(killed_anti) + " / 5")


func _on_base_blocked_solar() -> void:
	blocked_solar += 1
	if tutorial_stage == 5:
		tutormessage.emit("Block 5 Solar Flares.\nCreate an Electromagnetic Shield\nby doing at least two Clockwise Loops\n in a row while charging\n" + str(blocked_solar) + " / 5")


func _on_base_blocked_wave() -> void:
	blocked_wave += 1
	if tutorial_stage == 6:
		tutormessage.emit("Block 5 Anti-Matter Waves.\nCreate an Anti-Matter Shield\nby doing at least\ntwo Counter Clockwise Loops\nin a row while charging\n" + str(blocked_wave) + " / 5")


func _on_tutorial_clock_timeout() -> void:
	tutorial()
	if tutorial_stage == 1:
		tutormessage.emit("Build Charge by pressing Spacebar.\nDo Clockwise loops around\nthe planet to build charge.\nDo 10 Clockwise Loops\n" + str(cw_loops) + " / 10")
	elif tutorial_stage == 2:
		tutormessage.emit("Destroy 5 Asteroids.\nLeft click to do a blast.\nTakes one charge\nCan't do it while building charge\n" + str(killed_rocks) + " / 5")
		spawn(1)
	elif tutorial_stage == 3:
		tutormessage.emit("Do 10 Counter Clockwise Loops\nwhile holding SpaceBar.\nEach one builds anti-charge.\n" + str(ccw_loops) + " / 10")
	elif tutorial_stage == 4:
		tutormessage.emit("Destroy 5 Anti-Matter Clusters.\nRight click to do an anti-blast\n" + str(killed_anti) + " / 5")
		spawn(2)
	elif tutorial_stage == 5:
		tutormessage.emit("Block 5 Solar Flares.\nCreate an Electromagnetic Shield\nby doing at least two Clockwise Loops\n in a row while charging\n" + str(blocked_solar) + " / 5")
		$solarflare.play(5.0)
		$AnimationPlayer.play("solar_flare")
	elif tutorial_stage == 6:
		tutormessage.emit("Block 5 Anti-Matter Waves.\nCreate an Anti-Matter Shield\nby doing at least\ntwo Counter Clockwise Loops\nin a row while charging\n" + str(blocked_wave) + " / 5")
		$antiwave.play()
		$AnimationPlayer.play("anti_wave")
	if tutorial_stage != 7:
		$TutorialClock.start()
	else:
		tutormessage.emit("Congraduation on completing the tutorial")
		get_tree().create_timer(3).timeout.connect(func():
			tutormessage.emit("Good Luck defending the Planet")
			$goodluck.play()
		)
		get_tree().create_timer(6).timeout.connect(func():
			tutormessage.emit("")
			invincible.emit(false)
			play()
		)


func _on_main_menu_tutor() -> void:
	tutorial()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$TutorialClock.start()


func _on_animation_player_3_animation_finished(anim_name: StringName) -> void:
	get_tree().create_timer(1).timeout.connect(func():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Gameover.add_year(year)
		$Gameover.set_score(score)
		$Gameover.active_now()
		$Gameover
		)


func _on_maintheme_finished() -> void:
	$maintheme.play()
