extends Area3D
class_name MerchantInteractable3D


signal interacted

@export var interaction_text: String = "[E] To Trade"

var player_in_range: bool = false
var player: Node3D = null


func _ready() -> void:

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:

	if not player_in_range:
		return

	if event.is_action_pressed("interact"):
		interacted.emit()
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node3D) -> void:

	if body.name != "Player":
		return

	player = body
	player_in_range = true


func _on_body_exited(body: Node3D) -> void:

	if body != player:
		return

	player_in_range = false
	player = null
