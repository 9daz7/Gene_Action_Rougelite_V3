extends Area3D
class_name TreasureInteractable3D


signal interacted

@export var interaction_text: String = "[E] Open Chest"

var player_in_range: bool = false
var opened: bool = false


@onready var interaction_prompt: Label3D = (
	get_node_or_null("InteractionPrompt") as Label3D
)


func _ready() -> void:

	if interaction_prompt != null:
		interaction_prompt.text = interaction_text
		interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:

	if opened or not player_in_range:
		return

	if not event.is_action_pressed("interact"):
		return

	print("TREASURE CHEST INTERACTED")

	opened = true
	_update_prompt()

	interacted.emit()
	get_viewport().set_input_as_handled()


func _on_body_entered(body: Node3D) -> void:

	if not body.is_in_group("player"):
		return

	player_in_range = true
	_update_prompt()
	print("PLAYER ENTERED TREASURE RANGE")


func _on_body_exited(body: Node3D) -> void:

	if not body.is_in_group("player"):
		return

	player_in_range = false
	_update_prompt()
	print("PLAYER LEFT TREASURE RANGE")


func _update_prompt() -> void:

	if interaction_prompt != null:
		interaction_prompt.visible = (
			player_in_range and not opened
		)
