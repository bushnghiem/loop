extends Node
signal zero_health
signal maxhp

@export var max_health : float
var current_health : float

func _ready() -> void:
	current_health = max_health

func set_health(amount):
	current_health = amount

func damage(amount):
	current_health = current_health - amount
	if (current_health <= 0):
		zero_health.emit()
		#print("zero hp")
		

func heal(amount):
	current_health = current_health + amount
	if (current_health >= max_health):
		current_health = max_health
		maxhp.emit()
		#print("max hp")
