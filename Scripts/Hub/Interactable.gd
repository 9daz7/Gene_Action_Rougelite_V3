extends Area2D
class_name Interactable


# ==================================================
# Signals
# ==================================================

signal interacted
signal player_entered
signal player_exited

# ==================================================
# Settings
# ==================================================

@export var interaction_text: String = "E Interact"

# ==================================================
# State
# ==================================================

var player_in_range: bool = false

# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# ==================================================
# Interaction
# ==================================================

func interact() -> void:

	if not player_in_range:
		return

	print("INTERACTED WITH:", name)

	interacted.emit()

# ==================================================
# Interaction Range
# ==================================================

func _on_body_entered(body: Node2D) -> void:

	if not body.has_method(
		"set_nearby_interactable"
	):

		return

	player_in_range = true

	body.set_nearby_interactable(self)

	print(
		"Player entered interaction range:",
		name
	)

	player_entered.emit()


func _on_body_exited(body: Node2D) -> void:

	if not body.has_method(
		"set_nearby_interactable"
	):

		return

	player_in_range = false

	if body.nearby_interactable == self:

		body.set_nearby_interactable(null)

	print(
		"Player left interaction range:",
		name
	)

	player_exited.emit()
