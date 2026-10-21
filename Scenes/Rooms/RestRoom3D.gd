extends Room3DBase


const REST_UI_SCENE = preload(
	"res://Scenes/Rooms/RestRoom_UI.tscn"
)


@onready var rest_interactable: RestInteractable3D = (
	$RestInteractable
)

@onready var action_battle_ui: ActionBattleUI = $ActionBattleUI

var rest_ui: Control = null
var run_manager: RunManager = null
var room_manager: RoomManager = null

var previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE


func _ready() -> void:

	run_manager = get_node_or_null(
		"/root/Main/Managers/RunManager"
	) as RunManager

	room_manager = get_node_or_null(
		"/root/Main/Managers/RoomManager"
	) as RoomManager

	if not is_instance_valid(rest_interactable):
		push_error("RestRoom3D: RestInteractable is missing.")
		return

	if not rest_interactable.interacted.is_connected(
		_on_rest_interacted
	):
		rest_interactable.interacted.connect(
			_on_rest_interacted
		)

	if not is_instance_valid(action_battle_ui):
		push_error("RestRoom3D: ActionBattleUI is missing.")
		return

	if not is_instance_valid(room_manager.player_character):
		push_error("RestRoom3D: Player character is missing.")
		return

	if not is_instance_valid(room_manager.deebo_character):
		push_error("RestRoom3D: Deebo character is missing.")
		return

	action_battle_ui.setup(
		room_manager.player_character,
		room_manager.deebo_character
	)

	super._ready()
	complete_room()


func _on_rest_interacted() -> void:

	if is_instance_valid(rest_ui):
		return

	if run_manager == null:
		push_error("RestRoom3D: RunManager is missing.")
		return

	if room_manager == null:
		push_error("RestRoom3D: RoomManager is missing.")
		return

	var player := room_manager.player_character

	if is_instance_valid(player) and player.has_method("set_controls_enabled"):
		player.call("set_controls_enabled", false)

	rest_ui = REST_UI_SCENE.instantiate() as Control

	if rest_ui == null:
		push_error("RestRoom3D: Failed to create Rest Room UI.")
		return

	var ui_layer := get_tree().current_scene.get_node_or_null("UI")

	if ui_layer == null:
		push_error("RestRoom3D: Main UI node is missing.")
		rest_ui.queue_free()
		rest_ui = null
		return

	ui_layer.add_child(rest_ui)

	#rest_ui.set_anchors_and_offsets_preset(
		#Control.PRESET_FULL_RECT
	#)

	rest_ui.rest_finished.connect(_on_rest_finished)

	previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var deebo := room_manager.deebo_character

	if not is_instance_valid(player) or not is_instance_valid(deebo):
		push_error("RestRoom3D: Player or Deebo reference is missing.")
		rest_ui.queue_free()
		rest_ui = null
		return

	rest_ui.open(run_manager, player, deebo)


func _on_rest_finished() -> void:

	if is_instance_valid(rest_ui):
		rest_ui.queue_free()
		rest_ui = null

	if is_instance_valid(room_manager):
		var player := room_manager.player_character

		if is_instance_valid(player) and player.has_method("set_controls_enabled"):
			player.call("set_controls_enabled", true)

	Input.mouse_mode = previous_mouse_mode
