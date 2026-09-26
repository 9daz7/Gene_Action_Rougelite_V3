extends Node
class_name ActionCombatController


# ==================================================
# Combatants
# ==================================================

var player_character: CharacterBody2D
var deebo: PlayerAnimal

var player_health: float = 100.0
var player_max_health: float = 100.0

var player_combat_controller: ActionPlayerCombatController = null


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
# Formation
# ==================================================

@export var front_offset: Vector2 = Vector2(80.0, 0.0)
@export var back_offset: Vector2 = Vector2(-55.0, -35.0)

@export var attack_return_speed: float = 500.0


# ==================================================
# Swap
# ==================================================

@export var swap_speed_multiplier: float = 30.0

var is_swapping: bool = false
var deebo_swap_target: Vector2

var attack_override_active: bool = false
var attack_override_position: Vector2
var attack_return_active: bool = false

var player_dash_active: bool = false


func receive_enemy_damage(
	attacker: AnimalBase,
	damage: float
) -> void:

	if attacker == null:
		return

	if damage <= 0.0:
		return

	# ==========================================
	# Dodge
	# ==========================================

	if is_dodging():

		print(
			"ACTION DAMAGE DODGED | Attacker:",
			attacker.name
		)

		return


	# ==========================================
	# Distance
	# ==========================================

	if player_character == null:
		return

	if deebo == null:
		return

	var player_distance := (
		attacker.global_position
		.distance_to(
			player_character.global_position
		)
	)

	var deebo_distance := (
		attacker.global_position
		.distance_to(
			deebo.global_position
		)
	)


	# ==========================================
	# Determine Primary Target
	# ==========================================

	var primary_damage := damage * 0.7
	var secondary_damage := damage * 0.3


	print(
		"ACTION DAMAGE | Incoming:",
		damage
	)

	print(
		"PLAYER DISTANCE:",
		player_distance,
		"| DEEBO DISTANCE:",
		deebo_distance
	)


	# ==========================================
	# Player Character is Closer
	# ==========================================

	if player_distance <= deebo_distance:

		print(
			"PRIMARY TARGET: PLAYER CHARACTER | 70%"
		)

		take_player_damage(
			primary_damage
		)

		deebo.take_damage(
			secondary_damage,
			attacker,
			false,
			null
		)


	# ==========================================
	# Deebo is Closer
	# ==========================================

	else:

		print(
			"PRIMARY TARGET: DEEBO | 70%"
		)

		deebo.take_damage(
			primary_damage,
			attacker,
			false,
			null
		)

		take_player_damage(
			secondary_damage
		)


# ==================================================
# Setup
# ==================================================

func setup(
	player: CharacterBody2D,
	deebo_animal: PlayerAnimal
) -> void:

	player_character = player
	deebo = deebo_animal

	print("ACTION COMBAT CONTROLLER READY")


func set_player_combat_controller(
	controller: ActionPlayerCombatController
) -> void:

	player_combat_controller = controller


func is_dodging() -> bool:

	if player_combat_controller == null:
		return false

	return player_combat_controller.is_dodging()


func take_player_damage(damage: float) -> void:

	if damage <= 0.0:
		return

	player_health = max(
		player_health - damage,
		0.0
	)

	print(
		"PLAYER CHARACTER TOOK ",
		damage,
		" DAMAGE | HP: ",
		player_health,
		"/",
		player_max_health
	)


# ==================================================
# Physics
# ==================================================

func _physics_process(delta: float) -> void:

	if player_character == null:
		return

	if deebo == null:
		return

	if is_swapping:
		_update_swap(delta)


# ==================================================
# Input
# ==================================================

func _unhandled_input(event: InputEvent) -> void:

	if not event is InputEventKey:
		return

	if not event.pressed:
		return

	if event.echo:
		return

	if event.keycode == KEY_B:
		_start_swap()


