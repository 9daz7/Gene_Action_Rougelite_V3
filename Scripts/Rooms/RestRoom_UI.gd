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

var player_character: CharacterBody3D = null
var deebo_character: CharacterBody3D = null


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
	manager: RunManager,
	player_ref: CharacterBody3D,
	deebo_ref: CharacterBody3D
) -> void:

	if manager == null:
		push_error(
			"RestRoom_UI: RunManager is missing."
		)
		return

	if player_ref == null or deebo_ref == null:
		push_error("RestRoom_UI: Player or Deebo reference is missing.")
		return

	run_manager = manager
	player_character = player_ref
	deebo_character = deebo_ref

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

	if not is_instance_valid(player_character):
		push_error("RestRoom_UI: Player reference is invalid.")
		return

	if not is_instance_valid(deebo_character):
		push_error("RestRoom_UI: Deebo reference is invalid.")
		return

	var player_heal: float = player_character.max_health * 0.35
	var deebo_heal: float = deebo_character.max_health * 0.35

	player_character.heal(player_heal)
	deebo_character.heal(deebo_heal)

	healed = true
	heal_button.disabled = true

	print(
		"REST COMPLETE | Player: ",
		player_character.current_health,
		"/",
		player_character.max_health,
		" | Deebo: ",
		deebo_character.current_health,
		"/",
		deebo_character.max_health
	)


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
