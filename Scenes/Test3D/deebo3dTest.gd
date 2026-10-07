extends CharacterBody3D

@export var target: CharacterBody3D
@export var follow_distance: float = 1.5
@export var move_speed: float = 4.0

func _physics_process(_delta: float) -> void:
	if target == null:
		return

	var offset := target.global_position - global_position
	offset.y = 0.0

	var distance := offset.length()

	if distance > follow_distance:
		var direction := offset.normalized()

		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
