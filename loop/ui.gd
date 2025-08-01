extends Control

func _ready() -> void:
	print($Charge.text)
	print($AntiCharge.text)

func _on_pointer_ammo_update(ammo: Variant, antiammo: Variant) -> void:
	$Charge.set_text(str(ammo) + " / 10")
	$AntiCharge.set_text(str(antiammo) + " / 10")

func _on_main_scene_update_year(year: Variant) -> void:
	$Year.text = "Year " + str(year)


func _on_base_shields_update(shield: Variant, antishield: Variant) -> void:
	$Shield.visible = shield
	$AntiShield.visible = antishield

func solarWarning():
	for n in 3:
		get_tree().create_timer(1 * n).timeout.connect(func():
			$SolarWarning.text = str(n)
		)

func antiWaveWarning():
	for n in 3:
		get_tree().create_timer(1 * n).timeout.connect(func():
			$AntiWaveWarning.text = str(n)
			)
