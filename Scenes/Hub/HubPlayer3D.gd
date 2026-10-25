extends CharacterBody3D
class_name HubPlayer3D

# Movement
@export var walk_speed: float = 3.0
@export var sprint_speed: float = 5.5
@export var crouch_speed: float = 1.5

var controls_enabled: bool = true
var is_sprinting: bool = false
var is_crouching: bool = false

# Dash
@export var dash_speed: float = 12.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 0.8

var is_dashing: bool = false
var dash_direction: Vector3 = Vector3.ZERO
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

var nearby_interactable: Node = null


func set_controls_enabled(enabled: bool) -> void:

	controls_enabled = enabled

	if not enabled:
		velocity = Vector3.ZERO
		is_sprinting = false
		is_crouching = false
		is_dashing = false
		dash_timer = 0.0


func _physics_process(delta: float) -> void:

	if not controls_enabled:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	dash_cooldown_timer = maxf(dash_cooldown_timer - delta, 0.0)

	var input := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	var direction := Vector3(input.x, 0.0, input.y).normalized()

	# Start dash using the same input as the run-room player.
	if (
		Input.is_action_just_pressed("ui_accept")
		and not is_dashing
		and dash_cooldown_timer <= 0.0
	):
		_start_dash(direction)

	if is_dashing:
		dash_timer -= delta

		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed

		if dash_timer <= 0.0:
			is_dashing = false
	else:
		is_crouching = Input.is_action_pressed("crouch")
		is_sprinting = (
			Input.is_action_pressed("sprint")
			and not is_crouching
			and direction.length_squared() > 0.0
		)

		var speed := walk_speed

		if is_crouching:
			speed = crouch_speed
		elif is_sprinting:
			speed = sprint_speed

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

	move_and_slide()


func _start_dash(direction: Vector3) -> void:

	if direction.length_squared() <= 0.001:
		return

	dash_direction = direction
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	is_dashing = true

	# Dash interrupts sprinting and crouching.
	is_sprinting = false
	is_crouching = false


func set_nearby_interactable(interactable: Node) -> void:

	nearby_interactable = interactable
