extends Room3DBase
class_name EventRoom3D


# ==================================================
# Scenes
# ==================================================

const EVENT_UI_SCENE = preload(
	"res://Scenes/Rooms/EventRoom_UI.tscn"
)


# ==================================================
# References
# ==================================================

@onready var action_battle_ui: ActionBattleUI = (
	$ActionBattleUI
)

@onready var event_interactable: EventInteractable3D = (
	$EventInteractable3D
)


# ==================================================
# Managers
# ==================================================

var room_manager: RoomManager = null
var run_manager: RunManager = null


# ==================================================
# State
# ==================================================

var event_ui: EventRoom_UI = null

var previous_mouse_mode: Input.MouseMode = (
	Input.MOUSE_MODE_VISIBLE
)


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	room_manager = get_node_or_null(
		"/root/Main/Managers/RoomManager"
	) as RoomManager

	run_manager = get_node_or_null(
		"/root/Main/Managers/RunManager"
	) as RunManager

	if not is_instance_valid(room_manager):
		push_error("EventRoom3D: RoomManager is missing.")
		return

	if not is_instance_valid(run_manager):
		push_error("EventRoom3D: RunManager is missing.")
		return

	if not is_instance_valid(action_battle_ui):
		push_error("EventRoom3D: ActionBattleUI is missing.")
		return

	if not is_instance_valid(event_interactable):
		push_error("EventRoom3D: EventInteractable is missing.")
		return

	var player := room_manager.player_character
	var deebo := room_manager.deebo_character

	if not is_instance_valid(player):
		push_error("EventRoom3D: Player character is missing.")
		return

	if not is_instance_valid(deebo):
		push_error("EventRoom3D: Deebo character is missing.")
		return

	# Initialize the health bars using persistent character health.
	action_battle_ui.setup(player, deebo)

	if not event_interactable.interacted.is_connected(
		_on_event_interacted
	):
		event_interactable.interacted.connect(
			_on_event_interacted
		)

	super._ready()


# ==================================================
# Event Interaction
# ==================================================

func _on_event_interacted() -> void:

	if is_instance_valid(event_ui):
		return

	if room_completed or run_failed:
		return

	print("EVENT INTERACTION RECEIVED - OPENING UI")

	var player := room_manager.player_character

	if is_instance_valid(player) and player.has_method(
		"set_controls_enabled"
	):
		player.call("set_controls_enabled", false)

	var ui_layer := get_tree().current_scene.get_node_or_null("UI")

	if ui_layer == null:
		push_error("EventRoom3D: Main UI node is missing.")
		_restore_player_controls()
		return

	event_ui = EVENT_UI_SCENE.instantiate() as EventRoom_UI

	if event_ui == null:
		push_error("EventRoom3D: Failed to create Event UI.")
		_restore_player_controls()
		return

	ui_layer.add_child(event_ui)

	event_ui.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	if not event_ui.event_finished.is_connected(
		_on_event_finished
	):
		event_ui.event_finished.connect(
			_on_event_finished
		)

	previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	event_ui.open(run_manager)


# ==================================================
# Event Completion
# ==================================================

func _on_event_finished() -> void:

	print("EVENT FINISHED - UNLOCKING EXITS")

	if is_instance_valid(event_ui):
		event_ui.close()
		event_ui.queue_free()
		event_ui = null

	# Completing the room enables its registered exits.
	complete_room()

	_restore_player_controls()


# ==================================================
# Restore Player
# ==================================================

func _restore_player_controls() -> void:

	if is_instance_valid(room_manager):
		var player := room_manager.player_character

		if is_instance_valid(player) and player.has_method(
			"set_controls_enabled"
		):
			player.call("set_controls_enabled", true)

	Input.mouse_mode = previous_mouse_mode
