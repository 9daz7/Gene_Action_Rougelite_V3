extends Room3DBase


const TREASURE_UI_SCENE = preload(
	"res://Scenes/Rooms/TreasureRoom_UI.tscn"
)

var treasure_ui: TreasureRoom_UI = null

@onready var treasure_interactable: TreasureInteractable3D = (
	get_node_or_null("TreasureInteractable3D") as TreasureInteractable3D
)

@onready var run_manager: RunManager = get_node(
	"../Managers/RunManager"
)


func _ready() -> void:

	super._ready()

	if treasure_interactable == null:
		push_error("Treasure room: TreasureInteractable3D was not found.")
		return

	if not treasure_interactable.interacted.is_connected(_on_treasure_interacted):
		treasure_interactable.interacted.connect(_on_treasure_interacted)

	print("TREASURE ROOM READY: Chest signal connected")

	# Treasure rooms are complete on entry.
	complete_room()


func _on_treasure_interacted() -> void:

	print("TREASURE ROOM HANDLER REACHED")

	if is_instance_valid(treasure_ui):
		print("TREASURE UI ALREADY EXISTS")
		return

	print("RUN MANAGER VALID: ", is_instance_valid(run_manager))

	if not is_instance_valid(run_manager):
		push_error("Treasure room: RunManager not found.")
		return

	treasure_ui = TREASURE_UI_SCENE.instantiate() as TreasureRoom_UI

	if treasure_ui == null:
		push_error("Treasure room: Failed to instantiate TreasureRoom_UI.")
		return

	var main := get_tree().current_scene
	print("CURRENT SCENE: ", main.name if main != null else "NULL")

	var ui_layer := main.get_node_or_null("UI") if main != null else null
	print("UI NODE FOUND: ", ui_layer != null)

	if ui_layer == null:
		push_error("Treasure room: UI node not found under Main.")
		treasure_ui.queue_free()
		treasure_ui = null
		return

	ui_layer.add_child(treasure_ui)
	treasure_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	if not treasure_ui.treasure_finished.is_connected(_on_treasure_finished):
		treasure_ui.treasure_finished.connect(_on_treasure_finished)

	treasure_ui.open(run_manager, player, deebo)
	print("TREASURE UI OPENED")


func _on_treasure_finished(_reward) -> void:

	if is_instance_valid(treasure_ui):
		treasure_ui.queue_free()

	treasure_ui = null
	print("TREASURE REWARD SELECTED")
