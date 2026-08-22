extends RoomWorld
class_name TreasureRoom


# ==================================================
# Scenes
# ==================================================

const TREASURE_UI_SCENE = preload(
	"res://Scenes/Rooms/TreasureRoom_UI.tscn"
)


# ==================================================
# Managers
# ==================================================

@onready var run_manager: RunManager = get_node(
	"../Managers/RunManager"
)


# ==================================================
# Interaction
# ==================================================

@onready var treasure_interactable: Interactable = $TreasureInteractable


# ==================================================
# State
# ==================================================

var treasure_ui: TreasureRoom_UI = null


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	super._ready()

	if treasure_interactable == null:

		push_error(
			"TreasureRoomWorld: TreasureInteractable not found."
		)

		return

	if not treasure_interactable.interacted.is_connected(
		_on_treasure_interacted
	):

		treasure_interactable.interacted.connect(
			_on_treasure_interacted
	)


# ==================================================
# Treasure
# ==================================================

func _on_treasure_interacted() -> void:

	if is_instance_valid(treasure_ui):
		return

	print("================================")
	print("TREASURE INTERACTED")
	print("================================")

	# --------------------------------------------------
	# Lock player
	# --------------------------------------------------

	if room_player != null:

		room_player.set_controls_enabled(
			false
		)

	# --------------------------------------------------
	# Open old Treasure UI
	# --------------------------------------------------

	treasure_ui = TREASURE_UI_SCENE.instantiate()

	if treasure_ui == null:

		push_error(
			"TreasureRoomWorld: Failed to instantiate TreasureRoom_UI."
		)

		if room_player != null:

			room_player.set_controls_enabled(
				true
			)

		return

	get_tree().current_scene.get_node("UI").add_child(
		treasure_ui
	)

	treasure_ui.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	if not treasure_ui.treasure_finished.is_connected(
		_on_treasure_finished
	):

		treasure_ui.treasure_finished.connect(
			_on_treasure_finished
		)

	treasure_ui.open(
		run_manager
	)


# ==================================================
# Treasure Complete
# ==================================================

func _on_treasure_finished(
	reward
) -> void:

	print(
		"TREASURE UI FINISHED:",
		reward
	)

	if is_instance_valid(treasure_ui):

		treasure_ui.queue_free()

	treasure_ui = null

	# --------------------------------------------------
	# Complete Room
	# --------------------------------------------------

	room_manager.complete_room()

	# --------------------------------------------------
	# Restore Player
	# --------------------------------------------------

	if room_player != null:

		room_player.set_controls_enabled(
			true
		)
