extends Node


# --------------------------------------------------
# References
# --------------------------------------------------

@export var player: CharacterBody3D

@export var deebo: CharacterBody3D
@export var damage_share_distance: float = 3.0
@export_range(0.0, 1.0) var primary_damage_ratio: float = 0.7

@onready var enemy: CharacterBody3D = get_parent() as CharacterBody3D


# --------------------------------------------------
# Movement and Vision
# --------------------------------------------------

@export var move_speed: float = 2.5
@export var detection_range: float = 7.5
@export_range(1.0, 360.0, 1.0) var vision_angle: float = 100.0

@export var attack_range: float = 1.8
@export var stop_distance: float = 1.3

enum AwarenessState {
	ROAMING,
	INVESTIGATING,
	SEARCHING,
	ALERTED
}

var awareness_state: AwarenessState = AwarenessState.ROAMING

var last_known_player_position: Vector3 = Vector3.ZERO
var last_heard_position: Vector3 = Vector3.ZERO

@export var search_duration: float = 3.0
var search_timer: float = 0.0

@export var search_radius: float = 1.5
@export var search_move_speed: float = 1.2
@export var search_pause_min: float = 0.3
@export var search_pause_max: float = 0.7

var search_target: Vector3 = Vector3.ZERO
var search_pause_timer: float = 0.0

@export_group("Enemy Separation")
@export var separation_radius: float = 0.5
@export var separation_strength: float = 1.0


# --------------------------------------------------
# Roaming
# --------------------------------------------------

@export var roaming_radius: float = 3.0
@export var roaming_pause_min: float = 1.0
@export var roaming_pause_max: float = 3.0
@export var roaming_arrival_distance: float = 0.3

var spawn_position: Vector3
var roaming_target: Vector3
var roaming_timer: float = 0.0
var is_roaming: bool = false
var roaming_center: Vector3


# --------------------------------------------------
# Sound Detection
# --------------------------------------------------

@export var walking_noise_range: float = 6.0
@export var sprinting_noise_range: float = 12.0
@export var crouching_noise_range: float = 2.0
@export var dashing_noise_range: float = 14.0


# --------------------------------------------------
# Pack Alerts
# --------------------------------------------------

@export var pack_alert_radius: float = 10.0


# --------------------------------------------------
# Attack
# --------------------------------------------------

@export var attack_damage: float = 8.0
@export var attack_cooldown: float = 1.5
@export var attack_windup: float = 0.45

var can_attack: bool = true
var is_attacking: bool = false
var is_dead: bool = false


func _ready() -> void:

	#if player == null:
		#player = get_tree().current_scene.get_node_or_null("Player") as CharacterBody3D
#
	#if player == null:
		#push_error("ActionEnemyController3D: Player reference is missing.")
#
	#if deebo == null:
		#deebo = get_tree().current_scene.get_node_or_null("Deebo") as CharacterBody3D
#
	#if deebo == null:
		#push_warning("ActionEnemyController3D: Deebo reference is missing.")

	enemy.rotation.y = 0.0

	spawn_position = enemy.global_position
	roaming_target = spawn_position
	roaming_timer = randf_range(roaming_pause_min, roaming_pause_max)
	roaming_center = enemy.global_position
	add_to_group("enemies_3d")
	add_to_group("enemy_controllers_3d")


# --------------------------------------------------
# Vision
# --------------------------------------------------

func _can_see_player() -> bool:

	if not is_instance_valid(player):
		return false

	var to_player: Vector3 = player.global_position - enemy.global_position
	to_player.y = 0.0

	var distance: float = to_player.length()

	if distance > detection_range or distance <= 0.01:
		return false

	# Check whether the player is inside the vision cone.
	var forward: Vector3 = Vector3(0.0, 0.0, 1.0)
	forward.y = 0.0
	forward = forward.normalized()

	var direction: Vector3 = to_player.normalized()
	var angle: float = rad_to_deg(acos(
		clampf(forward.dot(direction), -1.0, 1.0)
	))

	if angle > vision_angle * 0.5:
		return false

	# Check whether a wall or other physics object blocks vision.
	var space_state = enemy.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		enemy.global_position + Vector3.UP * 0.8,
		player.global_position + Vector3.UP * 0.8
	)

	query.exclude = [enemy.get_rid()]

	var result: Dictionary = space_state.intersect_ray(query)

	if not result.is_empty():
		var collider: Object = result.get("collider") as Object

		if collider != player:
			return false

	return true


