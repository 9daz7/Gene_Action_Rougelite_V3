extends RoomWorld
class_name EventRoom


# ==================================================
# Scenes
# ==================================================

const EVENT_UI_SCENE = preload(
	"res://Scenes/Rooms/EventRoom_UI.tscn"
)


# ==================================================
# Managers
# ==================================================

@onready var run_manager: RunManager = get_node(
	"../Managers/RunManager"
)

@onready var event_interactable: Interactable = $EventInteractable


# ==================================================
# State
# ==================================================

var event_ui: Control = null


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	super._ready()

	if event_interactable == null:

		push_error(
			"EventRoom: EventInteractable not found."
		)

		return

	if not event_interactable.interacted.is_connected(
		_on_event_interacted
	):

		event_interactable.interacted.connect(
			_on_event_interacted
	)


# ==================================================
# Event
# ==================================================

func _on_event_interacted() -> void:

	if is_instance_valid(event_ui):

		return

	print("================================")
	print("EVENT INTERACTED")
	print("================================")

	# --------------------------------------------------
	# Lock Player
	# --------------------------------------------------

	if room_player != null:

		room_player.set_controls_enabled(
			false
		)

	# --------------------------------------------------
	# Open Event UI
	# --------------------------------------------------

	event_ui = EVENT_UI_SCENE.instantiate()

	if event_ui == null:

		push_error(
			"EventRoom: Failed to instantiate EventRoom_UI."
		)

		if room_player != null:

			room_player.set_controls_enabled(
				true
			)

		return

	get_tree().current_scene.get_node("UI").add_child(
		event_ui
	)

	event_ui.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	event_ui.event_finished.connect(
		_on_event_finished
	)

	print(
		"Event UI signal connected:",
		event_ui.event_finished.is_connected(
			_on_event_finished
		)
	)

	event_ui.open(
		run_manager
	)


# ==================================================
# Event Complete
# ==================================================

func _on_event_finished() -> void:

	print("================================")
	print("EVENT ROOM: FINISHED SIGNAL RECEIVED")
	print("================================")

	if is_instance_valid(event_ui):

		event_ui.close()
		event_ui.queue_free()

		event_ui = null

		print(
			"Event UI closed and freed"
		)

	# --------------------------------------------------
	# Restore Player
	# --------------------------------------------------

	room_manager.complete_room()

	if room_player != null:

		room_player.set_controls_enabled(
			true
		)

	print(
		"EVENT ROOM: PLAYER CONTROLS RESTORED"
	)
