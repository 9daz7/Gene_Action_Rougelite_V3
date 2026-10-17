extends CharacterBody3D


signal health_changed(current_health: float, max_health: float)
signal died


# --------------------------------------------------
# Movement
# --------------------------------------------------

var controls_enabled: bool = true

@export var walk_speed: float = 3.0
@export var sprint_speed: float = 5.5
@export var crouch_speed: float = 1.5

var current_move_speed: float = 3.0
var is_sprinting: bool = false
var is_crouching: bool = false

@export var dash_speed: float = 12.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 0.8

var is_dashing: bool = false
var dash_direction: Vector3 = Vector3.ZERO
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

@export var attack_cooldown: float = 0.4

var can_attack: bool = true
var is_melee_attacking: bool = false

var facing_direction: Vector3 = Vector3.FORWARD

@onready var animated_sprite: AnimatedSprite3D = $AnimatedSprite3D

var sprite_rest_position: Vector3
var is_slam_animating: bool = false

# --------------------------------------------------
# Combat
# --------------------------------------------------

const MELEE_HITBOX_SCENE: PackedScene = preload(
	"res://Scenes/Test3D/MeleeHitbox.tscn"
)

@export var melee_lunge_distance: float = 0.5
@export var melee_lunge_duration: float = 0.1

@export var stab_offset: float = 1.0
@export var stab_duration: float = 0.15
@export var stab_damage: float = 8.0

@export var swipe_offset: float = 0.9
@export var swipe_duration: float = 0.2
@export var swipe_damage: float = 8.0

@export var slam_offset: float = 1.2
@export var slam_duration: float = 0.35
@export var slam_damage: float = 12.0
@export var slam_height: float = 0.8

@export var attack_origin_offset: float = 0.5

@export var combo_reset_time: float = 0.9

@export var combat_controller: ActionCombatController3D

var combo_step: int = 0
var combo_timer: float = 0.0

@export var slam_recovery: float = 0.25
@export var slam_knockback: float = 8.0

var is_performing_slam: bool = false

@export var back_slam_travel_distance: float = 2.0
@export var back_slam_travel_duration: float = 0.23
@export var back_slam_landing_offset: float = 0.2


# --------------------------------------------------
# Health
# --------------------------------------------------

@export var max_health: float = 100.0
var current_health: float = 100.0
var is_dead: bool = false
var death_processed: bool = false


func _ready() -> void:

	sprite_rest_position = animated_sprite.position
	current_health = max_health
	current_move_speed = walk_speed


