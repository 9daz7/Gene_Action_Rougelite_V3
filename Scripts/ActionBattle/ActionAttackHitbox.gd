extends Area2D
class_name ActionAttackHitbox


# ==================================================
# Detection
# ==================================================

var detected_enemies: Array[AnimalBase] = []
var move: MoveResource = null
var hitbox_timer: float = 0.0


# ==================================================
# Setup
# ==================================================

func setup(action_move: MoveResource) -> void:

	move = action_move
	hitbox_timer = move.hitbox_duration

	print(
		"ACTION HITBOX SETUP | Move:",
		move.move_name,
		"| Type:",
		move.hitbox_type,
		"| Radius:",
		move.hitbox_radius,
		"| Size:",
		move.hitbox_size,
		"| Offset:",
		move.hitbox_offset
	)

	_build_hitbox_shape()


# ==================================================
# Build Hitbox Shape
# ==================================================

func _build_hitbox_shape() -> void:

	var collision_shape := get_node_or_null(
		"CollisionShape2D"
	)

	if collision_shape == null:
		push_error(
			"ActionAttackHitbox is missing CollisionShape2D."
		)
		return

	if move == null:
		return

	match move.hitbox_type:

		MoveResource.HitboxType.CIRCLE:

			var circle := CircleShape2D.new()
			circle.radius = move.hitbox_radius

			collision_shape.shape = circle

		MoveResource.HitboxType.RECTANGLE:

			var rectangle := RectangleShape2D.new()
			rectangle.size = move.hitbox_size

			collision_shape.shape = rectangle

		MoveResource.HitboxType.CONE:

			collision_shape.disabled = true

			var collision_polygon := get_node_or_null(
				"CollisionPolygon2D"
			)

			if collision_polygon == null:
				push_error(
					"ActionAttackHitbox is missing CollisionPolygon2D."
				)
				return

			collision_polygon.disabled = false

			var points := PackedVector2Array()

			# Cone starts at the hitbox origin.
			points.append(Vector2.ZERO)

			var half_angle := deg_to_rad(
				move.hitbox_angle / 2.0
			)

			var steps := 12

			for i in range(steps + 1):

				var t := float(i) / float(steps)

				var angle: float = lerp(
					-half_angle,
					half_angle,
					t
				)

				var point := Vector2.RIGHT.rotated(angle) * move.hitbox_radius

				points.append(point)

			collision_polygon.polygon = points

		MoveResource.HitboxType.NONE:

			collision_shape.disabled = true

		_:

			push_warning(
				"Unsupported hitbox type: "
				+ str(move.hitbox_type)
			)


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("ActionAttackHitbox ready")

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# ==================================================
# Enemy Detection
# ==================================================

func _on_body_entered(body: Node2D) -> void:

	if not body is AnimalBase:
		return

	var enemy := body as AnimalBase

	if not enemy.is_alive():
		return

	if enemy in detected_enemies:
		return

	detected_enemies.append(enemy)

	print(
		"ACTION HITBOX ENTERED: ",
		enemy.name
	)


func _on_body_exited(body: Node2D) -> void:

	if not body is AnimalBase:
		return

	var enemy := body as AnimalBase

	if enemy in detected_enemies:
		detected_enemies.erase(enemy)

	print(
		"ACTION HITBOX EXITED: ",
		enemy.name
	)


# ==================================================
# Public Access
# ==================================================

func get_detected_enemies() -> Array[AnimalBase]:

	for enemy in detected_enemies.duplicate():

		if not is_instance_valid(enemy):
			detected_enemies.erase(enemy)
			continue

		if not enemy.is_alive():
			detected_enemies.erase(enemy)

	return detected_enemies


# ==================================================
# Hitbox Lifetime
# ==================================================

func _physics_process(delta: float) -> void:

	hitbox_timer -= delta

	if hitbox_timer <= 0.0:

		queue_free()
