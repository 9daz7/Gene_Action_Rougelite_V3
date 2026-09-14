extends Node
class_name ActionPlayerCharacterController


# ==================================================
# Movement
# ==================================================

@export var move_speed: float = 200.0
@export var sprint_speed: float = 300.0
@export var crouch_speed: float = 100.0


# ==================================================
# State
# ==================================================

var is_sprinting: bool = false
var is_crouching: bool = false

var facing_direction: Vector2 = Vector2.RIGHT


# ==================================================
# References
# ==================================================

var player_character: CharacterBody2D


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	player_character = get_parent() as CharacterBody2D

	if player_character == null:

		push_error(
			"ActionPlayerCharacterController must be "
			+ "a child of a CharacterBody2D."
		)

		return

	print("ActionPLayerCharacterController ready")


# ==================================================
# Physics
# ==================================================

func _physics_process(_delta: float) -> void:

	if player_character == null:
		return

	_handle_movement()


# ==================================================
# Movement
# ==================================================

func _handle_movement() -> void:

	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	# --------------------------------------------------
	# Sprint / Crouch
	# --------------------------------------------------

	is_sprinting = (
		Input.is_action_pressed("sprint")
		and
		direction != Vector2.ZERO
	)

	is_crouching = (
		Input.is_action_pressed("crouch")
		and
		not is_sprinting
	)

	# --------------------------------------------------
	# Move
	# --------------------------------------------------

	player_character.velocity = (
		direction
		* _get_current_move_speed()
	)

	if direction != Vector2.ZERO:

		facing_direction = (
			direction.normalized()
		)

	player_character.move_and_slide()


# ==================================================
# Movement Speed
# ==================================================

func _get_current_move_speed() -> float:

	if is_sprinting:
		return sprint_speed

	if is_crouching:
		return crouch_speed

	return move_speed
