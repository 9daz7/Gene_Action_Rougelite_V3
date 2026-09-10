extends Node
class_name ActionPlayerController


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


# ==================================================
# References
# ==================================================

var player: CharacterBody2D


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	player = get_parent() as CharacterBody2D

	if player == null:

		push_error(
			"ActionPlayerController must be a child of "
			+ "a CharacterBody2D."
		)

		return

	print("ActionPlayerController ready")


# ==================================================
# Physics
# ==================================================

func _physics_process(_delta: float) -> void:

	if player == null:
		return


	# ==================================================
	# Movement Input
	# ==================================================

	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)


	# ==================================================
	# Sprint / Crouch
	# ==================================================

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


	# ==================================================
	# Move
	# ==================================================

	player.velocity = (
		direction
		* _get_current_move_speed()
	)

	player.move_and_slide()


# ==================================================
# Movement Speed
# ==================================================

func _get_current_move_speed() -> float:

	if is_sprinting:

		return sprint_speed

	if is_crouching:

		return crouch_speed

	return move_speed
