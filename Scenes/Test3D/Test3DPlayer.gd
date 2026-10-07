extends CharacterBody3D

@export var move_speed: float = 5.0

@onready var animated_sprite: AnimatedSprite3D = $AnimatedSprite3D


func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var direction := Vector3(
		input.x,
		0.0,
		input.y
	)

	if direction.length() > 0.0:
		direction = direction.normalized()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed

		animated_sprite.play("walk")
	else:
		velocity.x = 0.0
		velocity.z = 0.0

		animated_sprite.play("idle")

	move_and_slide()
