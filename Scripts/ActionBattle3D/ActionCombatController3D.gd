extends Node
class_name ActionCombatController3D


# ==================================================
# Combatants
# ==================================================

@export var player_character: CharacterBody3D
@export var deebo: CharacterBody3D


# ==================================================
# Combat Position
# ==================================================

enum CombatPosition {
	FRONT,
	BACK
}

var player_position: CombatPosition = CombatPosition.FRONT
var deebo_position: CombatPosition = CombatPosition.BACK


# ==================================================
# Combat
# ==================================================

@export_group("Deebo Moves")
@export var bite_move: MoveResource
#@export var protect_move: MoveResource
@export var gene_move: MoveResource

@export_group("Bite")
@export var bite_lunge_distance: float = 1.2
@export var bite_lunge_duration: float = 0.12
@export var bite_return_duration: float = 0.12


# ==================================================
# Move Cooldowns
# ==================================================

var is_deebo_animating: bool = false

var move_cooldowns: Dictionary = {
	&"bite": 0.0,
	&"gene_move": 0.0
}


func _process(delta: float) -> void:
	for move_name in move_cooldowns.keys():
		move_cooldowns[move_name] = maxf(
			float(move_cooldowns[move_name]) - delta,
			0.0
		)


func get_move_cooldown_remaining(move_name: StringName) -> float:
	return float(move_cooldowns.get(move_name, 0.0))


func is_move_on_cooldown(move_name: StringName) -> bool:
	return get_move_cooldown_remaining(move_name) > 0.0


func start_move_cooldown(move_name: StringName, duration: float) -> void:
	move_cooldowns[move_name] = maxf(duration, 0.0)


# ==================================================
# Formation
# ==================================================

@export var formation_distance: float = 2.0
@export var back_left_offset: float = 0.4

@export var formation_follow_speed: float = 8.0


# ==================================================
# Swap
# ==================================================

@export var swap_speed: float = 8.0

var is_swapping: bool = false
var deebo_swap_target: Vector3


# --------------------------------------------------
# Shared Action Lock
# --------------------------------------------------

var is_action_locked: bool = false
var current_action: StringName = &""


func begin_action(action_name: StringName) -> bool:

	if is_action_locked:
		return false

	if is_swapping:
		return false

	var scene := get_tree().current_scene

	if scene == null or scene.get("run_failed") == true:
		return false

	if (
		not is_instance_valid(player_character)
		or not is_instance_valid(deebo)
	):
		return false

	if player_character.get("is_dead") == true:
		return false

	if deebo.get("is_dead") == true:
		return false

	is_action_locked = true
	current_action = action_name

	print("ACTION START: ", current_action)

	return true


func finish_action(action_name: StringName) -> void:

	if not is_action_locked or current_action != action_name:
		return

	is_action_locked = false
	current_action = &""

	print("ACTION COMPLETE")


# ==================================================
# Setup
# ==================================================

#func setup(
	#player: CharacterBody3D,
	#deebo_character: CharacterBody3D
#) -> void:
#
	#player_character = player
	#deebo = deebo_character
#
	#print("3D ACTION COMBAT CONTROLLER READY")


# ==================================================
# Physics
# ==================================================

func _physics_process(delta: float) -> void:

	if player_character == null or deebo == null:
		return

	if is_swapping:
		_update_swap(delta)
		return

	_update_formation(delta)


# ==================================================
# Input
# ==================================================

func _unhandled_input(event: InputEvent) -> void:

	var scene := get_tree().current_scene
	if scene == null or scene.get("run_failed") == true:
		return

	if not event is InputEventKey:
		return

	if not event.pressed:
		return

	if event.echo:
		return

	if event.keycode == KEY_B:
		_start_swap()

	if event.is_action_pressed("select_move_1"):
		_try_deebo_move(&"bite")
	#elif event.is_action_pressed("select_move_2"):
		#_try_deebo_move(&"protect")
	elif event.is_action_pressed("select_move_3"):
		_try_deebo_move(&"gene_move")


func _try_deebo_move(action_name: StringName) -> void:

	# Each move has its own independent cooldown.
	if is_move_on_cooldown(action_name):
		return

	# Prevent Deebo moves from overlapping.
	if is_deebo_animating:
		return

	# Prevent Deebo from starting a move during player melee.
	if is_instance_valid(player_character):
		if player_character.get("is_melee_attacking") == true:
			return

	match action_name:
		&"bite":
			if bite_move == null:
				push_error("Bite resource is not assigned.")
				return

			is_deebo_animating = true
			_perform_bite()


		#&"protect":
			#if protect_move == null:
				#push_error("Protect resource is not assigned.")
				#finish_action(action_name)
				#return
			#_perform_protect()

		&"gene_move":
			if gene_move == null:
				push_error("Gene move resource is not assigned.")
				return

			is_deebo_animating = true
			_perform_gene_move()


