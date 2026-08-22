extends RoomWorld
class_name RestRoom


# ==================================================
# Scenes
# ==================================================

const REST_UI_SCENE = preload(
	"res://Scenes/Rooms/RestRoom_UI.tscn"
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

@onready var rest_interactable: Interactable = $RestInteractable


# ==================================================
# State
# ==================================================

var rest_ui: RestRoom_UI = null


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	super._ready()

	if not rest_interactable.interacted.is_connected(
		_on_rest_interacted
	):

		rest_interactable.interacted.connect(
			_on_rest_interacted
	)


# ==================================================
# Rest
# ==================================================

func _on_rest_interacted() -> void:

	if is_instance_valid(rest_ui):
		return

	if room_player != null:

		room_player.set_controls_enabled(
			false
		)

	rest_ui = REST_UI_SCENE.instantiate()

	get_tree().current_scene.get_node("UI").add_child(
		rest_ui
	)

	rest_ui.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	if not rest_ui.rest_finished.is_connected(
		_on_rest_finished
	):

		rest_ui.rest_finished.connect(
			_on_rest_finished
	)

	rest_ui.open(
		run_manager
	)


# ==================================================
# Rest Complete
# ==================================================

func _on_rest_finished() -> void:

	print("REST ROOM COMPLETE")

	if is_instance_valid(rest_ui):

		rest_ui.queue_free()

		rest_ui = null

	room_manager.complete_room()

	if room_player != null:

		room_player.set_controls_enabled(
			true
		)
