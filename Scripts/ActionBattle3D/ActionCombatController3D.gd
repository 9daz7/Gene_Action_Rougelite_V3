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

	if player_character == null:
		return

	if deebo == null:
		return

	if is_swapping:
		_update_swap(delta)
		return

	_update_formation(delta)


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

	if is_swapping:
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


# ==================================================
# Update Swap
# ==================================================

func _update_swap(delta: float) -> void:

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
