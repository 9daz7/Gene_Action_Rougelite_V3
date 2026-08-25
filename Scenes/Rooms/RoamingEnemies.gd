extends Node2D
class_name RoamingEnemy


# ==================================================
# Enemy Data
# ==================================================

@export var enemy_data: EnemyResource


# ==================================================
# Signals
# ==================================================

signal encounter_requested(enemy)


# ==================================================
# State
# ==================================================

var encountered: bool = false


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	var detection_area := get_node_or_null(
		"DetectionArea2D"
	)

	if detection_area == null:

		push_error(
			"RoamingEnemy: DetectionArea2D not found."
		)

		return

	if not detection_area.body_entered.is_connected(
		_on_detection_body_entered
	):

		detection_area.body_entered.connect(
			_on_detection_body_entered
	)


# ==================================================
# Detection
# ==================================================

func _on_detection_body_entered(
	body: Node
) -> void:

	if encountered:
		return

	if not body is RoomPlayer:
		return

	encountered = true

	print("================================")
	print("ROAMING ENEMY DETECTED PLAYER")
	print("================================")

	encounter_requested.emit(self)
