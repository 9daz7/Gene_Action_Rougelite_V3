extends Area3D
class_name RestInteractable3D

signal interacted

@export var interaction_text: String = "[E] To Rest"

var player_in_range: bool = false
var player: Node3D = null


func _ready() -> void:

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:

	if not player_in_range:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		print("KEY PRESSED IN REST RANGE: ", event.as_text())

	if event.is_action_pressed("interact"):
		print("INTERACT ACTION RECEIVED")
		interacted.emit()
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node3D) -> void:

	print("REST ZONE DETECTED BODY: ", body.name)

	if body.name != "Player":
		print("IGNORED: body name is not Player")
		return

	player = body
	player_in_range = true
	print("PLAYER ENTERED REST RANGE")


func _on_body_exited(body: Node3D) -> void:

	print("REST ZONE BODY EXITED: ", body.name)

	if body != player:
		return

	player_in_range = false
	player = null
	print("PLAYER LEFT REST RANGE")
