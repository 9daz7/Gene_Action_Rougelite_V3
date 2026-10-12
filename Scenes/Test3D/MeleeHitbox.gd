extends Area3D

@export var damage: float = 10.0
@export var hitbox_size: Vector3 = Vector3(0.8, 1.0, 1.8)

@export var knockback_strength: float = 0.0

var hit_targets: Array[Node] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:

	print("HITBOX DETECTED BODY: ", body.name)

	var target: Node = body

	while target != null and not target.has_method("take_damage"):
		target = target.get_parent()

	if target == null or hit_targets.has(target):
		return

	hit_targets.append(target)
	print("HITBOX DEALING DAMAGE: ", target.name, " | ", damage)
	target.take_damage(damage)
	print("Stab hit: ", target.name)

	if knockback_strength > 0.0 and target is CharacterBody3D:
		var target_body := target as CharacterBody3D
		var direction: Vector3 = target_body.global_position - global_position
		direction.y = 0.0

		if direction.length_squared() > 0.001:
			direction = direction.normalized()
			target_body.velocity.x = direction.x * knockback_strength
			target_body.velocity.z = direction.z * knockback_strength


func configure_hitbox(size: Vector3, attack_damage: float) -> void:

	damage = attack_damage
	hitbox_size = size

	var collision_shape := get_node_or_null("CollisionShape3D") as CollisionShape3D

	if collision_shape and collision_shape.shape is BoxShape3D:
		var box := collision_shape.shape.duplicate() as BoxShape3D
		box.size = hitbox_size
		collision_shape.shape = box
