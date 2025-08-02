extends CanvasLayer
var active = false
var death_message = "PLANET ENDED YEAR "
var count = 0
var index = 0

func _ready() -> void:
	for i in get_child_count():
		var invisible = Color(1.0, 1.0, 1.0, 0)
		get_child(i).set_self_modulate(invisible)

func active_now():
	$ResetButton/deathsong.play()
	get_tree().paused = true
	visible = true
	active = true
	see_me(0)
	for n in death_message.length():
		get_tree().create_timer(0.4 * n).timeout.connect(func():
			$DeathMessage.text += death_message[n]
			if (has_letters_and_numbers(death_message[n])):
				$ResetButton/menunoise.play()
			)
	get_tree().create_timer(0.4 * death_message.length() + 1).timeout.connect(func():
			$Score.visible = true
			$ResetButton/menunoise.play()
			)
	get_tree().create_timer(0.4 * death_message.length() + 2).timeout.connect(func():
			$ResetButton.disabled = false
			$ResetButton.visible = true
			$ResetButton/menunoise.play()
			)

func see_me(value):
	var default = Color(1.0, 1.0, 1.0, value)
	for i in get_child_count():
		get_child(i).set_self_modulate(default)

func has_letters_and_numbers(your_string):
	var regex = RegEx.new()
	regex.compile("[a-zA-Z0-9]+")  # Matches letters and numbers
	if regex.search(str(your_string)):
		return true
	else:
		return false

func set_score(score):
	$Score.text = "SCORE: " + str(snapped(score, 1))

func add_year(year):
	death_message += str(snapped(year, 1))


func _process(delta: float) -> void:
	if (!active):
		for i in get_child_count():
			var color = get_child(i).get_self_modulate()
			color.a = color.a - 0.01
			get_child(i).set_self_modulate(color)
	else:
		for i in get_child_count():
			var color = get_child(i).get_self_modulate()
			color.a = color.a + 0.01
			get_child(i).set_self_modulate(color)


func _on_reset_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
