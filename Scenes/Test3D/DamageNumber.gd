extends Node3D

@export var float_height: float = 0.02
@export var lifetime: float = 0.5

@onready var label: Label3D = $Label3D


func _ready() -> void:

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		self,
		"position:y",
		position.y + 0.002,
		lifetime
	).set_trans(Tween.TRANS_LINEAR)

	#var start_position := position
	#var end_position := start_position + Vector3(0.0, 0.002, 0.0)

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		lifetime
	).set_ease(Tween.EASE_IN)

	tween.chain().tween_callback(queue_free)


func set_damage(amount: float) -> void:

	label.text = str(roundi(amount))
