extends Node
class_name ActionPlayerCombatController


# ==================================================
# Scenes
# ==================================================

const SLINGSHOT_PROJECTILE = preload(
	"res://Scenes/Battle/SlingshotProjectile.tscn"
)


# ==================================================
# References
# ==================================================

var player_character: CharacterBody2D = null

@onready var aim_line: Line2D = get_parent().get_node_or_null(
	"AimLine"
)


# ==================================================
# Aim State
# ==================================================

var is_aiming: bool = false
var aim_direction: Vector2 = Vector2.RIGHT


# ==================================================
# Slingshot Charge
# ==================================================

@export var min_projectile_speed: float = 500.0
@export var max_projectile_speed: float = 1200.0
@export var max_charge_time: float = 2
@export var min_projectile_distance: float = 450.0
@export var max_projectile_distance: float = 950.0

var charge_time: float = 0.0
var charge_power: float = 0.0


# ==================================================
# Setup
# ==================================================

func _ready() -> void:

	player_character = get_parent() as CharacterBody2D

	if player_character == null:

		push_error(
			"ActionPlayerCombatController must be "
			+ "a child of a CharacterBody2D."
		)

		return

	if aim_line == null:

		push_error(
			"AimLine not found on ActionPlayerCharacter."
		)

		return

	aim_line.visible = false

	print("ActionPlayerCombatController ready")


# ==================================================
# Input
# ==================================================

func _input(event: InputEvent) -> void:

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_RIGHT:

			if event.pressed:

				is_aiming = true

			else:

				is_aiming = false


# ==================================================
# Process
# ==================================================

func _process(delta: float) -> void:

	if player_character == null:
		return

	if not is_aiming:
		aim_line.visible = false
		charge_time = 0.0
		charge_power = 0.0
		return

	_update_aim()

	charge_time += delta

	charge_power = clamp(
		charge_time / max_charge_time,
		0.0,
		1.0
	)

	if Input.is_action_just_pressed("player_fire"):
		_fire_slingshot()


# ==================================================
# Aim
# ==================================================

func _update_aim() -> void:

	var mouse_position := (
		player_character.get_global_mouse_position()
	)

	aim_direction = (
		mouse_position
		- player_character.global_position
	).normalized()

	var aim_distance: float = lerp(
		min_projectile_distance,
		max_projectile_distance,
		charge_power
	)

	var aim_alpha: float = lerp(
		0.35,
		1.0,
		charge_power
	)

	aim_line.self_modulate.a = aim_alpha

	aim_line.visible = true

	aim_line.points = PackedVector2Array([
		Vector2.ZERO,
		aim_direction * aim_distance
	])


# ==================================================
# Slingshot
# ==================================================

func _fire_slingshot() -> void:

	var projectile := SLINGSHOT_PROJECTILE.instantiate()

	get_tree().current_scene.add_child(projectile)

	projectile.global_position = (
		player_character.global_position
	)

	var projectile_speed: float = lerp(
		min_projectile_speed,
		max_projectile_speed,
		charge_power
	)

	var projectile_distance: float = lerp(
		min_projectile_distance,
		max_projectile_distance,
		charge_power
	)

	projectile.setup(
		aim_direction,
		projectile_speed,
		projectile_distance
	)

	charge_time = 0.0
	charge_power = 0.0
