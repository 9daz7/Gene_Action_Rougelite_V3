extends RoomWorld
class_name BossRoom


# ==================================================
# Dependencies
# ==================================================

@onready var battle_trigger: BattleTrigger = $BattleTrigger


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	print("================================")
	print("BOSS ROOM READY")
	print("================================")

	if battle_trigger == null:

		push_error(
			"BossRoom: BattleTrigger not found."
		)

		return

	if not battle_trigger.battle_triggered.is_connected(
		_on_battle_triggered
	):

		battle_trigger.battle_triggered.connect(
			_on_battle_triggered
		)


# ==================================================
# Battle Trigger
# ==================================================

func _on_battle_triggered() -> void:

	print("================================")
	print("BOSS ROOM: BATTLE TRIGGERED")
	print("================================")

	var room_manager := get_tree().current_scene.get_node_or_null(
		"Managers/RoomManager"
	)

	if room_manager == null:

		push_error(
			"BossRoom: RoomManager not found."
		)

		return

	room_manager.start_room_battle()
