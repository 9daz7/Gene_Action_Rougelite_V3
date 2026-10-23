extends Area3D
class_name EventInteractable3D


signal interacted

@export var interaction_text: String = "[E] Interact"

var player_in_range: bool = false
var player: Node3D = null


func _ready() -> void:

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:

	if not is_instance_valid(player):
		return

	if not player_in_range:
		return

	if event.is_action_pressed("interact") and not event.is_echo():
		print("EVENT INTERACTED")
		interacted.emit()
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node3D) -> void:

	if body.name != "Player":
		return

	player = body
	player_in_range = true
	print("PLAYER ENTERED EVENT RANGE")


func _on_body_exited(body: Node3D) -> void:

	if body != player:
		return

	player_in_range = false
	player = null
	print("PLAYER LEFT EVENT RANGE")
