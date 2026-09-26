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
	RECOVERING,
	DASHING,
	DODGING
}

var attack_state: AttackState = AttackState.IDLE

@export var melee_damage: float = 5.0
@export var melee_third_hit_damage: float = 7.0

@export var melee_lunge_distance: float = 25.0
@export var melee_lunge_duration: float = 0.10
@export var melee_recovery_duration: float = 0.25
@export var combo_window: float = 0.30

@export var dash_attack_damage: float = 10.0
@export var dash_attack_distance: float = 150.0
@export var dash_attack_duration: float = 0.15
@export var dash_attack_cooldown: float = 0.25

@export var dodge_distance: float = 100.0
@export var dodge_duration: float = 0.15
@export var dodge_invulnerability_duration: float = 0.12
@export var dodge_cooldown: float = 0.45

var dodge_timer: float = 0.0
var dodge_cooldown_timer: float = 0.0
var dodge_invulnerability_timer: float = 0.0

var attack_timer: float = 0.0
var attack_start_position: Vector2
var attack_target_position: Vector2
var active_attack_hitbox = null
var attack_direction: Vector2 = Vector2.RIGHT

var combo_step: int = 0
var combo_timer: float = 0.0
var combo_queued: bool = false
var melee_button_held: bool = false

var recovering_from_dash: bool = false

@export var combo_cooldown: float = 0.25
var combo_cooldown_timer: float = 0.0


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

	if event is InputEventKey:

		if event.pressed and not event.echo:

			if event.keycode == KEY_SPACE:
				_try_dodge()

		return

	if not event is InputEventMouseButton:
		return

	if event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			melee_button_held = true
			_try_melee_attack()
		else:
			melee_button_held = false

		return

	if event.button_index == MOUSE_BUTTON_RIGHT:

		if event.pressed:
			is_aiming = true
		else:
			is_aiming = false


func _try_melee_attack() -> void:

	if combat_controller == null:
		return

	if combat_controller.player_position == (
		combat_controller.CombatPosition.BACK
	):
		_try_dash_attack()
		return

	if combo_cooldown_timer > 0.0:
		return

	if attack_state != AttackState.IDLE:
		combo_queued = true
		return

	_start_melee_attack()


func _try_dash_attack() -> void:

	if attack_state != AttackState.IDLE:
		return

	_start_dash_attack()


func _try_dodge() -> void:

	if dodge_cooldown_timer > 0.0:
		return

	if attack_state != AttackState.IDLE:
		return

	_start_dodge()


func _start_dodge() -> void:

	var controller := (
		player_character.get_node_or_null(
			"ActionPlayerCharacterController"
		)
	)

	if controller == null:
		return

	var dodge_direction: Vector2 = controller.facing_direction

	if dodge_direction == Vector2.ZERO:
		dodge_direction = Vector2.RIGHT

	attack_direction = dodge_direction.normalized()

	attack_start_position = (
		player_character.global_position
	)

	attack_target_position = (
		attack_start_position
		+ attack_direction * dodge_distance
	)

	dodge_timer = 0.0
	dodge_invulnerability_timer = dodge_invulnerability_duration

	attack_state = AttackState.DODGING

	print("PLAYER DODGE START")


func _start_melee_attack() -> void:

	combo_step += 1

	if combo_step > 3:
		combo_step = 1

	combo_timer = 0.0

	attack_direction = _get_attack_direction()

	attack_start_position = player_character.global_position

	var lunge_distance := melee_lunge_distance

	attack_target_position = (
		player_character.global_position
		+ attack_direction * lunge_distance
	)

	attack_timer = 0.0
	attack_state = AttackState.LUNGING

	_create_melee_hitbox()

	print(
		"PLAYER MELEE ATTACK ",
		combo_step,
		" START"
	)


func _start_dash_attack() -> void:

	attack_direction = _get_attack_direction()

	attack_start_position = player_character.global_position

	attack_target_position = (
		attack_start_position
		+ attack_direction * dash_attack_distance
	)

	combat_controller.player_dash_active = true

	attack_timer = 0.0
	attack_state = AttackState.DASHING

	print("PLAYER DASH ATTACK START")


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

		AttackState.LUNGING:

			attack_timer += delta

			var progress := (
				attack_timer
				/ melee_lunge_duration
			)

			progress = min(progress, 1.0)

			player_character.global_position = (
				attack_start_position.lerp(
					attack_target_position,
					progress
				)
			)

			if progress >= 1.0:

				attack_state = AttackState.RECOVERING
				attack_timer = 0.0

				print(
					"PLAYER MELEE ",
					combo_step,
					" COMPLETE - RECOVERING"
				)


		AttackState.RECOVERING:
			
			attack_timer += delta

			var recovery_duration := melee_recovery_duration

			if recovering_from_dash:
				recovery_duration = dash_attack_cooldown

			if attack_timer >= recovery_duration:
				attack_state = AttackState.IDLE
				attack_timer = 0.0

				if recovering_from_dash:
					recovering_from_dash = false

				else:
					_combo_attack_finished()

		AttackState.DASHING:

			attack_timer += delta

			var progress := (
				attack_timer
				/ dash_attack_duration
			)

			progress = min(progress, 1.0)

			player_character.global_position = (
				attack_start_position.lerp(
					attack_target_position,
					progress
				)
			)

			if progress >= 1.0:
				_create_dash_attack_hitbox()
				combat_controller.set_player_front()
				combat_controller.player_dash_active = false
				combat_controller.reposition_deebo_to_formation()

				recovering_from_dash = true

				attack_state = AttackState.RECOVERING
				attack_timer = 0.0

				print(
					"PLAYER DASH IMPACT"
				)

		AttackState.DODGING:

			dodge_timer += delta

			var progress := (
				dodge_timer
				/ dodge_duration
			)

			progress = min(progress, 1.0)

			player_character.global_position = (
				attack_start_position.lerp(
					attack_target_position,
					progress
				)
			)

			if progress >= 1.0:

				attack_state = AttackState.IDLE
				dodge_timer = 0.0

				dodge_cooldown_timer = dodge_cooldown

				dodge_invulnerability_timer = 0.0

				print("PLAYER DODGE COMPLETE")


