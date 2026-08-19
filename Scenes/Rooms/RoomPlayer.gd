extends CharacterBody2D
class_name RoomPlayer


# ==================================================
# Movement
# ==================================================

@export var move_speed: float = 200.0


# ==================================================
# Camera
# ==================================================

@onready var camera: Camera2D = $Camera2D


# ==================================================
# State
# ==================================================

var controls_enabled: bool = true


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("RoomPlayer ready")

	if camera != null:

		camera.make_current()

		print(
			"RoomPlayer camera current:",
			camera.is_current()
		)

# ==================================================
# Physics
# ==================================================

func _physics_process(_delta: float) -> void:

	if not controls_enabled:
		velocity = Vector2.ZERO
		return
		
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * move_speed

	move_and_slide()	


# ==================================================
# Controls
# ==================================================

func set_controls_enabled(
	enabled: bool
) -> void:

	controls_enabled = enabled

	if not enabled:

		velocity = Vector2.ZERO

	print(
		"RoomPlayer controls:",
		controls_enabled
	)
