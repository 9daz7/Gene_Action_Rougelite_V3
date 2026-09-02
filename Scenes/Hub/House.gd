extends Node2D
class_name House


# ==================================================
# Interactions
# ==================================================

@onready var interactable: Interactable = $Interactable


# ==================================================
# UI
# ==================================================

@onready var potion_storage_ui: PotionStorageUI = get_node(
	"../../../UI/PotionStorageUI"
)


func _ready() -> void:

	if interactable == null:
		push_error("House: Interactable not found.")
		return

	if not interactable.interacted.is_connected(
		_open_potion_storage
	):
		interactable.interacted.connect(
			_open_potion_storage
	)


func _open_potion_storage() -> void:

	if potion_storage_ui == null:
		push_error(
			"House: PotionStorageUI not found."
		)
		return

	potion_storage_ui.open()
