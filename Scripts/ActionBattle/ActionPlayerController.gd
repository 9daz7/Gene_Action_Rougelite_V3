extends Node
class_name ActionPlayerController


# ==================================================
# Hitbox
# ==================================================

const ATTACK_HITBOX_SCENE = preload(
	"res://Scenes/Battle/ActionAttackHitbox.tscn"
)


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
	PRIMING,
	LUNGING,
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
var selected_move: MoveResource = null


# ==================================================
# Movement state
# ==================================================

var is_sprinting: bool = false
var is_crouching: bool = false

var facing_direction: Vector2 = Vector2.RIGHT


# ==================================================
# References
# ==================================================

var player: AnimalBase
var attack_area: ActionAttackArea


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

	attack_area = player.get_node_or_null(
		"AttackArea2D"
	)

	if attack_area == null:

		push_error(
			"ActionAttackArea not found on PlayerAnimal."
		)

	print("ActionPlayerController ready")


# ==================================================
# Attack Hitbox
# ==================================================

func _create_attack_hitbox() -> ActionAttackHitbox:

	var hitbox := ATTACK_HITBOX_SCENE.instantiate()

	get_tree().current_scene.add_child(hitbox)

	hitbox.global_position = (
		player.global_position
		+ facing_direction * 60.0
	)

	return hitbox


# ==================================================
# Physics
# ==================================================

func _physics_process(delta: float) -> void:

	if player == null:
		return

	_update_attack_state(delta)

	_handle_movement()

	if Input.is_action_just_pressed("select_move_1"):
		_use_move(0)

	if Input.is_action_just_pressed("select_move_2"):
		_use_move(1)

	if Input.is_action_just_pressed("select_move_3"):
		_use_move(2)


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
# Execute Attack
# ==================================================

func _execute_attack() -> void:

	if attack_move == null:
		print("ATTACK FAILED - NO MOVE")
		return

	# --------------------------------------------------
	# Check optional target
	# --------------------------------------------------

	if selected_target != null:

		if not is_instance_valid(selected_target):
			selected_target = null

		elif not selected_target.is_alive():
			selected_target = null

	# --------------------------------------------------
	# Targeted attack
	# --------------------------------------------------

	if selected_target != null:

		print(
			"PLAYER EXECUTING MOVE: ",
			attack_move.move_name,
			" ON ",
			selected_target.name
		)

		await attack_move.execute(
			player,
			selected_target
		)

		_apply_enemy_knockback()

		return

	# --------------------------------------------------
	# Untargeted attack
	# --------------------------------------------------

	if attack_area == null:

		print(
			"ATTACK MISSED - NO ATTACK AREA"
		)

		return

	var detected_enemies := (
		attack_area.get_detected_enemies()
	)

	if detected_enemies.is_empty():

		print(
			"PLAYER ATTACK MISSED - "
			+ "NO ENEMY IN ATTACK AREA"
		)

		return

	# --------------------------------------------------
	# Use the closest detected enemy.
	# --------------------------------------------------

	var closest_enemy: AnimalBase = null
	var closest_distance := INF

	for enemy in detected_enemies:

		if enemy == null:
			continue

		if not is_instance_valid(enemy):
			continue

		if not enemy.is_alive():
			continue

		var distance := (
			player.global_position
			.distance_to(enemy.global_position)
		)

		if distance < closest_distance:

			closest_distance = distance
			closest_enemy = enemy

	if closest_enemy == null:

		print(
			"PLAYER ATTACK MISSED - "
			+ "NO VALID ENEMY"
		)

		return

	# --------------------------------------------------
	# Execute attack.
	# --------------------------------------------------

	selected_target = closest_enemy

	print(
		"PLAYER EXECUTING MOVE: ",
		attack_move.move_name,
		" ON ",
		selected_target.name,
		" USING ATTACK AREA"
	)

	await attack_move.execute(
		player,
		selected_target
	)

	_apply_enemy_knockback()


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

	if direction != Vector2.ZERO:
		facing_direction = direction.normalized()

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

	selected_target = targeting.get_selected_target()

	if selected_target != null:
		if not selected_target.is_alive():
			selected_target = null

	# --------------------------------------------------
	# Find attack move.
	# --------------------------------------------------

	attack_move = selected_move

	if attack_move == null:
		push_warning("No move selected.")
		return

	print("PLAYER USES:", attack_move.move_name)

	# --------------------------------------------------
	# Store attack position.
	# --------------------------------------------------

	attack_start_position = (
		player.global_position
	)

	# --------------------------------------------------
	# Calculate lunge position.
	# --------------------------------------------------

	var direction: Vector2

	if selected_target != null:
		direction = (
			selected_target.global_position
			- player.global_position
		).normalized()
	else:
		direction = facing_direction

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


func _use_protect() -> void:

	if selected_move == null:
		return

	print("PLAYER USES PROTECT")

	await selected_move.execute(
		player,
		player
	)

	attack_state = AttackState.RECOVERING
	attack_recovery_timer = attack_recovery

	print("PLAYER PROTECT COMPLETE - RECOVERING")


func _use_move(index: int) -> void:

	if attack_state != AttackState.IDLE:
		print("PLAYER CANNOT ATTACK - NOT READY")
		return

	if not player.has_method("get_battle_moves"):
		return

	var moves = player.get_battle_moves()

	if index < 0 or index >= moves.size():
		print("NO MOVE IN SLOT ", index + 1)
		return

	var move = moves[index]

	if move == null:
		print("NO MOVE IN SLOT ", index + 1)
		return

	selected_move = move

	var test_hitbox := _create_attack_hitbox()

	print(
		"TEST HITBOX CREATED AT: ",
		test_hitbox.global_position
	)

	print("========================================")
	print("PLAYER USES MOVE")
	print("========================================")
	print("Slot:", index + 1)
	print("Move:", selected_move.move_name)

	if selected_move.effect_type == MoveResource.MoveEffectType.PROTECT:
		_use_protect()
		return
	
	_try_attack()


# ==================================================
# Execute Attack
# ==================================================

	#if attack_move == null:
		#return
#
	#if selected_target != null:
		#if not is_instance_valid(selected_target):
			#selected_target = null
#
	#if selected_target != null:
		#if not selected_target.is_alive():
			#selected_target = null
#
	#print("PLAYER ATTACK CONNECTED")
	#print("PLAYER USES:", attack_move.move_name)
#
	## --------------------------------------------------
	## Targeted attack
	## --------------------------------------------------
#
	#if selected_target != null:
#
		#selected_target.take_damage(
			#player.attack
		#)
#
		#_apply_enemy_knockback()
#
		#return
#
	## --------------------------------------------------
	## Untargeted attack
	## --------------------------------------------------
#
	#print(
		#"PLAYER ATTACKED IN FACING DIRECTION"
	#)


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


# ==================================================
# Movement Speed
# ==================================================

func _get_current_move_speed() -> float:

	if is_sprinting:
		return sprint_speed

	if is_crouching:
		return crouch_speed

	return move_speed
