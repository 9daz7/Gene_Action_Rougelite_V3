extends Area3D

@export var damage: float = 10.0
@export var hitbox_size: Vector3 = Vector3(0.8, 1.0, 1.8)

var hit_targets: Array[Node] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	var target: Node = body

	while target != null and not target.has_method("take_damage"):
		target = target.get_parent()

	if target == null or hit_targets.has(target):
		return

	hit_targets.append(target)
	target.take_damage(damage)
	print("Stab hit: ", target.name)


func configure_hitbox(size: Vector3, attack_damage: float) -> void:

	damage = attack_damage
	hitbox_size = size

	var collision_shape := get_node_or_null("CollisionShape3D") as CollisionShape3D

	if collision_shape and collision_shape.shape is BoxShape3D:
		var box := collision_shape.shape.duplicate() as BoxShape3D
		box.size = hitbox_size
		collision_shape.shape = box