# --------------------------------------------------
# Sound
# --------------------------------------------------

func _can_hear_player() -> bool:

	if not is_instance_valid(player):
		return false

	if not player.has_method("get_movement_noise"):
		return false

	var noise_level: float = player.get_movement_noise()
	if noise_level <= 0.0:
		return false

	var noise_range: float = walking_noise_range

	if player.is_dashing:
		noise_range = dashing_noise_range
	elif player.is_crouching:
		noise_range = crouching_noise_range
	elif player.is_sprinting:
		noise_range = sprinting_noise_range

	#return enemy.global_position.distance_to(
		#player.global_positions
	#) <= noise_range

	var can_hear: bool = enemy.global_position.distance_to(
		player.global_position
	) <= noise_range

	if can_hear:
		print("Wolf can hear player. Noise range: ", noise_range)

	return can_hear


func _update_detection() -> void:

	# Seeing the player overrides every non-alerted state.
	if _can_see_player():
		if awareness_state != AwarenessState.ALERTED:
			awareness_state = AwarenessState.ALERTED
			last_known_player_position = player.global_position
			_broadcast_visual_alert(last_known_player_position)
		else:
			last_known_player_position = player.global_position

		return

	# Only roaming Wolves investigate new sounds.
	if awareness_state == AwarenessState.ROAMING:
		if _can_hear_player():
			last_heard_position = player.global_position
			awareness_state = AwarenessState.INVESTIGATING
			_broadcast_pack_alert(last_heard_position)


func _physics_process(delta: float) -> void:

	if is_dead or enemy == null or not is_instance_valid(player):
		return

	_update_detection()

	# Visual detection immediately interrupts investigation and searching.
	if awareness_state == AwarenessState.ALERTED:
		var distance_to_player: float = enemy.global_position.distance_to(
			player.global_position
		)

		#print(
			#"ALERTED | Distance: ",
			#snappedf(distance_to_player, 0.1),
			#" | Attacking: ",
			#is_attacking,
			#" | Can attack: ",
			#can_attack
		#)

		# Continue into the chase and attack logic below.
		pass

	# Roam until the player has been seen.
	if awareness_state == AwarenessState.ROAMING:
		_update_roaming(delta)
		enemy.move_and_slide()
		return

	# Investigate the location where the sound was heard.
	if awareness_state == AwarenessState.INVESTIGATING \
	and awareness_state != AwarenessState.ALERTED:
		var sound_offset: Vector3 = last_heard_position - enemy.global_position
		sound_offset.y = 0.0

		if sound_offset.length() <= roaming_arrival_distance:
			awareness_state = AwarenessState.SEARCHING
			search_timer = search_duration
			roaming_center = last_heard_position
			search_target = _get_search_target()
			search_pause_timer = 0.0
			enemy.velocity.x = 0.0
			enemy.velocity.z = 0.0
		else:
			var sound_direction: Vector3 = sound_offset.normalized()
			enemy.velocity.x = sound_direction.x * move_speed * 0.75
			enemy.velocity.z = sound_direction.z * move_speed * 0.75

		enemy.move_and_slide()
		return

	# Search only while the Wolf has not become alerted.
	if awareness_state == AwarenessState.SEARCHING \
	and awareness_state != AwarenessState.ALERTED:
		search_timer -= delta

		if search_timer <= 0.0:
			awareness_state = AwarenessState.ROAMING
			roaming_timer = randf_range(
				roaming_pause_min,
				roaming_pause_max
			)
			roaming_target = _get_roaming_target()
			enemy.velocity.x = 0.0
			enemy.velocity.z = 0.0
			enemy.move_and_slide()
			return

		# Pause briefly before choosing another search point.
		if search_pause_timer > 0.0:
			search_pause_timer -= delta
			enemy.velocity.x = 0.0
			enemy.velocity.z = 0.0
			enemy.move_and_slide()
			return

		var search_offset: Vector3 = (
			search_target - enemy.global_position
		)
		search_offset.y = 0.0

		# Choose another point when the current one is reached.
		if search_offset.length() <= roaming_arrival_distance:
			search_target = _get_search_target()
			search_pause_timer = randf_range(
				search_pause_min,
				search_pause_max
			)
			enemy.velocity.x = 0.0
			enemy.velocity.z = 0.0
		else:
			var search_direction: Vector3 = search_offset.normalized()
			enemy.velocity.x = search_direction.x * search_move_speed
			enemy.velocity.z = search_direction.z * search_move_speed

		enemy.move_and_slide()
		return

	var offset: Vector3 = player.global_position - enemy.global_position
	offset.y = 0.0

	var distance: float = offset.length()

	## The enemy ignores the player until detected.
	#if distance > detection_range:
		#enemy.velocity.x = 0.0
		#enemy.velocity.z = 0.0
		#enemy.move_and_slide()
		#return

	# Attack whenever this Wolf is within attack range.
	if distance <= attack_range:
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0

		if can_attack and not is_attacking:
			_start_attack()

		enemy.move_and_slide()
		return

	# Chase the player.
	if not is_attacking and distance > stop_distance:
		var chase_direction: Vector3 = offset.normalized()
		var separation_direction: Vector3 = _get_separation_direction()

		var move_direction: Vector3 = (
			chase_direction + separation_direction * separation_strength
		).normalized()

		enemy.velocity.x = move_direction.x * move_speed
		enemy.velocity.z = move_direction.z * move_speed

		## Face the direction of movement.
		#enemy.look_at(
			#enemy.global_position + direction,
			#Vector3.UP
		#)
	else:
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0

	enemy.move_and_slide()