func _perform_bite() -> void:

	if not is_instance_valid(deebo) or bite_move == null:
		_finish_deebo_move()
		return

	# Start Bite's cooldown independently from its animation.
	start_move_cooldown(&"bite", bite_move.cooldown)

	# Bring Deebo to the front before attacking.
	if deebo_position == CombatPosition.BACK:
		var direction := _get_player_direction()
		var target_position := (
			player_character.global_position
			+ direction * formation_distance
		)

		target_position.y = deebo.global_position.y

		deebo_swap_target = target_position
		is_swapping = true

		while is_swapping:
			await get_tree().process_frame

		if not is_instance_valid(player_character) \
		or not is_instance_valid(deebo):
			_finish_deebo_move()
			return

		if deebo.get("is_dead") == true:
			_finish_deebo_move()
			return

	var player_position_3d: Vector3 = player_character.global_position
	var bite_start_position: Vector3 = deebo.global_position

	# Aim toward the player's current aim direction.
	var aim_direction: Vector3 = player_character.get_mouse_aim_direction()

	# Fall back to forward if the aim direction is invalid.
	aim_direction.y = 0.0
	if aim_direction.length_squared() < 0.001:
		aim_direction = Vector3.FORWARD
	else:
		aim_direction = aim_direction.normalized()

	# Lunge forward.
	var lunge_target: Vector3 = (
		bite_start_position + aim_direction * bite_lunge_distance
	)

	var lunge_tween: Tween = create_tween()
	lunge_tween.tween_property(
		deebo,
		"global_position",
		lunge_target,
		bite_lunge_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await lunge_tween.finished

	if not is_instance_valid(player_character) \
	or not is_instance_valid(deebo):
		_finish_deebo_move()
		return

	if deebo.get("is_dead") == true:
		_finish_deebo_move()
		return

	# Find the closest enemy in front of Deebo.
	var closest_enemy: CharacterBody3D = null
	var closest_distance: float = INF

	for enemy_node in get_tree().get_nodes_in_group("enemies_3d"):
		if not is_instance_valid(enemy_node):
			continue

		var enemy: Node = enemy_node.get_parent()
		if not is_instance_valid(enemy):
			continue

		if not enemy is CharacterBody3D:
			continue

		if not enemy.has_method("take_damage"):
			continue

		var enemy_body: CharacterBody3D = enemy as CharacterBody3D
		var to_enemy: Vector3 = (
			enemy_body.global_position - deebo.global_position
		)
		var distance: float = to_enemy.length()

		if distance > deebo.attack_range:
			continue

		if distance > 0.001:
			var direction_to_enemy: Vector3 = to_enemy.normalized()
			if aim_direction.dot(direction_to_enemy) < 0.5:
				continue

		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy_body

	# Apply Bite damage if an enemy was found.
	if is_instance_valid(closest_enemy):
		closest_enemy.take_damage(bite_move.power)

	# Return Deebo to the starting position.
	if is_instance_valid(deebo):
		var return_tween: Tween = create_tween()
		return_tween.tween_property(
			deebo,
			"global_position",
			bite_start_position,
			bite_return_duration
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

		await return_tween.finished

	# Brief recovery is part of the animation lock, not the cooldown.
	await get_tree().create_timer(
		bite_move.hitbox_duration + bite_move.action_recovery_duration
	).timeout

	_finish_deebo_move()


func _perform_gene_move() -> void:

	var move: MoveResource = gene_move

	if move == null:
		_finish_deebo_move()
		return

	# Start the Gene Move cooldown independently.
	start_move_cooldown(&"gene_move", move.cooldown)

	if not is_instance_valid(deebo):
		_finish_deebo_move()
		return

	var start_position: Vector3 = deebo.global_position
	var aim_direction: Vector3 = player_character.get_mouse_aim_direction()

	aim_direction.y = 0.0
	if aim_direction.length_squared() < 0.001:
		aim_direction = Vector3.FORWARD
	else:
		aim_direction = aim_direction.normalized()

	# Perform the lunge.
	var lunge_distance: float = move.action_lunge_distance / 100.0
	var target_position: Vector3 = (
		start_position + aim_direction * lunge_distance
	)

	var lunge_tween: Tween = create_tween()
	lunge_tween.tween_property(
		deebo,
		"global_position",
		target_position,
		bite_lunge_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await lunge_tween.finished

	if not is_instance_valid(deebo):
		_finish_deebo_move()
		return

	# Damage nearby enemies.
	for enemy_node in get_tree().get_nodes_in_group("enemies_3d"):
		if not is_instance_valid(enemy_node):
			continue

		var enemy: Node = enemy_node.get_parent()
		if not is_instance_valid(enemy):
			continue

		if not enemy is CharacterBody3D:
			continue

		if not enemy.has_method("take_damage"):
			continue

		var enemy_body: CharacterBody3D = enemy as CharacterBody3D

		if enemy_body.global_position.distance_to(deebo.global_position) <= 1.5:
			enemy_body.take_damage(move.power)

	# Return Deebo to his starting position.
	if is_instance_valid(deebo):
		var return_tween: Tween = create_tween()
		return_tween.tween_property(
			deebo,
			"global_position",
			start_position,
			bite_return_duration
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

		await return_tween.finished

	# Recovery blocks other Deebo moves, not player movement.
	await get_tree().create_timer(
		move.action_recovery_duration
	).timeout

	_finish_deebo_move()


func _finish_deebo_move() -> void:

	is_deebo_animating = false


# ==================================================
# Formation
# ==================================================

func _update_formation(delta: float) -> void:

	var target_position := _get_formation_position()

	deebo.global_position = deebo.global_position.lerp(
		target_position,
		min(formation_follow_speed * delta, 1.0)
	)

	#print(
		#"Player: ", player_character.global_position,
		#" | Deebo: ", deebo.global_position,
		#" | Position: ", CombatPosition.keys()[deebo_position]
	#)


func _get_formation_position() -> Vector3:

	var direction := _get_player_direction()
	var target_position := player_character.global_position

	# Player's left relative to their current facing direction.
	var left := Vector3(
		direction.z,
		0.0,
		-direction.x
	)

	if deebo_position == CombatPosition.FRONT:

		# Directly in front of the player.
		target_position += direction * formation_distance

	else:

		# Behind the player.
		target_position -= direction * formation_distance

		# Slightly to the player's left.
		target_position += left * back_left_offset

	target_position.y = deebo.global_position.y

	return target_position


# ==================================================
# Player Direction
# ==================================================

func _get_player_direction() -> Vector3:

	if player_character.has_method("get_facing_direction"):
		return player_character.get_facing_direction()

	return Vector3.FORWARD


# ==================================================
# Start Swap
# ==================================================

func _start_swap() -> void:

	if not begin_action(&"swap"):
		return

	var direction := _get_player_direction()
	var target_position := player_character.global_position

	# Player's left relative to their current facing direction.
	var left := Vector3(
		direction.z,
		0.0,
		-direction.x
	)

	if deebo_position == CombatPosition.FRONT:

		# FRONT → BACK
		target_position -= direction * formation_distance
		target_position += left * back_left_offset

	else:

		# BACK → FRONT
		target_position += direction * formation_distance

	target_position.y = deebo.global_position.y

	deebo_swap_target = target_position
	is_swapping = true

	print("3D COMBAT SWAP START")


func start_slam_swap() -> void:

	if is_swapping:
		return

	var direction := _get_player_direction()
	var target_position := player_character.global_position
	var left := Vector3(direction.z, 0.0, -direction.x)

	# Deebo is currently in FRONT, so move him behind the player.
	target_position -= direction * formation_distance
	target_position += left * back_left_offset
	target_position.y = deebo.global_position.y

	deebo_swap_target = target_position
	is_swapping = true


func _try_deebo_attack() -> void:

	if is_swapping:
		return

	if deebo.is_dead or not deebo.can_attack:
		return

	var scene := get_tree().current_scene

	if scene == null or scene.get("run_failed") == true:
		return

	var aim_direction: Vector3 = player_character.get_mouse_aim_direction()

	var closest_enemy: CharacterBody3D = null
	var closest_distance := INF

	for enemy_node in get_tree().get_nodes_in_group("enemies_3d"):
		var enemy_controller := enemy_node as Node

		if enemy_controller == null:
			continue

		var enemy_body := enemy_controller.get_parent() as CharacterBody3D

		if enemy_body == null or not enemy_body.has_method("take_damage"):
			continue

		var offset: Vector3 = enemy_body.global_position - deebo.global_position
		offset.y = 0.0

		var distance := offset.length()

		if distance > deebo.attack_range or distance <= 0.001:
			continue

		if aim_direction.dot(offset.normalized()) < 0.5:
			continue

		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy_body

	if closest_enemy == null:
		print("DEEBO ATTACK: No enemy in range and aim direction.")
		return

	deebo.can_attack = false
	closest_enemy.take_damage(deebo.attack_damage)

	print("DEEBO BASIC ATTACK: ", deebo.attack_damage, " damage.")

	_reset_deebo_attack_cooldown()


func _reset_deebo_attack_cooldown() -> void:

	await get_tree().create_timer(deebo.attack_cooldown).timeout

	if is_instance_valid(deebo) and not deebo.is_dead:
		deebo.can_attack = true


# ==================================================
# Update Swap
# ==================================================

func _update_swap(delta: float) -> void:

	var scene := get_tree().current_scene
	if scene == null or scene.get("run_failed") == true:
		is_swapping = false
		return

	var direction := (
		deebo_swap_target
		- deebo.global_position
	)

	direction.y = 0.0

	var distance := direction.length()

	if distance <= 0.05:

		deebo.global_position = deebo_swap_target

		_finish_swap()

		return

	deebo.global_position += (
		direction.normalized()
		* swap_speed
		* delta
	)


# ==================================================
# Finish Swap
# ==================================================

func _finish_swap() -> void:

	deebo.global_position = deebo_swap_target

	var old_player_position := player_position

	player_position = deebo_position
	deebo_position = old_player_position

	is_swapping = false

	print("3D COMBAT SWAP COMPLETE")

	print(
		"Player position: ",
		CombatPosition.keys()[player_position]
	)

	print(
		"Deebo position: ",
		CombatPosition.keys()[deebo_position]
	)

	if current_action == &"swap":
		finish_action(&"swap")
