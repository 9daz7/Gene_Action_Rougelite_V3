extends Control
class_name HouseUI


# ==================================================
# Signals
# ==================================================

signal house_closed


# ==================================================
# Managers
# ==================================================

@onready var save_manager = get_node(
	"../../Managers/SaveManager"
)

@onready var run_manager: RunManager = get_node(
	"../../Managers/RunManager"
)


# ==================================================
# UI
# ==================================================

@onready var potion_storage_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/PotionStorageButton
)

@onready var save_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/SaveButton
)

@onready var close_button: Button = (
	$CenterContainer/PanelContainer/VBoxContainer/CloseButton
)


@onready var potion_storage_ui: PotionStorageUI = get_node(
	"../PotionStorageUI"
)


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	if not potion_storage_button.pressed.is_connected(
		_open_potion_storage
	):
		potion_storage_button.pressed.connect(
			_open_potion_storage
	)

	if not save_button.pressed.is_connected(
		_save_game
	):
		save_button.pressed.connect(
			_save_game
	)

	if not close_button.pressed.is_connected(
		_close
	):
		close_button.pressed.connect(
			_close
	)

	hide()


# ==================================================
# Open
# ==================================================

func open() -> void:

	show()


# ==================================================
# Potion Storage
# ==================================================

func _open_potion_storage() -> void:

	if potion_storage_ui == null:

		push_error(
			"HouseUI: PotionStorageUI not found."
		)

		return

	hide()

	potion_storage_ui.open()


# ==================================================
# Save Game
# ==================================================

func _save_game() -> void:

	if save_manager == null:

		push_error(
			"HouseUI: SaveManager not found."
		)

		return

	if run_manager == null:

		push_error(
			"HouseUI: RunManager not found."
		)

		return

	print("================================")
	print("HOUSE: SAVING GAME")
	print("================================")

	save_manager.save_game(
		PermanentProgressionManager,
		run_manager
	)

	print("Game saved.")

# ==================================================
# Close
# ==================================================

func _close() -> void:

	hide()

	house_closed.emit()
