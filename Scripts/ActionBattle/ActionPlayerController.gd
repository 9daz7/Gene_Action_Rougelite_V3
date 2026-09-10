extends Node
class_name ActionPlayerController


# ==================================================
# Movement
# ==================================================

@export var move_speed: float = 200.0
@export var sprint_speed: float = 300.0
@export var crouch_speed: float = 100.0


# ==================================================
# Combat
# ==================================================

var selected_target: AnimalBase = null


# ==================================================
# State
# ==================================================

var is_sprinting: bool = false
var is_crouching: bool = false


# ==================================================
# References
# ==================================================

var player: AnimalBase


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	player = get_parent() as AnimalBase

	if player == null:

		push_error(
			"ActionPlayerController must be a child of "
			+ "an AnimalBase."
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
	# Attack Input
	# ==================================================

	if Input.is_action_just_pressed("attack"):

		_try_attack()


# ==================================================
# Attack
# ==================================================

func _try_attack() -> void:

	print("PLAYER ATTACK INPUT")

	var targeting = get_parent().get_parent().get_node_or_null(
		"ActionTargeting"
	)

	if targeting == null:

		push_warning(
			"ActionTargeting node not found."
		)

		return

	selected_target = targeting.get_selected_target()

	if selected_target == null:

		print("NO TARGET SELECTED")

		return

	if not selected_target.is_alive():

		print("TARGET IS DEAD")

		return

	print(
		"PLAYER TARGET:",
		selected_target.name
	)

	var attack_move := _find_attack_move()

	if attack_move == null:

		push_warning(
			"Player has no usable attack move."
		)

		return

	print(
		"PLAYER USES:",
		attack_move.move_name
	)

	attack_move.execute(
		player,
		selected_target
	)


# ==================================================
# Attack Selection
# ==================================================

func _find_attack_move() -> MoveResource:

	if not player.has_method("get_battle_moves"):

		push_warning(
			"Player does not have get_battle_moves()."
		)

		return null

	var moves = player.get_battle_moves()

	if moves.is_empty():

		push_warning(
			"Player has no battle moves."
		)

		return null

	for move in moves:

		if move == null:
			continue

		if move.effect_type == MoveResource.MoveEffectType.DAMAGE:

			return move

		if move.effect_type == MoveResource.MoveEffectType.HYBRID:

			return move

	return null


# ==================================================
# Movement Speed
# ==================================================

func _get_current_move_speed() -> float:

	if is_sprinting:
		return sprint_speed

	if is_crouching:
		return crouch_speed

	return move_speed
