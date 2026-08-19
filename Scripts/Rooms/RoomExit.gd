extends Interactable
class_name RoomExit


# ==================================================
# Signals
# ==================================================

signal exit_entered(exit_id: int)


# ==================================================
# Exit Information
# ==================================================

@export var exit_id: int = 0


# ==================================================
# State
# ==================================================

var enabled: bool = false


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	super._ready()

	interaction_text = "E  Interact"


# ==================================================
# Interaction
# ==================================================

func interact() -> void:

	if not enabled:
		return

	if not player_in_range:
		return

	print("================================")
	print("ROOM EXIT INTERACTED")
	print("Exit ID:", exit_id)
	print("================================")

	exit_entered.emit(
		exit_id
	)


# ==================================================
# Controls
# ==================================================

func set_enabled(
	value: bool
) -> void:

	enabled = value

	print(
		"RoomExit",
		exit_id,
		"enabled:",
		enabled
	)
