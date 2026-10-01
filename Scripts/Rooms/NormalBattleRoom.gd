extends RoomWorld
class_name NormalBattleRoom


# ==================================================
# Battle Trigger
# ==================================================

@onready var battle_trigger: BattleTrigger = $BattleTrigger


# ==================================================
# Roaming Enemies
# ==================================================

var roaming_enemies: Array[RoamingEnemy] = []


# ==================================================
# Roaming Enemy State
# ==================================================

var active_roaming_enemy: RoamingEnemy = null


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	super._ready()

	print("================================")
	print("NORMAL BATTLE ROOM READY")
	print("================================")

	_connect_battle_trigger()
	_connect_roaming_enemies()


# ==================================================
# Battle Trigger
# ==================================================


func _connect_battle_trigger() -> void:

	if battle_trigger == null:

		push_error(
			"NormalBattleRoom: BattleTrigger not found."
		)

		return

	if not battle_trigger.player_entered.is_connected(
		_on_battle_trigger_entered
	):

		battle_trigger.player_entered.connect(
			_on_battle_trigger_entered
	)


func _on_battle_trigger_entered() -> void:

	print("================================")
	print("NORMAL BATTLE ROOM: BATTLE TRIGGERED")
	print("================================")

	if room_manager == null:

		push_error(
			"NormalBattleRoom: RoomManager not found."
		)

		return

	set_player_controls(false)


func _connect_roaming_enemies() -> void:

	roaming_enemies.clear()

	var enemies := find_children(
		"*",
		"RoamingEnemy",
		true,
		false
	)

	for enemy in enemies:

		if not enemy is RoamingEnemy:
			continue

		roaming_enemies.append(
			enemy
		)

		if not enemy.encounter_requested.is_connected(
			_on_roaming_enemy_encounter
		):

			enemy.encounter_requested.connect(
				_on_roaming_enemy_encounter
			)

	print(
		"Roaming enemies found:",
		roaming_enemies.size()
	)


func _on_roaming_enemy_encounter(
	enemy: RoamingEnemy
) -> void:

	if enemy == null:
		return

	if active_roaming_enemy != null:
		return

	if enemy.enemy_data == null:

		push_error(
			"NormalBattleRoom: Roaming enemy has no EnemyResource."
		)

		return

	active_roaming_enemy = enemy

	print("================================")
	print("NORMAL BATTLE ROOM: ROAMING ENCOUNTER")
	print("Enemy:", enemy.name)
	print("================================")

	set_player_controls(
		false
	)

	# --------------------------------------------------
	# Temporary test
	# --------------------------------------------------

	print(
		"ROAMING ENCOUNTER DETECTION TEST PASSED"
	)


# ==================================================
# Battle State
# ==================================================


func set_battle_active(
	active: bool
) -> void:

	print(
		"NormalBattleRoom battle active:",
		active
	)

	set_player_controls(
		not active
	)

	if battle_trigger != null:

		if active:

			battle_trigger.call_deferred(
				"set_process_mode",
				Node.PROCESS_MODE_DISABLED
			)

			_disable_room_exits()

		else:

			battle_trigger.call_deferred(
				"set_process_mode",
				Node.PROCESS_MODE_INHERIT
			)

			enable_room_exits()
