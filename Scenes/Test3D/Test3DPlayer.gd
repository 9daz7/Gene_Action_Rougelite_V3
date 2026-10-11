extends CharacterBody3D

# --------------------------------------------------
# Movement
# --------------------------------------------------

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

var facing_direction: Vector3 = Vector3.FORWARD

@onready var animated_sprite: AnimatedSprite3D = $AnimatedSprite3D

var sprite_rest_position: Vector3
var is_slam_animating: bool = false

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

var combo_step: int = 0
var combo_timer: float = 0.0

# --------------------------------------------------
# Health
# --------------------------------------------------

@export var max_health: float = 100.0
var current_health: float = 100.0
var is_dead: bool = false


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


func _physics_process(delta: float) -> void:

	if is_dead:
		velocity = Vector3.ZERO
		move_and_slide()
		return

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
		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed

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

		velocity.x = direction.x * current_move_speed
		velocity.z = direction.z * current_move_speed

	move_and_slide()

	# Update melee combo reset timer.
	if combo_step > 0:
		combo_timer -= delta

		if combo_timer <= 0.0:
			combo_step = 0

	if Input.is_action_pressed("player_attack") \
			and can_attack \
			and not is_dashing:
		_perform_melee_attack()


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
	_play_melee_lunge(aim_direction)

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

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


# --------------------------------------------------
# Damage and Death
# --------------------------------------------------

func take_damage(amount: float) -> void:

	if is_dead or amount <= 0.0:
		return

	current_health = maxf(current_health - amount, 0.0)

	print("Player took ", amount, " damage. Health: ",
		current_health, "/", max_health)

	if current_health <= 0.0:
		_die()


func _die() -> void:

	if is_dead:
		return

	is_dead = true
	velocity = Vector3.ZERO

	print("Player has been defeated.")
