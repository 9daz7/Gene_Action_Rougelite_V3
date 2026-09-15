extends Area2D
class_name SlingshotProjectile


# ==================================================
# Settings
# ==================================================

@export var speed: float = 600.0
@export var damage: int = 5
@export var lifetime: float = 2.0


# ==================================================
# State
# ==================================================

var direction: Vector2 = Vector2.RIGHT
var max_distance: float = 600.0
var distance_traveled: float = 0.0


# ==================================================
# Setup
# ==================================================

func setup(
	aim_direction: Vector2,
	projectile_speed: float,
	projectile_distance: float
) -> void:

	direction = aim_direction.normalized()
	speed = projectile_speed
	max_distance = projectile_distance


# ==================================================
# Process
# ==================================================

func _physics_process(delta: float) -> void:

	var movement_distance: float = speed * delta

	position += direction * movement_distance

	distance_traveled += movement_distance

	if distance_traveled >= max_distance:

		queue_free()


# ==================================================
# Collision
# ==================================================

func _on_body_entered(body: Node) -> void:

	if not body is AnimalBase:
		return

	var animal := body as AnimalBase

	if not animal.is_alive():
		return

	animal.take_damage(
		damage,
		null
	)

	queue_free()
