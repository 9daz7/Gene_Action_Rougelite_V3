extends Area3D
class_name LabWorkstation3D


const LAB_UI_SCENE: PackedScene = preload(
	"res://Scenes/Rooms/AbandonedLab_UI.tscn"
)

@export var interaction_text: String = "Workstation [E]"

@export var lab_data: LabResource

var player_in_range: bool = false
var lab_ui: AbandonedLab_UI = null

@onready var interaction_prompt: Label3D = (
	get_node_or_null("Label3D") as Label3D
)


func _ready() -> void:

	if interaction_prompt != null:
		interaction_prompt.text = interaction_text
		interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:

	if not event.is_action_pressed("interact") or event.is_echo():
		return

	if not player_in_range:
		return

	if is_instance_valid(lab_ui):
		return

	var room_manager := get_node_or_null(
		"/root/Main/Managers/RoomManager"
	) as RoomManager

	if room_manager == null:
		push_error("LabWorkstation3D: RoomManager not found.")
		return

	var current_room: RoomResource = room_manager.current_room

	if current_room == null:
		push_error("LabWorkstation3D: Current room is missing.")
		return

	lab_ui = LAB_UI_SCENE.instantiate() as AbandonedLab_UI

	if lab_ui == null:
		push_error("LabWorkstation3D: Failed to create lab UI.")
		return

	var ui_root := get_tree().current_scene.get_node_or_null("UI")

	if ui_root == null:
		lab_ui.free()
		lab_ui = null
		push_error("LabWorkstation3D: Main UI node not found.")
		return

	ui_root.add_child(lab_ui)
	lab_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	if not lab_ui.lab_finished.is_connected(_on_lab_finished):
		lab_ui.lab_finished.connect(_on_lab_finished)

	# Reuse the existing run room's lab data and state.
	if lab_data == null:
		lab_ui.queue_free()
		lab_ui = null
		push_error(
			"LabWorkstation3D: Assign a LabResource in the Inspector."
		)
		return

	lab_ui.open(lab_data, current_room)
	get_viewport().set_input_as_handled()


func _on_lab_finished() -> void:

	if is_instance_valid(lab_ui):
		lab_ui.close()
		lab_ui.queue_free()

	lab_ui = null


func _on_body_entered(body: Node3D) -> void:

	if not body.is_in_group("player"):
		return

	player_in_range = true
	_update_prompt()


func _on_body_exited(body: Node3D) -> void:

	if not body.is_in_group("player"):
		return

	player_in_range = false
	_update_prompt()


func _update_prompt() -> void:

	if interaction_prompt != null:
		interaction_prompt.visible = player_in_range


func _exit_tree() -> void:

	if is_instance_valid(lab_ui):
		lab_ui.close()
		lab_ui.queue_free()
