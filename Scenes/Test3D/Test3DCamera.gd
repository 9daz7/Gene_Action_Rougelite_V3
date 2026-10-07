extends Camera3D

@export var target: Node3D
@export var follow_offset: Vector3 = Vector3(0.0, 5.0, 4.5)

func _ready() -> void:
	if target == null:
		target = get_parent().get_node("Player")

	rotation_degrees = Vector3(-50.0, 0.0, 0.0)

func _process(_delta: float) -> void:
	if target == null:
		return

	global_position = target.global_position + follow_offset
