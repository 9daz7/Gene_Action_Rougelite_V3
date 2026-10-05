extends Node
class_name ActionPlayerCharacterController


# ==================================================
# Movement
# ==================================================

@export var move_speed: float = 200.0
@export var sprint_speed: float = 300.0
@export var crouch_speed: float = 100.0
@export var attack_move_speed: float = 50.0


# ==================================================
# State
# ==================================================

var is_sprinting: bool = false
var is_crouching: bool = false

var facing_direction: Vector2 = Vector2.RIGHT


# ==================================================
# Interaction
# ==================================================

var nearby_interactable: Interactable = null

@onready var interaction_prompt: InteractionPrompt = (
	get_parent().get_node_or_null("InteractionPrompt")
)


# ==================================================
# References
# ==================================================

var player_character: CharacterBody2D
var animated_sprite: AnimatedSprite2D
var deebo_controller: ActionPlayerController
var player_combat_controller: ActionPlayerCombatController


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

	var interaction_area: Area2D = (
		get_parent().get_node_or_null("InteractionArea")
	)

	if interaction_area != null:

		if not interaction_area.area_entered.is_connected(
			_on_interaction_area_entered
		):

			interaction_area.area_entered.connect(
				_on_interaction_area_entered
			)

		if not interaction_area.area_exited.is_connected(
			_on_interaction_area_exited
		):

			interaction_area.area_exited.connect(
				_on_interaction_area_exited
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

	_handle_interaction()

	_update_animation(direction)


# ==================================================
# Movement Speed
# ==================================================

func _get_current_move_speed() -> float:

	if player_combat_controller != null:

		if player_combat_controller.attack_state != (
			player_combat_controller.AttackState.IDLE
		):

			return attack_move_speed

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


# ==================================================
# Interaction
# ==================================================

func _handle_interaction() -> void:

	if not Input.is_action_just_pressed("interact"):
		return

	if nearby_interactable == null:
		return

	nearby_interactable.interact()


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


func _on_interaction_area_entered(
	area: Area2D
) -> void:

	if area is Interactable:

		set_nearby_interactable(area)


func _on_interaction_area_exited(
	area: Area2D
) -> void:

	if area == nearby_interactable:

		set_nearby_interactable(null)


func _hide_interaction_prompt() -> void:

	if interaction_prompt != null:

		interaction_prompt.hide_prompt()


func set_deebo_controller(
	controller: ActionPlayerController
) -> void:

	deebo_controller = controller


func set_player_combat_controller(
	controller: ActionPlayerCombatController
) -> void:

	player_combat_controller = controller
