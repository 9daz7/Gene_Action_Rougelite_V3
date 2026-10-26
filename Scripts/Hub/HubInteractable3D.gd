extends Area3D
class_name HubInteractable3D

signal interacted

@export var interaction_name: String = "Interact"

var player_in_range: HubPlayer3D = null


func _ready() -> void:

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:

	if not body is HubPlayer3D:
		return

	player_in_range = body as HubPlayer3D
	player_in_range.set_nearby_interactable(self)


func _on_body_exited(body: Node3D) -> void:

	if body != player_in_range:
		return

	if player_in_range.nearby_interactable == self:
		player_in_range.set_nearby_interactable(null)

	player_in_range = null


func interact() -> void:

	if not is_instance_valid(player_in_range):
		return

	print("HUB INTERACTION: ", interaction_name)
	interacted.emit()
