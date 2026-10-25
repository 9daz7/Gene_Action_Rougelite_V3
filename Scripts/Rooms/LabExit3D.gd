extends Area3D
class_name LabInteriorExit3D


@export var interaction_text: String = "Return Outside [E]"

var player_in_range: bool = false

var exit_locked: bool = false

@onready var interaction_prompt: Label3D = (
	get_node_or_null("Label3D") as Label3D
)


func _ready() -> void:

	if interaction_prompt != null:
		interaction_prompt.text = interaction_text
		interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	add_to_group("lab_interior_exit")


func _unhandled_input(event: InputEvent) -> void:

	if not event.is_action_pressed("interact") or event.is_echo():
		return

	if not player_in_range:
		return

	if exit_locked:
		print("Lab exit locked: defeat all enemies first.")
		get_viewport().set_input_as_handled()
		return

	var room_manager := get_node_or_null(
		"/root/Main/Managers/RoomManager"
	) as RoomManager

	if room_manager == null:
		push_error("LabInteriorExit3D: RoomManager not found.")
		return

	room_manager.return_from_temporary_interior()
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


func set_exit_locked(value: bool) -> void:

	exit_locked = value
	_update_prompt()


func _update_prompt() -> void:

	if interaction_prompt != null:
		interaction_prompt.visible = (
			player_in_range and not exit_locked
		)
