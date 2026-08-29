extends CharacterBody2D
class_name RoamingEnemy


# ==================================================
# Enemy Data
# ==================================================

@export var enemy_data: EnemyResource


# ==================================================
# Signals
# ==================================================

signal encounter_requested(enemy)


# ==================================================
# Movement Settings
# ==================================================

@export var move_speed: float = 35.0
@export var wander_radius: float = 150.0

@export var min_wander_time: float = 1.0
@export var max_wander_time: float = 3.0

@export var idle_chance: float = 0.25


# ==================================================
# Detection Settings
# ==================================================

@export var detection_radius: float = 180.0


# ==================================================
# State
# ==================================================

var encountered: bool = false

var spawn_position: Vector2
var wander_target: Vector2

var wander_timer: float = 0.0
var is_wandering: bool = false


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	spawn_position = global_position

	_choose_next_wander()

	var detection_area := get_node_or_null(
		"DetectionArea2D"
	)

	if detection_area == null:

		push_error(
			"RoamingEnemy: DetectionArea2D not found."
		)

		return

	detection_area.monitoring = true


# ==================================================
# Detection
# ==================================================


func _physics_process(
	delta: float
) -> void:

	if encountered:
		velocity = Vector2.ZERO
		return

	wander_timer -= delta

	if wander_timer <= 0.0:

		_choose_next_wander()

	if not is_wandering:

		velocity = Vector2.ZERO

	else:

		var direction := (
			global_position.direction_to(
				wander_target
			)
		)

		velocity = direction * move_speed

		_update_detection_direction()

		move_and_slide()

		if global_position.distance_to(
			wander_target
		) < 8.0:

			_choose_next_wander()

	_check_player_detection()


# ==================================================
# Wandering
# ==================================================

func _choose_next_wander() -> void:

	wander_timer = randf_range(
		min_wander_time,
		max_wander_time
	)

	# ==================================================
	# Occasionally stop
	# ==================================================

	if randf() < idle_chance:

		is_wandering = false
		velocity = Vector2.ZERO
		return

	# ==================================================
	# Choose nearby position
	# ==================================================

	is_wandering = true

	var offset := Vector2(
		randf_range(
			-wander_radius,
			wander_radius
		),
		randf_range(
			-wander_radius,
			wander_radius
		)
	)

	wander_target = spawn_position + offset


# ==================================================
# Detection Direction
# ==================================================

func _update_detection_direction() -> void:

	if velocity.length() < 1.0:
		return

	var detection_area := get_node_or_null(
		"DetectionArea2D"
	)

	if detection_area == null:
		return

	detection_area.rotation = (
		velocity.angle() - PI / 2.0
	)


func _check_player_detection() -> void:

	if encountered:
		return

	var detection_area := get_node_or_null(
		"DetectionArea2D"
	)

	if detection_area == null:
		return

	var bodies: Array[Node2D] = (
		detection_area.get_overlapping_bodies()
	)

	for body in bodies:

		if not body is RoomPlayer:
			continue

		var player := body as RoomPlayer

		var effective_radius := (
			detection_radius
			* player.get_detection_multiplier()
		)

		var distance := (
			global_position.distance_to(
				player.global_position
			)
		)

		if distance > effective_radius:
			continue

		_start_encounter(player)

		return


func _start_encounter(
	player: RoomPlayer
) -> void:

	if encountered:
		return

	encountered = true

	velocity = Vector2.ZERO

	print("================================")
	print("ROAMING ENEMY DETECTED PLAYER")
	print("Distance:", global_position.distance_to(
		player.global_position
	))
	print("Detection multiplier:", player.get_detection_multiplier())
	print("================================")

	encounter_requested.emit(
		self
	)