func _play_melee_lunge(aim_direction: Vector3) -> void:

	var start_position := global_position
	var target_position := start_position + aim_direction * melee_lunge_distance

	var tween := create_tween()
	tween.tween_property(
		self,
		"global_position",
		target_position,
		melee_lunge_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await tween.finished


func _play_slam_animation() -> void:

	if is_slam_animating:
		return

	is_slam_animating = true

	var tween := create_tween()

	# Wind up: raise the sprite.
	tween.tween_property(
		animated_sprite,
		"position",
		sprite_rest_position + Vector3.UP * slam_height,
		0.15
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Slam down: return to the original position.
	tween.tween_property(
		animated_sprite,
		"position",
		sprite_rest_position,
		0.08
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await tween.finished

	# Ensure the sprite finishes exactly where it started.
	animated_sprite.position = sprite_rest_position
	is_slam_animating = false


func _perform_back_slam() -> void:

	if is_performing_slam or is_dead or is_dashing:
		return

	if combat_controller == null:
		return

	if not combat_controller.begin_action(&"player_slam"):
		return

	is_performing_slam = true
	can_attack = false

	var aim_direction: Vector3 = get_mouse_aim_direction()
	var deebo_start_position: Vector3 = combat_controller.deebo.global_position

	# landing toward Deebo's starting position.
	var horizontal_to_deebo: Vector3 = deebo_start_position - global_position
	horizontal_to_deebo.y = 0.0

	var landing_direction: Vector3 = aim_direction

	if horizontal_to_deebo.length_squared() > 0.001:
		landing_direction = horizontal_to_deebo.normalized()

	var landing_position: Vector3 = (
		global_position
		+ landing_direction * back_slam_travel_distance
	)

	if horizontal_to_deebo.length() > 0.001:
		landing_position = (
			deebo_start_position
			+ landing_direction * back_slam_landing_offset
		)

	landing_position.y = global_position.y

	# Jump visually and travel forward at the same time.
	var travel_tween := create_tween()
	travel_tween.tween_property(
		self,
		"global_position",
		landing_position,
		back_slam_travel_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	_play_slam_animation()

	await travel_tween.finished

	if is_dead:
		combat_controller.finish_action(&"player_slam")
		is_performing_slam = false
		return

	var hitbox := MELEE_HITBOX_SCENE.instantiate() as Area3D

	if hitbox == null:
		push_error("MeleeHitbox scene root must be an Area3D.")
		combat_controller.finish_action(&"player_slam")
		is_performing_slam = false
		can_attack = true
		return

	get_tree().current_scene.add_child(hitbox)

	hitbox.configure_hitbox(
		Vector3(2.4, 1.0, 2.4),
		slam_damage
	)

	hitbox.knockback_strength = slam_knockback

	hitbox.global_position = (
		global_position
		+ aim_direction * slam_offset
		+ Vector3.UP * 0.5
	)

	hitbox.global_rotation.y = atan2(
		-aim_direction.x,
		-aim_direction.z
	)

	# Keep the hitbox active briefly to detect nearby enemies.
	await get_tree().create_timer(slam_duration).timeout

	if is_instance_valid(hitbox):
		hitbox.queue_free()

	if is_dead:
		combat_controller.finish_action(&"player_slam")
		is_performing_slam = false
		return

	# Move Deebo behind the player, making the player FRONT.
	combat_controller.start_slam_swap()

	while combat_controller.is_swapping:
		await get_tree().process_frame

	await get_tree().create_timer(slam_recovery).timeout

	combat_controller.finish_action(&"player_slam")

	is_performing_slam = false
	can_attack = true


func set_controls_enabled(enabled: bool) -> void:

	controls_enabled = enabled

	if not enabled:
		velocity = Vector3.ZERO
		is_dashing = false
		dash_timer = 0.0
		is_sprinting = false
		is_crouching = false


func _physics_process(delta: float) -> void:

	if is_dead:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if not controls_enabled:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	var action_movement_multiplier: float = 1.0

	if (
		combat_controller != null
		and combat_controller.is_action_locked
		and combat_controller.current_action != &"swap"
	):
		action_movement_multiplier = 0.6

	if can_attack == false:
		action_movement_multiplier = minf(
			action_movement_multiplier,
			0.6
		)

	if (
		combat_controller != null
		and combat_controller.is_action_locked
		and combat_controller.current_action != &"swap"
	):
		action_movement_multiplier = 0.6

	# Update dash cooldown.
	dash_cooldown_timer = maxf(
		dash_cooldown_timer - delta, 0.0
	)

	# Read movement input.
	var input := Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)

	var direction := Vector3(input.x, 0.0, input.y)

	if direction.length_squared() > 0.0:
		direction = direction.normalized()
		facing_direction = direction

	# Dash takes priority over normal movement.
	if Input.is_action_just_pressed("ui_accept") \
			and not is_dashing \
			and dash_cooldown_timer <= 0.0:
		_start_dash(direction)

	if is_dashing:
		dash_timer -= delta
		velocity.x = (
			dash_direction.x
			* dash_speed
			* action_movement_multiplier
		)
		velocity.z = (
			dash_direction.z
			* dash_speed
			* action_movement_multiplier
		)

		if dash_timer <= 0.0:
			is_dashing = false
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		# Sprint and crouch cannot be active together.
		is_crouching = Input.is_action_pressed("crouch")

		is_sprinting = (
			Input.is_action_pressed("sprint")
			and not is_crouching
			and direction.length_squared() > 0.0
		)

		if is_crouching:
			current_move_speed = crouch_speed
		elif is_sprinting:
			current_move_speed = sprint_speed
		else:
			current_move_speed = walk_speed

		var effective_move_speed: float = (
			current_move_speed * action_movement_multiplier
		)

		velocity.x = direction.x * effective_move_speed
		velocity.z = direction.z * effective_move_speed

	move_and_slide()

	# Update melee combo reset timer.
	if combo_step > 0:
		combo_timer -= delta

		if combo_timer <= 0.0:
			combo_step = 0

	if Input.is_action_pressed("player_attack") \
			and can_attack \
			and not is_dashing \
			and combat_controller != null:

		if combat_controller.player_position \
				== ActionCombatController3D.CombatPosition.FRONT:
			_perform_melee_attack()

		elif combat_controller.player_position \
				== ActionCombatController3D.CombatPosition.BACK:
			_perform_back_slam()


func _start_dash(direction: Vector3) -> void:

	if direction.length_squared() <= 0.001:
		direction = facing_direction

	dash_direction = direction.normalized()
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	is_dashing = true

	# A dash interrupts crouching and sprinting.
	is_crouching = false
	is_sprinting = false


func get_facing_direction() -> Vector3:

	return facing_direction


func get_movement_noise() -> float:

	if is_dashing:
		return 1.0
	if is_crouching:
		return 0.1
	if is_sprinting:
		return 0.8
	if velocity.length() > 0.1:
		return 0.35

	return 0.0


func get_mouse_aim_direction() -> Vector3:

	var camera := get_viewport().get_camera_3d()

	if camera == null:
		return facing_direction

	var mouse_position := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)

	# Intersect the mouse ray with the player's ground plane.
	var ground_plane := Plane(Vector3.UP, global_position.y)
	var intersection = ground_plane.intersects_ray(
		ray_origin,
		ray_direction
	)

	if intersection == null:
		return facing_direction

	var aim_direction: Vector3 = intersection - global_position
	aim_direction.y = 0.0

	if aim_direction.length_squared() < 0.001:
		return facing_direction

	return aim_direction.normalized()


func _perform_melee_attack() -> void:

	if not can_attack:
		return

	can_attack = false

	var aim_direction := get_mouse_aim_direction()
	await _play_melee_lunge(aim_direction)

	var hitbox := MELEE_HITBOX_SCENE.instantiate() as Area3D
	var attack_size := Vector3(0.8, 1.0, 1.8)

	if hitbox == null:
		push_error("MeleeHitbox scene root must be an Area3D.")
		can_attack = true
		return

	var attack_duration: float = stab_duration
	var attack_offset: float = stab_offset
	var attack_name: String = "STAB"

	match combo_step:
		0:
			attack_name = "STAB"
			attack_duration = stab_duration
			attack_offset = stab_offset
			hitbox.damage = stab_damage

		1:
			attack_name = "SWIPE"
			attack_duration = swipe_duration
			attack_offset = swipe_offset
			hitbox.damage = swipe_damage
			attack_size = Vector3(1.8, 1.0, 1.5)

		2:
			attack_name = "SLAM"
			attack_duration = slam_duration
			attack_offset = slam_offset
			hitbox.damage = slam_damage
			attack_size = Vector3(2.4, 1.0, 2.4)

	get_tree().current_scene.add_child(hitbox)

	hitbox.configure_hitbox(attack_size, hitbox.damage)

	var attack_origin := global_position \
		+ aim_direction * attack_origin_offset

	hitbox.global_position = attack_origin \
		+ aim_direction * attack_offset \
		+ Vector3.UP * 0.5

	hitbox.global_rotation.y = atan2(
		-aim_direction.x,
		-aim_direction.z
	)

	if combo_step == 2:
		_play_slam_animation()

	print(attack_name, " HITBOX SPAWNED — aim: ", aim_direction)

	combo_step = (combo_step + 1) % 3
	combo_timer = combo_reset_time

	await get_tree().create_timer(attack_duration).timeout

	if is_instance_valid(hitbox):
		hitbox.queue_free()

	if is_dead:
		return

	await get_tree().create_timer(attack_cooldown).timeout

	if is_dead:
		return

	can_attack = true


# --------------------------------------------------
# Damage and Death
# --------------------------------------------------

func take_damage(amount: float) -> void:

	if is_dead or amount <= 0.0:
		return

	print("PLAYER HIT: ", amount, " damage. Current health: ", current_health)

	current_health = maxf(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)

	print("Player took ", amount, " damage. Health: ",
		current_health, "/", max_health)

	if current_health <= 0.0:
		_die()


func _die() -> void:

	if is_dead:
		return

	is_dead = true

	# Stop movement and prevent further combat actions.
	velocity = Vector3.ZERO
	is_dashing = false
	dash_timer = 0.0
	can_attack = false

	## Stop any active player tweens.
	#for tween in get_tree().get_processed_tweens():
		#if tween.is_valid() and tween.is_running():
			#if tween.bind_node == self:
				#tween.kill()

	died.emit()

	print("Player has been defeated.")
