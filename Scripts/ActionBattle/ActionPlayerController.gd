extends Node
class_name ActionPlayerController


# ==================================================
# Movement
# ==================================================

@export var move_speed: float = 200.0
@export var sprint_speed: float = 300.0
@export var crouch_speed: float = 100.0


# ==================================================
# Attack
# ==================================================

@export var attack_recovery: float = 0.5
@export var attack_lunge_distance: float = 70.0
@export var attack_lunge_duration: float = 0.12
@export var attack_return_duration: float = 0.10
@export var attack_knockback_distance: float = 35.0
@export var attack_knockback_duration: float = 0.08


# ==================================================
# Attack state
# ==================================================

enum AttackState {
	IDLE,
	LUNGING,
	#KNOCKBACK,
	RETURNING,
	RECOVERING
}

var attack_state: AttackState = AttackState.IDLE

var attack_recovery_timer: float = 0.0
var attack_timer: float = 0.0

#var knockback_timer: float = 0.0
#var knockback_start_position: Vector2
#var knockback_target_position: Vector2

var attack_start_position: Vector2
var attack_target_position: Vector2

var selected_target: AnimalBase = null
var attack_move: MoveResource = null


# ==================================================
# Movement state
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

func _physics_process(delta: float) -> void:

	if player == null:
		return

	_update_attack_state(delta)

	_handle_movement()

	if Input.is_action_just_pressed("attack"):
		_try_attack()


# ==================================================
# Attack State
# ==================================================

func _update_attack_state(delta: float) -> void:

	match attack_state:

		AttackState.IDLE:
			pass

		AttackState.LUNGING:

			attack_timer += delta

			var progress := (
				attack_timer
				/ attack_lunge_duration
			)

			progress = clamp(
				progress,
				0.0,
				1.0
			)

			player.global_position = (
				attack_start_position.lerp(
					attack_target_position,
					progress
				)
			)

			if progress >= 1.0:

				await _execute_attack()

				attack_state = AttackState.RETURNING
				attack_timer = 0.0

		#AttackState.KNOCKBACK:
#
			#knockback_timer += delta
#
			#var progress := (
				#knockback_timer
				#/ attack_knockback_duration
			#)
#
			#progress = clamp(
				#progress,
				#0.0,
				#1.0
			#)
#
			#if selected_target != null:
				#if is_instance_valid(selected_target):
#
					#selected_target.global_position = (
						#knockback_start_position.lerp(
							#knockback_target_position,
							#progress
						#)
					#)
#
			#if progress >= 1.0:
#
				#attack_state = AttackState.RETURNING
				#attack_timer = 0.0

		AttackState.RETURNING:

			attack_timer += delta

			var progress := (
				attack_timer
				/ attack_return_duration
			)

			progress = clamp(
				progress,
				0.0,
				1.0
			)

			player.global_position = (
				attack_target_position.lerp(
					attack_start_position,
					progress
				)
			)

			if progress >= 1.0:

				player.global_position = (
					attack_start_position
				)

				attack_state = (
					AttackState.RECOVERING
				)

				attack_recovery_timer = (
					attack_recovery
				)

				print(
					"PLAYER ATTACK COMPLETE - RECOVERING"
				)

		AttackState.RECOVERING:

			attack_recovery_timer -= delta

			if attack_recovery_timer <= 0.0:

				attack_recovery_timer = 0.0
				attack_state = AttackState.IDLE

				print("PLAYER READY")


# ==================================================
# Movement
# ==================================================

func _handle_movement() -> void:

	# --------------------------------------------------
	# Don't move during an attack.
	# --------------------------------------------------

	if attack_state != AttackState.IDLE:
		player.velocity = Vector2.ZERO
		return

	# --------------------------------------------------
	# Normal movement.
	# --------------------------------------------------

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
# Attack
# ==================================================

