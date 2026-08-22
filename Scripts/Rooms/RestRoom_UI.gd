extends Control
class_name RestRoom_UI


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

var run_manager: RunManager = null
var healed: bool = false


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	if not heal_button.pressed.is_connected(
		_heal_pressed
	):

		heal_button.pressed.connect(
			_heal_pressed
	)

	if not leave_button.pressed.is_connected(
		_leave_pressed
	):

		leave_button.pressed.connect(
			_leave_pressed
	)


# ==================================================
# Public Functions
# ==================================================


func open(
	manager: RunManager
) -> void:

	if manager == null:

		push_error(
			"RestRoom_UI: RunManager is missing."
		)

		return

	run_manager = manager

	show()

	healed = false

	heal_button.disabled = false


func close():

	hide()


# ==================================================
# Rest
# ==================================================


func _heal_pressed() -> void:

	if healed:
		return

	if run_manager == null:
		push_error(
			"RestRoom_UI: RunManager is missing."
		)

		return

	var heal_amount: int = int(
		run_manager.max_hp * 0.35
	)

	run_manager.heal_player(
		heal_amount
	)

	healed = true

	print(
		"Rest healed player for:",
		heal_amount
	)

	heal_button.disabled = true


# ==================================================
# Leave
# ==================================================


func _leave_pressed() -> void:

	rest_finished.emit()
