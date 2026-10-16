extends Area3D
class_name RoomExit3D


# ==================================================
# Signals
# ==================================================

signal exit_entered(exit_id: int)


# ==================================================
# Exit Configuration
# ==================================================

@export var exit_id: int = 0

var enabled: bool = false
var player_in_range: bool = false


@onready var interaction_prompt: Label3D = $InteractionPrompt


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# ==================================================
# Interaction
# ==================================================

func _unhandled_input(event: InputEvent) -> void:

	if not enabled or not player_in_range:
		return

	#print("EXIT RECEIVED INPUT: ", event.as_text())

	if not event.is_action_pressed("interact"):
		return

	enabled = false
	_update_interaction_prompt()

	print("================================")
	print("ROOM EXIT INTERACTED")
	print("Exit ID: ", exit_id)
	print("================================")

	exit_entered.emit(exit_id)
	get_viewport().set_input_as_handled()


# ==================================================
# Controls
# ==================================================

func set_enabled(value: bool) -> void:

	enabled = value
	print("RoomExit3D ", exit_id, " enabled: ", enabled)

	_update_interaction_prompt()


# ==================================================
# Detection
# ==================================================

func _on_body_entered(body: Node3D) -> void:

	print("EXIT AREA DETECTED BODY: ", body.name)
	#print(
		#"EXIT BODY ENTERED: ",
		#body.name,
		#" | In player group: ",
		#body.is_in_group("player")
	#)

	if not body.is_in_group("player"):
		return

	player_in_range = true
	print("PLAYER IN EXIT RANGE")

	_update_interaction_prompt()


func _on_body_exited(body: Node3D) -> void:

	if not body.is_in_group("player"):
		return

	player_in_range = false
	print("PLAYER LEFT EXIT RANGE")

	_update_interaction_prompt()


func _update_interaction_prompt() -> void:

	interaction_prompt.visible = (
		enabled
		and player_in_range
	)