func _try_attack() -> void:

	print("PLAYER ATTACK INPUT")

	# --------------------------------------------------
	# Only allow attacks while idle.
	# --------------------------------------------------

	if attack_state != AttackState.IDLE:

		print("PLAYER CANNOT ATTACK - NOT READY")

		return

	# --------------------------------------------------
	# Find targeting system.
	# --------------------------------------------------

	var targeting = (
		get_parent()
		.get_parent()
		.get_node_or_null("ActionTargeting")
	)

	if targeting == null:

		push_warning(
			"ActionTargeting node not found."
		)

		return

	# --------------------------------------------------
	# Get selected target.
	# --------------------------------------------------

	selected_target = (
		targeting.get_selected_target()
	)

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

	# --------------------------------------------------
	# Find attack move.
	# --------------------------------------------------

	attack_move = _find_attack_move()

	if attack_move == null:

		push_warning(
			"Player has no usable attack move."
		)

		return

	print(
		"PLAYER USES:",
		attack_move.move_name
	)

	# --------------------------------------------------
	# Store attack position.
	# --------------------------------------------------

	attack_start_position = (
		player.global_position
	)

	# --------------------------------------------------
	# Calculate lunge position.
	# --------------------------------------------------

	var direction := (
		selected_target.global_position
		- player.global_position
	).normalized()

	attack_target_position = (
		player.global_position
		+
		direction
		*
		attack_lunge_distance
	)

	# --------------------------------------------------
	# Start lunge.
	# --------------------------------------------------

	attack_state = AttackState.LUNGING
	attack_timer = 0.0

	print(
		"PLAYER LUNGE START"
	)


# ==================================================
# Execute Attack
# ==================================================

func _execute_attack() -> void:

	if attack_move == null:
		return

	if selected_target == null:
		return

	if not is_instance_valid(selected_target):
		return

	if not selected_target.is_alive():

		print(
			"TARGET DIED BEFORE ATTACK CONNECTED"
		)

		return

	print(
		"PLAYER ATTACK CONNECTED"
	)

	print(
		"PLAYER USES:",
		attack_move.move_name
	)

	await attack_move.execute(
		player,
		selected_target
	)

	_apply_enemy_knockback()


func _apply_enemy_knockback() -> void:

	print("========================================")
	print("APPLY ENEMY KNOCKBACK")
	print("========================================")

	if selected_target == null:

		print("KNOCKBACK FAILED: No selected target")
		return

	print(
		"Selected target:",
		selected_target.name
	)

	if not is_instance_valid(selected_target):

		print(
			"KNOCKBACK FAILED: Target is invalid"
		)

		return

	if not selected_target.is_alive():

		print(
			"KNOCKBACK FAILED: Target is dead"
		)

		return

	var controller := selected_target.get_node_or_null(
		"ActionEnemyController"
	)

	print(
		"Enemy controller found:",
		controller
	)

	if controller == null:

		print(
			"KNOCKBACK FAILED: "
			+ "ActionEnemyController not found"
		)

		print(
			"Target children:"
		)

		for child in selected_target.get_children():

			print(
				" - ",
				child.name,
				" | ",
				child.get_class()
			)

		return

	var direction := (
		selected_target.global_position
		- player.global_position
	).normalized()

	print(
		"Knockback direction:",
		direction
	)

	print(
		"Knockback distance:",
		attack_knockback_distance
	)

	if controller.has_method("apply_knockback"):

		print(
			"Calling ActionEnemyController.apply_knockback()"
		)

		controller.apply_knockback(
			direction,
			attack_knockback_distance
		)

	else:

		print(
			"KNOCKBACK FAILED: "
			+ "apply_knockback() not found"
		)

#func _start_knockback() -> void:
#
	#if selected_target == null:
		#return
#
	#if not is_instance_valid(selected_target):
		#return
#
	#if not selected_target.is_alive():
		#return
#
	#var direction := (
		#selected_target.global_position
		#- player.global_position
	#).normalized()
#
	#knockback_start_position = (
		#selected_target.global_position
	#)
#
	#knockback_target_position = (
		#knockback_start_position
		#+
		#direction
		#*
		#attack_knockback_distance
	#)
#
	#knockback_timer = 0.0
#
	#attack_state = AttackState.KNOCKBACK
#
	#print("ENEMY KNOCKBACK START")
#

# ==================================================
# Attack Selection
# ==================================================

func _find_attack_move() -> MoveResource:

	if not player.has_method("get_battle_moves"):

		push_warning(
			"Player does not have "
			+ "get_battle_moves()."
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
