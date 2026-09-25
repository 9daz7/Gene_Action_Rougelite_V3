extends Node
class_name ActionPlayerCharacterController


# ==================================================
# Movement
# ==================================================

@export var move_speed: float = 200.0
@export var sprint_speed: float = 300.0
@export var crouch_speed: float = 100.0
@export var attack_move_speed: float = 100.0


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
var animated_sprite: AnimatedSprite2D
var deebo_controller: ActionPlayerController


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

	animated_sprite = player_character.get_node_or_null(
		"AnimatedSprite2D"
	)

	if animated_sprite == null:

		push_error(
			"AnimatedSprite2D not found on "
			+ "ActionPlayerCharacter."
		)

	print("ActionPlayerCharacterController ready")


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

	_update_animation(direction)


# ==================================================
# Movement Speed
# ==================================================

func _get_current_move_speed() -> float:

	if deebo_controller != null:

		if deebo_controller.attack_state != (
			deebo_controller.AttackState.IDLE
		):

			return attack_move_speed

	if is_sprinting:
		return sprint_speed

	if is_crouching:
		return crouch_speed

	return move_speed


# ==================================================
# Animation
# ==================================================

func _update_animation(direction: Vector2) -> void:

	if animated_sprite == null:
		return

	if direction == Vector2.ZERO:

		animated_sprite.stop()

		return

	# --------------------------------------------------
	# Horizontal movement
	# --------------------------------------------------

	if abs(direction.x) > abs(direction.y):

		animated_sprite.play("walk_side")

		animated_sprite.flip_h = (
			direction.x < 0.0
		)

		return

	# --------------------------------------------------
	# Down
	# --------------------------------------------------

	if direction.y > 0.0:

		animated_sprite.play("walk_down")
		animated_sprite.flip_h = false

		return

	# --------------------------------------------------
	# Up
	# --------------------------------------------------

	animated_sprite.play("walk_up")
	animated_sprite.flip_h = false


func set_deebo_controller(
	controller: ActionPlayerController
) -> void:

	deebo_controller = controller
