extends Node2D
class_name Interactable


# ==================================================
# Signals
# ==================================================

signal interacted

# ==================================================
# Settings
# ==================================================

@export var interaction_text: String = "Interact"

# ==================================================
# State
# ==================================================

var player_in_range: bool = false

# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	if has_node("InteractionArea"):
		var area := $InteractionArea as Area2D

		area.body_entered.connect(
			_on_body_entered
		)

		area.body_exited.connect(
			_on_body_exited
		)

# ==================================================
# Input
# ==================================================

func _unhandled_input(event: InputEvent) -> void:

	if not player_in_range:
		return

	if event.is_action_pressed("interact"):

		print(
			"INTERACTED WITH:",
			name
		)

		interacted.emit()

# ==================================================
# Interaction Range
# ==================================================

func _on_body_entered(body: Node) -> void:

	if not body is CharacterBody2D:
		return

	player_in_range = true

	print(
		"Interaction available:",
		name
	)


func _on_body_exited(body: Node) -> void:

	if not body is CharacterBody2D:
		return

	player_in_range = false

	print(
		"Interaction unavailable:",
		name
	)
