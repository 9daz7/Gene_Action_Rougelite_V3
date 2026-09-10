extends Node
class_name ActionEnemyController


# ==================================================
# Movement
# ==================================================

@export var move_speed_multiplier: float = 25.0

@export var chase_range: float = 500.0

@export var stop_distance: float = 70.0


# ==================================================
# Combat
# ==================================================

@export var attack_range: float = 80.0

@export var attack_cooldown: float = 1.5

var attack_timer: float = 0.0


# ==================================================
# References
# ==================================================

var enemy: AnimalBase
var target: AnimalBase


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	enemy = get_parent() as AnimalBase

	if enemy == null:

		push_error(
			"ActionEnemyController must be a child "
			+ "of a CharacterBody2D."
		)

		return

	print("ActionEnemyController ready")


# ==================================================
# Physics
# ==================================================

func _physics_process(delta: float) -> void:

	if enemy == null:
		return

	if target == null:
		return

	if not target.is_alive():
		enemy.velocity = Vector2.ZERO
		return

	# --------------------------------------------------
	# Update attack cooldown
	# --------------------------------------------------

	if attack_timer > 0.0:

		attack_timer -= delta

		if attack_timer < 0.0:
			attack_timer = 0.0

	# --------------------------------------------------
	# Calculate distance
	# --------------------------------------------------

	var distance := enemy.global_position.distance_to(
		target.global_position
	)

	# --------------------------------------------------
	# Outside chase range
	# --------------------------------------------------

	if distance > chase_range:

		enemy.velocity = Vector2.ZERO
		enemy.move_and_slide()

		return

	# --------------------------------------------------
	# Attack range
	# --------------------------------------------------

	if distance <= attack_range:

		enemy.velocity = Vector2.ZERO
		enemy.move_and_slide()

		_try_attack()

		return

	# --------------------------------------------------
	# Chase target
	# --------------------------------------------------

	var direction := (
		target.global_position
		- enemy.global_position
	).normalized()

	var animal_speed := 10.0

	if enemy.has_method("get_speed"):
		animal_speed = enemy.get_speed()

	enemy.velocity = (
		direction
		* animal_speed
		* move_speed_multiplier
	)

	enemy.move_and_slide()


# ==================================================
# Combat
# ==================================================

func _try_attack() -> void:

	if attack_timer > 0.0:
		return

	if not enemy.has_method("get_battle_moves"):
		push_warning(
			"Enemy does not have get_battle_moves()."
		)
		return

	var moves = enemy.get_battle_moves()

	if moves.is_empty():
		push_warning(
			"Enemy has no battle moves available."
		)
		return

	var attack_move = _find_attack_move(moves)

	if attack_move == null:
		push_warning(
			"Enemy has no usable attack move."
		)
		return

	print(
		"========================================"
	)
	print(
		"ENEMY ATTACK"
	)
	print(
		"========================================"
	)
	print(
		enemy.name,
		" uses ",
		attack_move.move_name
	)

	attack_timer = attack_cooldown

	attack_move.execute(
		enemy,
		target
	)


# ==================================================
# Attack Selection
# ==================================================

func _find_attack_move(moves: Array) -> MoveResource:

	for move in moves:

		if move == null:
			continue

		# --------------------------------------------------
		# Offensive Damage Move
		# --------------------------------------------------

		if move.effect_type == MoveResource.MoveEffectType.DAMAGE:
			return move

		# --------------------------------------------------
		# Hybrid Offensive Move
		# --------------------------------------------------

		if move.effect_type == MoveResource.MoveEffectType.HYBRID:
			return move

	return null