func _start_attack() -> void:

	is_attacking = true
	can_attack = false

	_perform_attack()


func _perform_attack() -> void:

	var scene := get_tree().current_scene

	if scene == null or scene.get("run_failed") == true:
		is_attacking = false
		return

	await get_tree().create_timer(attack_windup).timeout

	# The run may have failed during the windup.
	scene = get_tree().current_scene

	if (
		scene == null
		or scene.get("run_failed") == true
		or is_dead
		or not is_instance_valid(enemy)
	):
		is_attacking = false
		return

	# Recheck range after the windup so attacks can be dodged.
	var targets: Array[CharacterBody3D] = []

	if _can_receive_damage(player):
		targets.append(player)

	if _can_receive_damage(deebo):
		targets.append(deebo)

	var in_range := false

	for target in targets:
		var offset: Vector3 = target.global_position - enemy.global_position
		offset.y = 0.0

		if offset.length() <= attack_range:
			in_range = true
			break

	if in_range:
		_apply_attack_damage()

	is_attacking = false

	scene = get_tree().current_scene

	if scene == null or scene.get("run_failed") == true:
		return

	await get_tree().create_timer(attack_cooldown).timeout

	scene = get_tree().current_scene

	if (
		not is_dead
		and scene != null
		and scene.get("run_failed") != true
	):
		can_attack = true


func _apply_attack_damage() -> void:

	var scene := get_tree().current_scene

	if scene == null or scene.get("run_failed") == true:
		return

	if not is_instance_valid(enemy) or is_dead:
		return

	var targets: Array[CharacterBody3D] = []

	if _can_receive_damage(player):
		targets.append(player)

	if _can_receive_damage(deebo):
		targets.append(deebo)

	if targets.is_empty():
		return

	# Find the eligible character closest to the attacking enemy.
	var closest_target: CharacterBody3D = targets[0]
	var closest_distance: float = enemy.global_position.distance_to(
		closest_target.global_position
	)

	for target in targets:
		var distance: float = enemy.global_position.distance_to(
			target.global_position
		)

		if distance < closest_distance:
			closest_target = target
			closest_distance = distance

	var other_target: CharacterBody3D = null

	for target in targets:
		if target != closest_target:
			other_target = target
			break

	if (
		other_target != null
		and closest_target.global_position.distance_to(
			other_target.global_position
		) <= damage_share_distance
	):
		closest_target.take_damage(
			attack_damage * primary_damage_ratio
		)

		# The first hit may have ended the run.
		scene = get_tree().current_scene

		if scene == null or scene.get("run_failed") == true:
			return

		# Recheck that the second target can still receive damage.
		if _can_receive_damage(other_target):
			other_target.take_damage(
				attack_damage * (1.0 - primary_damage_ratio)
			)
	else:
		closest_target.take_damage(attack_damage)


