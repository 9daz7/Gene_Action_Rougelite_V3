extends Node
class_name ActionCombatController


# ==================================================
# Combatants
# ==================================================

var player_character: CharacterBody2D = null
var deebo: PlayerAnimal = null


# ==================================================
# Combat Position
# ==================================================

enum CombatPosition {
	FRONT,
	BACK
}

var player_position: CombatPosition = CombatPosition.BACK
var deebo_position: CombatPosition = CombatPosition.FRONT


# ==================================================
# Swap
# ==================================================

@export var swap_distance: float = 80.0
@export var swap_speed: float = 300.0

var is_swapping: bool = false

var player_swap_target: Vector2
var deebo_swap_target: Vector2


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
	print("Player position: BACK")
	print("Deebo position: FRONT")


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


# ==================================================
# Start Swap
# ==================================================

func _start_swap() -> void:

	if is_swapping:
		return

	print("========================================")
	print("COMBAT SWAP START")
	print("========================================")

	print(
		"Before swap | Player:",
		CombatPosition.keys()[player_position],
		"| Deebo:",
		CombatPosition.keys()[deebo_position]
	)

	var center_position := (
		player_character.global_position
		+ deebo.global_position
	) / 2.0

	var direction := (
		deebo.global_position
		- player_character.global_position
	).normalized()

	if direction == Vector2.ZERO:
		direction = Vector2.LEFT

	player_swap_target = (
		center_position
		+ direction * swap_distance / 2.0
	)

	deebo_swap_target = (
		center_position
		- direction * swap_distance / 2.0
	)

	is_swapping = true


# ==================================================
# Update Swap
# ==================================================

func _update_swap(delta: float) -> void:

	var player_direction := (
		player_swap_target
		- player_character.global_position
	)

	var deebo_direction := (
		deebo_swap_target
		- deebo.global_position
	)

	var player_distance := player_direction.length()
	var deebo_distance := deebo_direction.length()

	if player_distance > 2.0:

		player_character.velocity = (
			player_direction.normalized()
			* swap_speed
		)

		player_character.move_and_slide()

	else:

		player_character.velocity = Vector2.ZERO

	if deebo_distance > 2.0:

		deebo.velocity = (
			deebo_direction.normalized()
			* swap_speed
		)

		deebo.move_and_slide()

	else:

		deebo.velocity = Vector2.ZERO

	if (
		player_distance <= 2.0
		and
		deebo_distance <= 2.0
	):

		_finish_swap()


# ==================================================
# Finish Swap
# ==================================================

func _finish_swap() -> void:

	player_character.global_position = player_swap_target
	deebo.global_position = deebo_swap_target

	player_character.velocity = Vector2.ZERO
	deebo.velocity = Vector2.ZERO

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
