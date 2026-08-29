extends CharacterBody2D
class_name HubPlayer


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
# Interaction
# ==================================================

var nearby_interactable: Interactable = null


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("HubPlayer ready")

	pass


# ==================================================
# Physics
# ==================================================


func _physics_process(_delta: float) -> void:

	var hub_world := get_parent()

	if hub_world is HubWorld and not hub_world.is_open:

		velocity = Vector2.ZERO

		is_sprinting = false
		is_crouching = false

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

	velocity = direction * _get_current_move_speed()

	move_and_slide()

	_handle_interaction()


# ==================================================
# Movement Speed
# ==================================================

func _get_current_move_speed() -> float:

	if is_sprinting:

		return sprint_speed

	if is_crouching:

		return crouch_speed

	return move_speed


# ==================================================
# Interaction
# ==================================================

func _handle_interaction() -> void:

	if not Input.is_action_just_pressed("interact"):
		return

	if nearby_interactable == null:
		return

	nearby_interactable.interact()


# ==================================================
# Interaction Detection
# ==================================================

func set_nearby_interactable(
	interactable: Interactable
) -> void:

	nearby_interactable = interactable
