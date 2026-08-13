extends CharacterBody2D
class_name HubPlayer


# ==================================================
# Movement
# ==================================================

@export var move_speed: float = 200.0


# ==================================================
# Interaction
# ==================================================

var nearby_interactable: Interactable = null


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("HubPlayer ready")

	pass


# ==================================================
# Physics
# ==================================================


func _physics_process(_delta: float) -> void:

	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * move_speed

	move_and_slide()

	_handle_interaction()


# ==================================================
# Interaction
# ==================================================

func _handle_interaction() -> void:

	if not Input.is_action_just_pressed("interact"):
		return

	if nearby_interactable == null:
		return

	nearby_interactable.interact()


# ==================================================
# Interaction Detection
# ==================================================

func set_nearby_interactable(
	interactable: Interactable
) -> void:

	nearby_interactable = interactable
