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

	heal_button.gui_input.connect(
		_on_button_gui_input.bind("HealButton")
	)

	leave_button.gui_input.connect(
		_on_button_gui_input.bind("LeaveButton")
	)

# temp func
func _on_button_gui_input(
	event: InputEvent,
	button_name: String
) -> void:

	if event is InputEventMouseButton and event.pressed:
		print("BUTTON GUI INPUT: ", button_name, " | ", event)

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

	print(
		"HOVERED CONTROL: ",
		get_viewport().gui_get_hovered_control()
	)
	print(
		"HEAL | visible: ", heal_button.is_visible_in_tree(),
		" | disabled: ", heal_button.disabled,
		" | mouse_filter: ", heal_button.mouse_filter
	)
	print(
		"LEAVE | visible: ", leave_button.is_visible_in_tree(),
		" | disabled: ", leave_button.disabled,
		" | mouse_filter: ", leave_button.mouse_filter
	)

# ==================================================
# Leave
# ==================================================


func _leave_pressed() -> void:

	print("REST UI: LEAVE BUTTON PRESSED")
	rest_finished.emit()