func _process(delta: float) -> void:

	if player_character == null:
		return

	if deebo == null:
		return

	if attack_override_active:
		deebo.global_position = attack_override_position
		return

	if attack_return_active:
		_update_attack_return(delta)
		return

	if player_dash_active:
		return

	if is_swapping:
		return

	_update_formation()


func _update_formation() -> void:

	deebo.global_position = _get_formation_position()


func set_player_front() -> void:

	player_position = CombatPosition.FRONT
	deebo_position = CombatPosition.BACK


func reposition_deebo_to_formation() -> void:

	attack_return_active = true


func _update_attack_return(delta: float) -> void:

	var target_position := _get_formation_position()
	var direction := (
		target_position
		- deebo.global_position
	)

	var distance := direction.length()

	if distance <= 2.0:
		deebo.global_position = target_position
		attack_return_active = false
		return

	deebo.global_position += (
		direction.normalized()
		* attack_return_speed
		* delta
	)


func _get_formation_position() -> Vector2:

	var direction := _get_player_direction()
	var side := Vector2(-direction.y, direction.x)

	var offset := front_offset

	if deebo_position == CombatPosition.BACK:
		offset = back_offset

	return (
		player_character.global_position
		+ direction * offset.x
		+ side * offset.y
	)


func start_deebo_attack_movement(
	start_position: Vector2
) -> void:

	attack_override_active = true
	attack_override_position = start_position


func set_deebo_attack_position(
	position: Vector2
) -> void:

	if not attack_override_active:
		return
	
	attack_override_position = position


func finish_deebo_attack_movement() -> void:

	attack_override_active = false
	attack_return_active = true

	print("DEEBO RETURNING TO FORMATION")


func _get_player_direction() -> Vector2:

	var controller := player_character.get_node_or_null(
		"ActionPlayerCharacterController"
	)

	if controller == null:
		return Vector2.RIGHT

	if controller.facing_direction == Vector2.ZERO:
		return Vector2.RIGHT

	return controller.facing_direction.normalized()


func move_deebo_toward(
	target_position: Vector2,
	speed: float
) -> void:

	if deebo == null:
		return

	var direction := (
		target_position
		- deebo.global_position
	).normalized()

	deebo.global_position += direction * speed * get_physics_process_delta_time()


# ==================================================
# Start Swap
# ==================================================

func _start_swap() -> void:

	if is_swapping:
		return

	if player_combat_controller != null:
		player_combat_controller.cancel_player_attack()

	print("========================================")
	print("COMBAT SWAP START")
	print("========================================")

	print(
		"Before swap | Player:",
		CombatPosition.keys()[player_position],
		"| Deebo:",
		CombatPosition.keys()[deebo_position]
	)

	var direction := _get_player_direction()

	var side := Vector2(
		-direction.y,
		direction.x
	)

	var offset := front_offset

	if deebo_position == CombatPosition.FRONT:
		offset = back_offset

	deebo_swap_target = (
		player_character.global_position
		+ direction * offset.x
		+ side * offset.y
	)

	is_swapping = true


# ==================================================
# Update Swap
# ==================================================

func _update_swap(delta: float) -> void:

	var direction := (
		deebo_swap_target
		- deebo.global_position
	)

	var distance := direction.length()

	if distance > 2.0:

		var swap_speed: float = deebo.get_speed() * swap_speed_multiplier

		deebo.global_position += (
			direction.normalized()
			* swap_speed
			* delta
		)

	else:

		deebo.global_position = deebo_swap_target
		_finish_swap()


# ==================================================
# Finish Swap
# ==================================================

func _finish_swap() -> void:

	deebo.global_position = deebo_swap_target

	var old_player_position := player_position

	player_position = deebo_position
	deebo_position = old_player_position

	is_swapping = false

	print("COMBAT SWAP COMPLETE")

	print(
		"Player position:",
		CombatPosition.keys()[player_position]
	)

	print(
		"Deebo position:",
		CombatPosition.keys()[deebo_position]
	)
