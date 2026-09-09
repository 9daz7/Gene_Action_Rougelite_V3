extends Control
class_name PotionStorageUI


# ==================================================
# Managers
# ==================================================

@onready var potion_storage: PotionStorageManager = (
	get_node("../../Managers/PotionStorageManager")
)

@onready var run_manager: RunManager = (
	get_node("../../Managers/RunManager")
)


# ==================================================
# UI
# ==================================================

@onready var storage_list: VBoxContainer = (
	$CenterContainer/PanelContainer/VBoxContainer/Content/StoragePanel/StorageList
)

@onready var run_slots: HBoxContainer = (
	$CenterContainer/PanelContainer/VBoxContainer/Content/RunPanel/RunSlots
)

@onready var close_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/CloseButton
)

@onready var save_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/SaveButton
)


# ==================================================
# State
# ==================================================

var selected_potion: PotionResource = null


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	close_button.pressed.connect(
		_close
	)

	save_button.pressed.connect(
		_save_game
	)

	for i in range(
		run_slots.get_child_count()
	):

		var slot := run_slots.get_child(i) as Button

		if slot == null:
			continue

		slot.pressed.connect(
			func() -> void:
				_remove_from_run_slot(
					slot.get_meta("slot_index")
				)
		)

		slot.set_meta(
			"slot_index",
			i
		)

	hide()


# ==================================================
# Open
# ==================================================

func open() -> void:

	selected_potion = null

	_refresh()

	show()


# ==================================================
# Refresh
# ==================================================

func _refresh() -> void:

	_refresh_storage()
	_refresh_run_slots()


# ==================================================
# Storage
# ==================================================

func _refresh_storage() -> void:

	for child in storage_list.get_children():

		child.queue_free()

	if potion_storage == null:
		return

	for potion in potion_storage.stored_potions.keys():

		if potion == null:
			continue

		var amount: int = (
			potion_storage.get_potion_count(
				potion
			)
		)

		if amount <= 0:
			continue

		var button := Button.new()

		button.text = (
			potion.potion_name
			+ " ×"
			+ str(amount)
		)

		button.custom_minimum_size = Vector2(
			260,
			50
		)

		button.pressed.connect(
			func() -> void:
				_add_to_run(potion)
		)

		storage_list.add_child(
			button
		)


# ==================================================
# Run Slots
# ==================================================

func _remove_from_run_slot(
	slot_index: int
) -> void:

	var removed := (
		run_manager.remove_potion_from_run(
			slot_index
		)
	)

	if removed == null:
		return

	potion_storage.add_potion(
		removed
	)

	_refresh()


func _refresh_run_slots() -> void:

	var potions := run_manager.get_run_potions()

	for i in range(
		run_slots.get_child_count()
	):

		var slot := run_slots.get_child(i) as Button

		if slot == null:
			continue

		slot.text = "Empty"

		if i < potions.size():

			var potion: PotionResource = potions[i]

			if potion != null:

				slot.text = potion.potion_name

				slot.set_meta(
					"slot_index",
					i
				)


# ==================================================
# Add To Run
# ==================================================

func _add_to_run(
	potion: PotionResource
) -> void:

	if potion == null:
		return

	if potion_storage == null:
		return

	if run_manager == null:
		return

	if not potion_storage.move_potion_to_run(
		potion,
		run_manager
	):

		print(
			"Could not move potion into run."
		)

		return

	_refresh()


# ==================================================
# Remove From Run
# ==================================================

func _remove_from_run(
	potion: PotionResource
) -> void:

	if potion == null:
		return

	if potion_storage == null:
		return

	if run_manager == null:
		return

	if not run_manager.has_run_potion(
		potion
	):

		return

	var removed := run_manager.remove_potion_from_run(
		run_manager.get_run_potions().find(potion)
	)

	if removed == null:
		return

	potion_storage.return_potion_from_run(
		removed,
	)

	_refresh()


# ==================================================
# Save Game
# ==================================================

func _save_game() -> void:

	print("================================")
	print("MANUAL SAVE REQUESTED")
	print("================================")

	var save_manager = get_node_or_null(
		"../../Managers/SaveManager"
	)

	if save_manager == null:

		push_error(
			"PotionStorageUI: SaveManager not found."
		)

		return

	if run_manager == null:

		push_error(
			"PotionStorageUI: RunManager not found."
		)

		return

	save_manager.save_game(
		PermanentProgressionManager,
		run_manager
	)

	print("Manual save complete.")


# ==================================================
# Close
# ==================================================

func _close() -> void:

	hide()
