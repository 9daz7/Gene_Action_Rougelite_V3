extends CharacterBody2D
class_name RoomPlayer


# ==================================================
# Movement
# ==================================================

@export var move_speed: float = 200.0


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


# ==================================================
# Physics
# ==================================================

func _physics_process(_delta: float) -> void:

	if not controls_enabled:
		velocity = Vector2.ZERO
		_hide_interaction_prompt()
		return
		
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * move_speed

	move_and_slide()	

	_handle_interaction()


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

		_hide_interaction_prompt()

	print(
		"RoomPlayer controls:",
		controls_enabled
	)
