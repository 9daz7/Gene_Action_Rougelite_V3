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

@export var attack_prime_time: float = 0.3
@export var attack_lunge_distance: float = 100.0
@export var attack_lunge_duration: float = 0.12
@export var attack_recovery_time: float = 0.5

var attack_timer: float = 0.0

enum AttackState {
	IDLE,
	PRIMING,
	LUNGING,
	RECOVERING
}

var attack_state: AttackState = AttackState.IDLE

var attack_start_position: Vector2
var attack_target_position: Vector2
var attack_move: MoveResource = null

var attack_prime_timer: float = 0.0
var attack_lunge_timer: float = 0.0
var attack_recovery_timer: float = 0.0


# ==================================================
# Knockback
# ==================================================

@export var knockback_duration: float = 0.08

var is_knocked_back: bool = false
var knockback_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO


# ==================================================
# References
# ==================================================

var enemy: AnimalBase
var target: AnimalBase

var enemy_sprite: Sprite2D
var original_sprite_scale: Vector2


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

	enemy_sprite = enemy.get_node_or_null(
		"EnemySprite"
	) as Sprite2D

	if enemy_sprite != null:
		original_sprite_scale = enemy_sprite.scale


# ==================================================
# Physics
# ==================================================

func _physics_process(delta: float) -> void:

	if enemy == null:
		return

	if not target.is_alive():
		enemy.velocity = Vector2.ZERO
		return

	if is_knocked_back:
		_update_knockback(delta)
		return

	if attack_state != AttackState.IDLE:
		_update_attack_state(delta)
		return

	if not enemy.is_alive():
		enemy.velocity = Vector2.ZERO
		return

	if target == null:
		return

	if not target.is_alive():
		enemy.velocity = Vector2.ZERO
		attack_state = AttackState.IDLE
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

	if distance > chase_range and not is_alerted:

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

	#if is_alerted:
		#print(
			#enemy.name,
			#" ALERTED CHASING ",
			#target.name,
			#" | Distance: ",
			#distance
		#)

	enemy.velocity = (
		direction
		* animal_speed
		* move_speed_multiplier
	)

	enemy.move_and_slide()


# ==================================================
# Knockback
# ==================================================

func _update_knockback(delta: float) -> void:

	knockback_timer += delta

	enemy.velocity = knockback_velocity

	enemy.move_and_slide()

	knockback_velocity = (
		knockback_velocity.move_toward(
			Vector2.ZERO,
			knockback_velocity.length()
			/
			knockback_duration
			*
			delta
		)
	)

	if knockback_timer >= knockback_duration:

		knockback_timer = 0.0
		knockback_velocity = Vector2.ZERO
		is_knocked_back = false

		print(
			enemy.name,
			" KNOCKBACK COMPLETE"
		)


func apply_knockback(
	direction: Vector2,
	distance: float
) -> void:

	if enemy == null:
		return

	if not enemy.is_alive():
		return

	if direction == Vector2.ZERO:
		return

	var duration := knockback_duration

	var speed := (
		distance
		/
		duration
	)

	knockback_velocity = (
		direction.normalized()
		*
		speed
	)

	knockback_timer = 0.0
	is_knocked_back = true

	print(
		enemy.name,
		" KNOCKBACK START"
	)



var is_alerted: bool = false

# ==================================================
# Alert / Aggro
# ==================================================

func alert_to_attacker(attacker: AnimalBase) -> void:

	if enemy == null:
		return

	if attacker == null:
		return

	if not attacker.is_alive():
		return

	target = attacker
	is_alerted = true

	print(
		enemy.name,
		" ALERTED BY: ",
		attacker.name
	)


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

	var selected_move := _find_attack_move(moves)

	if selected_move == null:
		push_warning(
			"Enemy has no usable attack move."
		)
		return

	attack_move = selected_move

	print(
		"========================================"
	)
	print(
		"ENEMY ATTACK PRIME"
	)
	print(
		"========================================"
	)
	print(
		enemy.name,
		" prepares ",
		attack_move.move_name
	)

	attack_timer = attack_cooldown

	attack_prime_timer = 0.0
	attack_state = AttackState.PRIMING


# ==================================================
# Attack State
# ==================================================

func _update_attack_state(delta: float) -> void:

	if not enemy.is_alive():

		enemy.velocity = Vector2.ZERO

		attack_state = AttackState.IDLE

		attack_move = null

		print(
			enemy.name,
			" ATTACK CANCELLED - ENEMY DEAD"
		)

		return

	match attack_state:

		AttackState.PRIMING:

			enemy.velocity = Vector2.ZERO
			enemy.move_and_slide()

			attack_prime_timer += delta

			if attack_prime_timer >= attack_prime_time:

				_start_attack_lunge()


		AttackState.LUNGING:

			attack_lunge_timer += delta

			var progress := (
				attack_lunge_timer
				/
				attack_lunge_duration
			)

			progress = clamp(progress, 0.0, 1.0)

			enemy.global_position = (
				attack_start_position.lerp(
					attack_target_position,
					progress
				)
			)

			if progress >= 1.0:

				_execute_attack_hit()

				attack_state = AttackState.RECOVERING
				attack_recovery_timer = 0.0


		AttackState.RECOVERING:

			enemy.velocity = Vector2.ZERO
			enemy.move_and_slide()

			attack_recovery_timer += delta

			if attack_recovery_timer >= attack_recovery_time:

				attack_state = AttackState.IDLE

				print(
					enemy.name,
					" ATTACK RECOVERY COMPLETE"
				)


func _start_attack_lunge() -> void:

	if target == null:
		attack_state = AttackState.IDLE
		return

	if not target.is_alive():
		attack_state = AttackState.IDLE
		return

	print(
		enemy.name,
		" LUNGES AT ",
		target.name
	)

	attack_start_position = enemy.global_position

	var direction := (
		target.global_position
		-
		enemy.global_position
	).normalized()

	attack_target_position = (
		attack_start_position
		+
		direction
		*
		attack_lunge_distance
	)

	attack_lunge_timer = 0.0
	attack_state = AttackState.LUNGING


func _execute_attack_hit() -> void:

	if attack_move == null:
		return

	if target == null:
		return

	if not is_instance_valid(target):
		return

	if not target.is_alive():
		return

	var distance := enemy.global_position.distance_to(
		target.global_position
	)

	print(
		enemy.name,
		" BITE HIT CHECK | Distance: ",
		distance
	)

	if distance > attack_range:
		print(
			enemy.name,
			" MISSED!"
		)
		return

	print(
		"========================================"
	)
	print(
		"ENEMY ATTACK CONNECTED"
	)
	print(
		"========================================"
	)
	print(
		enemy.name,
		" uses ",
		attack_move.move_name
	)

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
