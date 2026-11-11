extends Area3D
class_name BetweenWorldLabExit3D


signal exit_requested


@export var interaction_text: String = "Enter Next World [E]"

var player_in_range: bool = false
var exit_locked: bool = false
var exit_used: bool = false

@onready var interaction_prompt: Label3D = (
	get_node_or_null("Label3D") as Label3D
)


func _ready() -> void:

	if interaction_prompt != null:
		interaction_prompt.text = interaction_text
		interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	add_to_group("between_world_lab_exit")


func _unhandled_input(event: InputEvent) -> void:

	if not event.is_action_pressed("interact") or event.is_echo():
		return

	if not player_in_range:
		return

	if exit_locked or exit_used:
		get_viewport().set_input_as_handled()
		return

	exit_used = true
	_update_prompt()

	print("BETWEEN-WORLD LAB EXIT REQUESTED")

	exit_requested.emit()

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
			player_in_range
			and not exit_locked
			and not exit_used
		)
