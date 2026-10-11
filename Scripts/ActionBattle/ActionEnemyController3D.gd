extends Node


# --------------------------------------------------
# References
# --------------------------------------------------

@export var player: CharacterBody3D

@onready var enemy: CharacterBody3D = get_parent() as CharacterBody3D


# --------------------------------------------------
# Movement and Vision
# --------------------------------------------------

@export var move_speed: float = 2.5
@export var detection_range: float = 6.0
@export_range(1.0, 360.0, 1.0) var vision_angle: float = 100.0

@export var attack_range: float = 1.8
@export var stop_distance: float = 1.3

var is_player_detected: bool = false
var last_known_player_position: Vector3 = Vector3.ZERO


# --------------------------------------------------
# Roaming
# --------------------------------------------------

@export var roaming_radius: float = 4.0
@export var roaming_pause_min: float = 1.0
@export var roaming_pause_max: float = 3.0
@export var roaming_arrival_distance: float = 0.3

var spawn_position: Vector3
var roaming_target: Vector3
var roaming_timer: float = 0.0
var is_roaming: bool = false


# --------------------------------------------------
# Sound Detection
# --------------------------------------------------

@export var walking_noise_range: float = 6.0
@export var sprinting_noise_range: float = 12.0
@export var crouching_noise_range: float = 2.0
@export var dashing_noise_range: float = 15.0


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

	if player == null:
		player = get_tree().current_scene.get_node_or_null("Player") as CharacterBody3D

	if player == null:
		push_error("ActionEnemyController3D: Player reference is missing.")

	enemy.rotation.y = 0.0

	spawn_position = enemy.global_position
	roaming_target = spawn_position
	roaming_timer = randf_range(roaming_pause_min, roaming_pause_max)


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

	if _can_see_player():
		is_player_detected = true
		last_known_player_position = player.global_position


func _physics_process(delta: float) -> void:

	if is_dead or enemy == null or not is_instance_valid(player):
		return

	_update_detection()

	# Roam until the player has been seen.
	if not is_player_detected:
		_update_roaming(delta)
		enemy.move_and_slide()
		return

	var offset: Vector3 = player.global_position - enemy.global_position
	offset.y = 0.0

	var distance: float = offset.length()

	# The enemy ignores the player until detected.
	if distance > detection_range:
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		enemy.move_and_slide()
		return

	# Attack when close enough.
	if distance <= attack_range:
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0

		if can_attack and not is_attacking:
			_start_attack()

		enemy.move_and_slide()
		return

	# Chase the player.
	if not is_attacking and distance > stop_distance:
		var direction: Vector3 = offset.normalized()

		enemy.velocity.x = direction.x * move_speed
		enemy.velocity.z = direction.z * move_speed
		
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

	await get_tree().create_timer(attack_windup).timeout

	if is_dead or not is_instance_valid(player):
		is_attacking = false
		return

	var distance: float = enemy.global_position.distance_to(
		player.global_position
	)

	# Check range again so the player can dodge the attack.
	var flat_offset: Vector3 = player.global_position - enemy.global_position
	flat_offset.y = 0.0

	if flat_offset.length() <= attack_range:
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)

	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout

	if not is_dead:
		can_attack = true

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

	return spawn_position + random_offset


func stop_ai() -> void:

	is_dead = true
	enemy.velocity = Vector3.ZERO
