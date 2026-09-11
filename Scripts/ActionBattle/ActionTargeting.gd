extends Node
class_name ActionTargeting


# ==================================================
# State
# ==================================================

var selected_target: AnimalBase = null


@onready var target_marker: Polygon2D = (
	get_parent().get_node("TargetMarker")
)


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("ActionTargeting ready")


# ==================================================
# Input
# ==================================================

func _unhandled_input(event: InputEvent) -> void:

	if not event is InputEventMouseButton:
		return

	if not event.pressed:
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	_select_target_at_mouse(event.position)


# ==================================================
# Target Selection
# ==================================================

func _select_target_at_mouse(mouse_position: Vector2) -> void:

	var parent_scene = get_parent()

	if parent_scene == null:
		return

	var enemies = parent_scene.get_node_or_null("Enemies")

	if enemies == null:
		return

	for child in enemies.get_children():

		if not child is AnimalBase:
			continue

		var enemy := child as AnimalBase

		if not enemy.is_alive():
			continue

		var distance := (
			enemy.global_position
			.distance_to(mouse_position)
		)

		if distance <= 100.0:

			selected_target = enemy

			target_marker.global_position = (
				enemy.global_position
			)

			target_marker.visible = true

			print(
				"TARGET SELECTED: ",
				enemy.name
			)

			return

	# --------------------------------------------------
	# Nothing Selected
	# --------------------------------------------------

	selected_target = null

	target_marker.visible = false

	print("TARGET DESELECTED")


# ==================================================
# Public Access
# ==================================================

func get_selected_target() -> AnimalBase:

	return selected_target


func _process(_delta: float) -> void:

	if selected_target == null:
		return

	if not is_instance_valid(selected_target):
		selected_target = null
		target_marker.visible = false
		return

	if not selected_target.is_alive():
		selected_target = null
		target_marker.visible = false
		return

	target_marker.global_position = (
		selected_target.global_position
	)
