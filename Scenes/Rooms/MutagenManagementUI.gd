extends Control
class_name MutagenManagementUI


# ==================================================
# Signals
# ==================================================

signal management_finished


# ==================================================
# Managers
# ==================================================

@onready var run_mutagen_manager: RunMutagenManager = get_node(
	"../../Managers/RunMutagenManager"
)


# ==================================================
# UI
# ==================================================

@onready var title_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/TitleLabel
)

@onready var equipped_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/EquippedLabel
)

@onready var equipped_grid: GridContainer = (
	$CenterContainer/PanelContainer/VBoxContainer/EquippedGrid
)

@onready var reserve_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/ReserveLabel
)

@onready var reserve_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/ReserveButton
)

@onready var selected_label: Label = (
	$CenterContainer/PanelContainer/VBoxContainer/SelectedLabel
)

@onready var remove_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/ActionContainer/RemoveButton
)

@onready var swap_reserve_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/ActionContainer/SwapReserveButton
)

@onready var done_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/DoneButton
)


# ==================================================
# State
# ==================================================

var selected_slot: int = -1

var slot_buttons: Array[Button] = []


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	_create_slot_connections()

	remove_button.disabled = true
	swap_reserve_button.disabled = true


# ==================================================
# Open
# ==================================================

func open() -> void:

	selected_slot = -1

	show()

	_refresh_ui()


# ==================================================
# Create Equipped Slot Connections
# ==================================================

func _create_slot_connections() -> void:

	slot_buttons.clear()

	for i in range(6):

		var button: Button = equipped_grid.get_child(i)

		slot_buttons.append(button)

		button.pressed.connect(
			_on_equipped_slot_pressed.bind(i)
		)

	reserve_button.pressed.connect(
		_on_reserve_pressed
	)

	remove_button.pressed.connect(
		_on_remove_pressed
	)

	swap_reserve_button.pressed.connect(
		_on_swap_reserve_pressed
	)

	done_button.pressed.connect(
		_on_done_pressed
	)


# ==================================================
# Refresh
# ==================================================

func _refresh_ui() -> void:

	if run_mutagen_manager == null:
		return

	var equipped := (
		run_mutagen_manager.get_equipped_mutagens()
	)

	# ==================================================
	# Equipped
	# ==================================================

	for i in range(6):

		var button: Button = slot_buttons[i]

		if i < equipped.size():

			var mutagen: MutagenResource = (
				equipped[i]
			)

			if mutagen != null:

				button.text = mutagen.mutagen_name

			else:

				button.text = "Empty"

		else:

			button.text = "Empty"

		button.disabled = false

	# ==================================================
	# Reserve
	# ==================================================

	var reserve := (
		run_mutagen_manager.reserve_mutagen
	)

	if reserve != null:

		reserve_button.text = (
			"Reserve: "
			+ reserve.mutagen_name
		)

	else:

		reserve_button.text = "Reserve: Empty"

	# ==================================================
	# Selection
	# ==================================================

	if selected_slot >= 0:

		var selected_mutagen: MutagenResource = null

		if selected_slot < equipped.size():

			selected_mutagen = (
				equipped[selected_slot]
			)

		if selected_mutagen != null:

			selected_label.text = (
				"Selected: "
				+ selected_mutagen.mutagen_name
			)

		else:

			selected_label.text = (
				"Selected: Empty Slot"
			)

	else:

		selected_label.text = (
			"Selected: None"
		)

	# ==================================================
	# Action Buttons
	# ==================================================

	remove_button.disabled = (
		selected_slot < 0
		or
		selected_slot >= equipped.size()
	)

	swap_reserve_button.disabled = (
		selected_slot < 0
		or
		not run_mutagen_manager.has_reserve()
	)

	# ==================================================
	# Highlight
	# ==================================================

	for i in range(slot_buttons.size()):

		slot_buttons[i].button_pressed = (
			i == selected_slot
		)


# ==================================================
# Equipped Slot Selected
# ==================================================

func _on_equipped_slot_pressed(
	slot_index: int
) -> void:

	selected_slot = slot_index

	print(
		"Selected Mutagen slot:",
		slot_index
	)

	_refresh_ui()


# ==================================================
# Reserve Selected
# ==================================================

func _on_reserve_pressed() -> void:

	if not run_mutagen_manager.has_reserve():

		print(
			"No reserve Mutagen."
		)

		return

	print(
		"Reserve Mutagen selected."
	)

	selected_label.text = (
		"Reserve selected"
	)


# ==================================================
# Remove
# ==================================================

func _on_remove_pressed() -> void:

	if selected_slot < 0:
		return

	var equipped := (
		run_mutagen_manager.get_equipped_mutagens()
	)

	if selected_slot >= equipped.size():
		return

	var mutagen: MutagenResource = (
		equipped[selected_slot]
	)

	if mutagen == null:
		return

	if run_mutagen_manager.remove_mutagen(
		mutagen
	):

		print(
			"Lab removed Mutagen:",
			mutagen.mutagen_name
		)

		selected_slot = -1

		_refresh_ui()


# ==================================================
# Swap With Reserve
# ==================================================

func _on_swap_reserve_pressed() -> void:

	if selected_slot < 0:
		return

	if not run_mutagen_manager.has_reserve():
		return


	if run_mutagen_manager.equip_reserve_mutagen(
		selected_slot
	):

		print(
			"Lab swapped selected slot with reserve."
		)

		_refresh_ui()


# ==================================================
# Done
# ==================================================

func _on_done_pressed() -> void:

	print(
		"Mutagen management finished."
	)

	hide()

	management_finished.emit()
