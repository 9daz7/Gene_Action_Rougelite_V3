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
var combat_controller: ActionCombatController = null

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
# Melee Attack
# ==================================================

const ATTACK_HITBOX_SCENE = preload(
	"res://Scenes/Battle/ActionAttackHitbox.tscn"
)

enum AttackState {
	IDLE,
	LUNGING,
	RETURNING,
	RECOVERING
}

var attack_state: AttackState = AttackState.IDLE

@export var melee_damage: float = 5.0
@export var melee_third_hit_damage: float = 7.0

@export var melee_lunge_distance: float = 45.0
@export var melee_lunge_duration: float = 0.10
@export var melee_recovery_duration: float = 0.25

var attack_timer: float = 0.0
var attack_target_position: Vector2
var active_attack_hitbox = null
var attack_direction: Vector2 = Vector2.RIGHT

var combo_step: int = 0
var combo_timer: float = 0.0
var combo_queued: bool = false


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


func set_combat_controller(
	controller: ActionCombatController
) -> void:

	combat_controller = controller


# ==================================================
# Input
# ==================================================

func _input(event: InputEvent) -> void:

	if not event is InputEventMouseButton:
		return

	if event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			_try_melee_attack()

		return

	if event.button_index == MOUSE_BUTTON_RIGHT:

		if event.pressed:
			is_aiming = true
		else:
			is_aiming = false


func _try_melee_attack() -> void:

	if combat_controller == null:
		return

	if combat_controller.player_position != (
		combat_controller.CombatPosition.FRONT
	):
		return

	if attack_state != AttackState.IDLE:
		return

	_start_melee_attack()


func _start_melee_attack() -> void:

	attack_start_position = (
		player_character.global_position
	)

	attack_direction = _get_attack_direction()

	attack_target_position = (
		attack_start_position
		+
		attack_direction
		* melee_lunge_distance
	)

	attack_state = AttackState.LUNGING
	attack_timer = 0.0

	_create_melee_hitbox()

	print("PLAYER MELEE ATTACK START")


func _get_attack_direction() -> Vector2:

	var targeting := (
		get_parent()
		.get_parent()
		.get_node_or_null("ActionTargeting")
	)

	if targeting != null:

		var target = targeting.get_selected_target()

		if target != null:
			if is_instance_valid(target):
				if target.is_alive():

					return (
						target.global_position
						- player_character.global_position
					).normalized()

	var controller := (
		player_character.get_node_or_null(
			"ActionPlayerCharacterController"
		)
	)

	if controller != null:

		if controller.facing_direction != Vector2.ZERO:
			return controller.facing_direction.normalized()

	return Vector2.RIGHT


func _update_attack_state(delta: float) -> void:

	match attack_state:

		AttackState.IDLE:
			pass

		AttackState.LUNGING:

			attack_timer += delta

			var progress := (
				attack_timer
				/ melee_lunge_duration
			)

			progress = clamp(
				progress,
				0.0,
				1.0
			)

			player_character.global_position = (
				attack_start_position.lerp(
					attack_target_position,
					progress
				)
			)

			if progress >= 1.0:

				attack_state = AttackState.RETURNING
				attack_timer = 0.0

		AttackState.RETURNING:

			attack_timer += delta

			var progress := (
				attack_timer
				/ melee_return_duration
			)

			progress = clamp(
				progress,
				0.0,
				1.0
			)

			if progress >= 1.0:

				player_character.global_position = (
					attack_start_position
				)

				attack_state = AttackState.RECOVERING
				attack_timer = (
					melee_recovery_duration
				)

				print(
					"PLAYER MELEE COMPLETE - RECOVERING"
				)

		AttackState.RECOVERING:

			attack_timer -= delta

			if attack_timer <= 0.0:

				attack_timer = 0.0
				attack_state = AttackState.IDLE

				print("PLAYER MELEE READY")


func _create_melee_hitbox() -> void:

	var hitbox: Node = (
		ATTACK_HITBOX_SCENE.instantiate()
	)

	if hitbox == null:
		push_error(
			"Failed to create player melee hitbox."
		)
		return

	var action_hitbox := (
		hitbox as ActionAttackHitbox
	)

	if action_hitbox == null:
		push_error(
			"Created node is not an ActionAttackHitbox."
		)
		return

	get_tree().current_scene.add_child(
		action_hitbox
	)

	action_hitbox.set_follow_target(
		player_character,
		attack_direction,
		40.0
	)

	action_hitbox.hitbox_timer = 0.15

	action_hitbox.global_position = (
		player_character.global_position
		+
		attack_direction * 40.0
	)

	action_hitbox.global_rotation = (
		attack_direction.angle()
	)

	action_hitbox.enemy_hit.connect(
		_on_melee_hit
	)

	active_attack_hitbox = action_hitbox

	# Build a temporary melee shape.
	var collision_shape := (
		action_hitbox.get_node_or_null(
			"CollisionShape2D"
		)
	)

	if collision_shape != null:

		var rectangle := RectangleShape2D.new()

		rectangle.size = Vector2(
			70.0,
			50.0
		)

		collision_shape.shape = rectangle
		collision_shape.disabled = false


func _on_melee_hit(enemy: AnimalBase) -> void:

	if enemy == null:
		return

	if not is_instance_valid(enemy):
		return

	if not enemy.is_alive():
		return

	print(
		"PLAYER MELEE HIT: ",
		enemy.name
	)

	enemy.take_damage(
		melee_damage
	)


# ==================================================
# Process
# ==================================================

func _process(delta: float) -> void:

	if player_character == null:
		return

	_update_attack_state(delta)

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
