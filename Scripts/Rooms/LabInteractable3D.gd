extends Area3D
class_name LabEntranceInteractable3D

const LAB_INTERIOR_SCENE: PackedScene = preload(
    "res://Scenes/Rooms/LabInterior3D.tscn"
)

@export var interaction_text: String = "[E] Enter Abandoned Lab"

var player_in_range: bool = false

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

	var room_manager := get_node_or_null(
		"/root/Main/Managers/RoomManager"
	) as RoomManager

	if room_manager == null:
		push_error("LabEntrance: RoomManager not found.")
		return

	room_manager.enter_temporary_interior(LAB_INTERIOR_SCENE)
	get_viewport().set_input_as_handled()


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
