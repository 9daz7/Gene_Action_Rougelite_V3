extends CharacterBody2D
class_name RoomPlayer


# ==================================================
# Movement
# ==================================================

@export var move_speed: float = 200.0

@export var sprint_speed: float = 300.0
@export var crouch_speed: float = 100.0


# ==================================================
# Detection
# ==================================================

@export var normal_detection_multiplier: float = 1.0
@export var sprint_detection_multiplier: float = 1.5
@export var crouch_detection_multiplier: float = 0.5


# ==================================================
# Camera
# ==================================================

@onready var camera: Camera2D = $Camera2D


# ==================================================
# Interaction
# ==================================================

@onready var interaction_prompt: InteractionPrompt = $InteractionPrompt

var nearby_interactable: Interactable = null


# ==================================================
# State
# ==================================================

var controls_enabled: bool = true

var is_sprinting: bool = false
var is_crouching: bool = false

var detection_multiplier: float = 1.0


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("RoomPlayer ready")

	if camera != null:

		camera.make_current()

		print(
			"RoomPlayer camera current:",
			camera.is_current()
		)

	if interaction_prompt != null:

		interaction_prompt.hide_prompt()

	_update_movement_state()


# ==================================================
# Physics
# ==================================================

func _physics_process(_delta: float) -> void:

	if not controls_enabled:

		velocity = Vector2.ZERO

		is_sprinting = false
		is_crouching = false

		_update_movement_state()

		_hide_interaction_prompt()

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

	_update_movement_state()

	# ==================================================
	# Move
	# ==================================================

	velocity = direction * _get_current_move_speed()

	move_and_slide()	

	_handle_interaction()


# ==================================================
# Movement State
# ==================================================

func _update_movement_state() -> void:

	if is_sprinting:

		detection_multiplier = (
			sprint_detection_multiplier
		)

	elif is_crouching:

		detection_multiplier = (
			crouch_detection_multiplier
		)

	else:

		detection_multiplier = (
			normal_detection_multiplier
		)


func _get_current_move_speed() -> float:

	if is_sprinting:

		return sprint_speed

	if is_crouching:

		return crouch_speed

	return move_speed


# ==================================================
# Detection
# ==================================================

func get_detection_multiplier() -> float:

	return detection_multiplier


# ==================================================
# Interaction
# ==================================================

func _handle_interaction() -> void:

	if nearby_interactable == null:
		return

	if not Input.is_action_just_pressed(
		"interact"
	):

		return

	nearby_interactable.interact()


# ==================================================
# Interaction Detection
# ==================================================

func set_nearby_interactable(
	interactable: Interactable
) -> void:

	nearby_interactable = interactable

	if interaction_prompt == null:
		return

	if nearby_interactable == null:

		interaction_prompt.hide_prompt()

	else:

		interaction_prompt.show_prompt(
			nearby_interactable.interaction_text
		)


# ==================================================
# Interaction Prompt
# ==================================================

func _hide_interaction_prompt() -> void:

	if interaction_prompt != null:

		interaction_prompt.hide_prompt()


# ==================================================
# Controls
# ==================================================

func set_controls_enabled(
	enabled: bool
) -> void:

	controls_enabled = enabled

	if not enabled:

		velocity = Vector2.ZERO

		is_sprinting = false
		is_crouching = false

		_update_movement_state()

		_hide_interaction_prompt()

	print(
		"RoomPlayer controls:",
		controls_enabled
	)