func _can_receive_damage(target: CharacterBody3D) -> bool:

	if not is_instance_valid(target):
		return false

	if not target.has_method("take_damage"):
		return false

	if target.get("is_dead") == true:
		return false

	return true


func _update_roaming(delta: float) -> void:

	if roaming_timer > 0.0:
		roaming_timer -= delta
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		return

	var offset: Vector3 = roaming_target - enemy.global_position
	offset.y = 0.0

	if offset.length() <= roaming_arrival_distance:
		roaming_target = _get_roaming_target()
		roaming_timer = randf_range(
			roaming_pause_min,
			roaming_pause_max
		)
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		return

	var direction: Vector3 = offset.normalized()
	enemy.velocity.x = direction.x * move_speed * 0.5
	enemy.velocity.z = direction.z * move_speed * 0.5


func _get_roaming_target() -> Vector3:

	var random_offset := Vector3(
		randf_range(-roaming_radius, roaming_radius),
		0.0,
		randf_range(-roaming_radius, roaming_radius)
	)

	return roaming_center + random_offset


func _get_search_target() -> Vector3:

	var random_offset := Vector3(
		randf_range(-search_radius, search_radius),
		0.0,
		randf_range(-search_radius, search_radius)
	)

	return roaming_center + random_offset


func _broadcast_pack_alert(alert_position: Vector3) -> void:

	for controller in get_tree().get_nodes_in_group("enemies_3d"):
		if controller == self:
			continue

		if not controller.has_method("receive_pack_alert"):
			continue

		var other_enemy: CharacterBody3D = controller.get_parent() as CharacterBody3D

		if other_enemy == null:
			continue

		var distance: float = enemy.global_position.distance_to(
			other_enemy.global_position
		)

		if distance <= pack_alert_radius:
			controller.receive_pack_alert(alert_position)


func _broadcast_visual_alert(player_position: Vector3) -> void:

	for controller in get_tree().get_nodes_in_group("enemies_3d"):
		if controller == self:
			continue

		if not controller.has_method("receive_visual_alert"):
			continue

		controller.receive_visual_alert(player_position)


func receive_pack_alert(alert_position: Vector3) -> void:

	# Only unalerted Wolves need to receive a new disturbance.
	if is_dead or awareness_state != AwarenessState.ROAMING:
		return

	last_heard_position = alert_position
	awareness_state = AwarenessState.INVESTIGATING

	# Relay the alert so it can spread through the pack.
	_broadcast_pack_alert(alert_position)


func receive_visual_alert(player_position: Vector3) -> void:

	if is_dead:
		return

	# Check whether this Wolf already knows about the threat.
	var was_already_alerted: bool = (
		awareness_state == AwarenessState.ALERTED
	)

	# A visual alert confirms the threat.
	awareness_state = AwarenessState.ALERTED
	last_known_player_position = player_position

	# Only relay the alert when this Wolf becomes alerted for the first time.
	if not was_already_alerted:
		_broadcast_visual_alert(player_position)


func _get_separation_direction() -> Vector3:

	var separation := Vector3.ZERO

	for controller in get_tree().get_nodes_in_group("enemies_3d"):
		if controller == self:
			continue

		if controller.is_dead:
			continue

		var other_enemy := controller.get_parent() as CharacterBody3D
		if other_enemy == null:
			continue

		var offset: Vector3 = (
			enemy.global_position - other_enemy.global_position
		)
		offset.y = 0.0

		var distance := offset.length()

		if distance > 0.01 and distance < separation_radius:
			var weight := 1.0 - (distance / separation_radius)
			separation += offset.normalized() * weight

	if separation.length_squared() > 0.001:
		return separation.normalized()

	return Vector3.ZERO


func stop_ai() -> void:

	is_dead = true
	enemy.velocity = Vector3.ZERO