func _update_dodge_timers(delta: float) -> void:

	if dodge_cooldown_timer > 0.0:

		dodge_cooldown_timer -= delta

		if dodge_cooldown_timer < 0.0:
			dodge_cooldown_timer = 0.0

	if dodge_invulnerability_timer > 0.0:

		dodge_invulnerability_timer -= delta

		if dodge_invulnerability_timer < 0.0:
			dodge_invulnerability_timer = 0.0


func _combo_attack_finished() -> void:

	if combo_step == 3:
		combo_queued = false
		combo_timer = 0.0
		combo_cooldown_timer = combo_cooldown
		print("PLAYER COMBO COMPLETE - COOLDOWN")
		return

	if combo_queued:
		combo_queued = false
		_start_melee_attack()
		return

	if melee_button_held:
		_start_melee_attack()
		return

	combo_timer = combo_window


func _create_melee_hitbox() -> void:

	var hitbox = (
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

	var damage := melee_damage

	if combo_step == 3:
		damage = melee_third_hit_damage

	print(
		"PLAYER MELEE HIT: ",
		enemy.name,
		" | Combo: ",
		combo_step,
		" | Damage: ",
		damage
	)

	enemy.take_damage(damage)


func cancel_player_attack() -> void:

	attack_state = AttackState.IDLE
	attack_timer = 0.0

	combo_step = 0
	combo_timer = 0.0
	combo_queued = false
	combo_cooldown_timer = 0.0
	recovering_from_dash = false

	if active_attack_hitbox != null:
		active_attack_hitbox.queue_free()
		active_attack_hitbox = null

	print("PLAYER ATTACK CANCELED")


func is_dodging() -> bool:

	return dodge_invulnerability_timer > 0.0


func _create_dash_attack_hitbox() -> void:

	var hitbox = ATTACK_HITBOX_SCENE.instantiate()

	if hitbox == null:
		push_error(
			"Failed to create dash attack hitbox."
		)
		return

	var action_hitbox := (
		hitbox as ActionAttackHitbox
	)

	if action_hitbox == null:
		push_error(
			"Dash attack hitbox is not ActionAttackHitbox."
		)
		return

	get_tree().current_scene.add_child(
		action_hitbox
	)

	action_hitbox.global_position = (
		player_character.global_position
	)

	action_hitbox.hitbox_timer = 0.15

	action_hitbox.enemy_hit.connect(
		_on_dash_attack_hit
	)

	active_attack_hitbox = action_hitbox

	var collision_shape := (
		action_hitbox.get_node_or_null(
			"CollisionShape2D"
		)
	)

	if collision_shape != null:
		var circle := CircleShape2D.new()
		circle.radius = 45.0

		collision_shape.shape = circle
		collision_shape.disabled = false


func _on_dash_attack_hit(enemy: AnimalBase) -> void:

	print(
		"PLAYER DASH ATTACK HIT: ",
		enemy.name,
		" | Damage: ",
		dash_attack_damage
	)

	enemy.take_damage(
		dash_attack_damage
	)


# ==================================================
# Process
# ==================================================

func _process(delta: float) -> void:

	if player_character == null:
		return

	_update_attack_state(delta)
	_update_dodge_timers(delta)
	_update_combo_cooldown(delta)
	_update_combo_timer(delta)

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


func _update_combo_timer(delta: float) -> void:

	if combo_timer <= 0.0:
		return

	combo_timer -= delta

	if combo_timer <= 0.0:

		combo_timer = 0.0
		combo_step = 0
		combo_queued = false

		print("PLAYER COMBO RESET")


func _update_combo_cooldown(delta: float) -> void:

	if combo_cooldown_timer <= 0.0:
		return

	combo_cooldown_timer -= delta

	if combo_cooldown_timer <= 0.0:
		combo_cooldown_timer = 0.0
		combo_step = 0

		print("PLAYER COMBO COOLDOWN COMPLETE")

		if melee_button_held:
			_start_melee_attack()


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
