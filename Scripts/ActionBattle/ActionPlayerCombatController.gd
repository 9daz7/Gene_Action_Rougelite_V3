extends Node
class_name ActionPlayerCombatController


# ==================================================
# References
# ==================================================

var player_character: CharacterBody2D = null

@onready var aim_line: Line2D = get_parent().get_node_or_null(
	"AimLine"
)


# ==================================================
# Aim State
# ==================================================

var is_aiming: bool = false
var aim_direction: Vector2 = Vector2.RIGHT


# ==================================================
# Setup
# ==================================================

func _ready() -> void:

	player_character = get_parent() as CharacterBody2D

	if player_character == null:

		push_error(
			"ActionPlayerCombatController must be "
			+ "a child of a CharacterBody2D."
		)

		return

	if aim_line == null:

		push_error(
			"AimLine not found on ActionPlayerCharacter."
		)

		return

	aim_line.visible = false

	print("ActionPlayerCombatController ready")


# ==================================================
# Input
# ==================================================

func _input(event: InputEvent) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_RIGHT:

			if event.pressed:

				is_aiming = true

			else:

				is_aiming = false


# ==================================================
# Process
# ==================================================

func _process(_delta: float) -> void:

	if player_character == null:
		return

	if not is_aiming:

		aim_line.visible = false
		return

	_update_aim()


# ==================================================
# Aim
# ==================================================

func _update_aim() -> void:

	var mouse_position := (
		player_character.get_global_mouse_position()
	)

	aim_direction = (
		mouse_position
		- player_character.global_position
	).normalized()

	aim_line.visible = true

	aim_line.points = PackedVector2Array([
		Vector2.ZERO,
		aim_direction * 200.0
	])
