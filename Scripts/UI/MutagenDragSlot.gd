extends Button
class_name MutagenDragSlot


var slot_type: String = ""
var slot_index: int = -1
var mutagen: MutagenResource = null


func set_mutagen(
	new_mutagen: MutagenResource
) -> void:

	mutagen = new_mutagen

	if mutagen == null:

		text = "Empty"

	else:

		text = mutagen.mutagen_name

func _get_drag_data(
	at_position: Vector2
):

	if mutagen == null:
		return null

	var preview := Label.new()

	preview.text = mutagen.mutagen_name

	set_drag_preview(preview)

	return {
		"mutagen": mutagen,
		"source_type": slot_type,
		"source_index": slot_index
	}


func _can_drop_data(
	_at_position: Vector2,
	data
) -> bool:

	if not data is Dictionary:
		return false

	if not data.has("mutagen"):
		return false

	var dragged_mutagen = data["mutagen"]

	if dragged_mutagen == null:
		return false

	return true


func _drop_data(
	_at_position: Vector2,
	data
) -> void:

	var manager_ui := get_parent().get_parent()

	while manager_ui != null:

		if manager_ui is MutagenManagementUI:

			manager_ui.handle_mutagen_drop(
				data,
				slot_type,
				slot_index
			)

			return

		manager_ui = manager_ui.get_parent()
