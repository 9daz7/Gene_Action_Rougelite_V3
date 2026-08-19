extends Area2D
class_name BattleTrigger


# ==================================================
# Signals
# ==================================================

signal player_entered


# ==================================================
# State
# ==================================================

var triggered: bool = false


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("BattleTrigger ready")

	if not body_entered.is_connected(
		_on_body_entered
	):

		body_entered.connect(
			_on_body_entered
	)


# ==================================================
# Detection
# ==================================================

func _on_body_entered(body: Node2D) -> void:

	if triggered:
		return

	if not body is RoomPlayer:
		return

	triggered = true

	print("================================")
	print("PLAYER ENTERED BATTLE TRIGGER")
	print("================================")

	player_entered.emit()
