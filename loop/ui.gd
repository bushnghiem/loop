extends CanvasLayer
var count = 0
var warning_text = ""
var pausable = false

func _input(event):
	if pausable:
		if Input.is_action_just_pressed("pause"):
			if !get_tree().paused:
				get_tree().paused = true
				$Paused.visible = true
			else:
				get_tree().paused = false
				$Paused.visible = false

func _ready() -> void:
	pass

func set_base_health(_health):
	$BaseHealth.value = _health

func lower_base_health(amount):
	$BaseHealth.value -= amount
	if $BaseHealth.value <= 0:
		$Planet.visible = false

func set_moon_health(_health):
	$MoonHealth.value = _health

func lower_moon_health(amount):
	$MoonHealth.value -= amount
	if $MoonHealth.value <= 0:
		$Moon.visible = false

func _on_pointer_ammo_update(ammo: Variant, antiammo: Variant) -> void:
	$Charge.set_text(str(ammo) + " / 10")
	$AntiCharge.set_text(str(antiammo) + " / 10")

func _on_main_scene_update_year(year: Variant) -> void:
	$Year.text = "YEAR " + str(snapped(year, 1))


func _on_base_shields_update(shield: Variant, antishield: Variant) -> void:
	$Shield.visible = shield
	$AntiShield.visible = antishield

func solarWarning():
	#print("solar warn")
	warning_text = "Solar Flare In \n"
	count = 3
	$Timer.start()

func antiWaveWarning():
	#print("anti warn")
	warning_text = "Anti-Matter Wave In \n"
	count = 3
	$Timer.start()


func _on_timer_timeout() -> void:
	if count > 0:
		$Warning.text = warning_text + str(count)
		count -=1
		$Count.play()
		$Timer.start()
	else:
		$Warning.text = ""


func _on_main_scene_update_score(_score: Variant) -> void:
	$Score.text = str(snapped(_score, 1))


func _on_main_scene_update_combo(_combo: Variant) -> void:
	if _combo == 0:
		$LoopCombo.text = ""
	elif _combo == 1:
		$LoopCombo.text = "Loop"
	elif _combo > 1:
		$LoopCombo.text = "Loop X" + str(_combo)


func _on_main_scene_tutormessage(message: Variant) -> void:
	$TutorialMessage.text = message


func _on_base_game_over() -> void:
	pausable = false
