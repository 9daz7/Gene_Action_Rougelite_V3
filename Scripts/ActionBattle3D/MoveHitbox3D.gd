extends Area3D
class_name MoveHitbox3D


# ==================================================
# Configuration
# ==================================================

var move_resource: MoveResource
var hitbox_owner: Node3D

var hit_enemies: Array[Node3D] = []

@onready var collision_shape: CollisionShape3D = $CollisionShape3D


# ==================================================
# Setup
# ==================================================

func configure(
	move: MoveResource,
	owner: Node3D
) -> void:

	move_resource = move
	hitbox_owner = owner

	if move_resource == null:
		push_error("MOVE HITBOX: MoveResource is missing.")
		return

	if move_resource.hitbox_type == MoveResource.HitboxType.NONE:
		push_warning("MOVE HITBOX: Move has no hitbox type.")
		return

	_create_collision_shape()


# ==================================================
# Collision Shape
# ==================================================

func _create_collision_shape() -> void:

	var shape: Shape3D

	match move_resource.hitbox_type:

		MoveResource.HitboxType.CIRCLE:

			var cylinder := CylinderShape3D.new()
			cylinder.radius = move_resource.hitbox_radius / 100.0
			cylinder.height = 1.2
			shape = cylinder


		MoveResource.HitboxType.RECTANGLE:

			var box := BoxShape3D.new()
			box.size = Vector3(
				move_resource.hitbox_size.x / 100.0,
				1.0,
				move_resource.hitbox_size.y / 100.0
			)
			shape = box


		MoveResource.HitboxType.CONE:

			# Temporary implementation:
			# Cone support will be added after basic shape testing.
			push_warning("MOVE HITBOX: Cone support is not implemented yet.")
			return


		_:

			push_warning("MOVE HITBOX: Unsupported hitbox type.")
			return

	collision_shape.shape = shape

	collision_shape.position.y = 0.6


# ==================================================
# Activate
# ==================================================

func activate() -> void:

	if move_resource == null:
		return

	if collision_shape.shape == null:
		return

	collision_layer = 0
	collision_mask = 8

	monitoring = true
	monitorable = false

	body_entered.connect(_on_body_entered)

	destroy_after_duration()


# ==================================================
# Enemy Detection
# ==================================================

func _on_body_entered(body: Node3D) -> void:

	if not body is CharacterBody3D:
		return

	if not body.has_method("take_damage"):
		return

	if hit_enemies.has(body):
		return

	# Single-target moves stop after their first successful hit.
	if (
		move_resource.target_type == MoveResource.TargetType.SINGLE_ENEMY
		and not hit_enemies.is_empty()
	):
		return

	hit_enemies.append(body)

	body.take_damage(move_resource.power)

	print(
		"MOVE HITBOX HIT: ",
		move_resource.move_name,
		" | Enemy: ",
		body.name,
		" | Damage: ",
		move_resource.power
	)


# ==================================================
# Lifetime
# ==================================================

func destroy_after_duration() -> void:

	if move_resource == null:
		queue_free()
		return

	await get_tree().create_timer(
		move_resource.hitbox_duration
	).timeout

	queue_free()
