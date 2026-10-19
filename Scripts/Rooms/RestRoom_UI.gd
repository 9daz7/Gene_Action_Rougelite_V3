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

	print("REST UI READY")
	print("Heal button:", heal_button)
	print("Leave button:", leave_button)

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

	print("REST UI: HEAL BUTTON PRESSED")

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


func _input(event: InputEvent) -> void:

	if event is InputEventMouseButton and event.pressed:
		print(
			"MOUSE CLICK:",
			event.position,
			"| REST UI RECT:",
			get_global_rect(),
			"| HEAL RECT:",
			heal_button.get_global_rect(),
			"| LEAVE RECT:",
			leave_button.get_global_rect()
		)

# ==================================================
# Leave
# ==================================================


func _leave_pressed() -> void:

	rest_finished.emit()
