extends Control
class_name RestRoom


# ==================================================
# Signals
# ==================================================

signal rest_finished


# ==================================================
# Onready Variables
# ==================================================

@onready var heal_button = $CenterContainer/VBoxContainer/HealButton
@onready var leave_button = $CenterContainer/VBoxContainer/LeaveButton


# ==================================================
# Member Variables
# ==================================================

var run_manager: RunManager

var healed := false


# ==================================================
# Initialization
# ==================================================


func _ready():

	heal_button.pressed.connect(
		_heal_pressed
	)

	leave_button.pressed.connect(
		_leave_pressed
	)


# ==================================================
# Public Functions
# ==================================================


func open(manager:RunManager):

	run_manager = manager

	show()

	healed = false

	heal_button.disabled = false


func close():

	hide()


# ==================================================
# Private Functions
# ==================================================


func _heal_pressed():

	if healed:
		return

	if run_manager == null:
		print("ERROR: RunManager not found")
		return

	var heal_amount = int(run_manager.max_hp * 0.35)

	run_manager.heal_player(heal_amount)

	healed = true

	print("Rest healed player")

	heal_button.disabled = true


func _leave_pressed():

	rest_finished.emit()

	queue_free()
