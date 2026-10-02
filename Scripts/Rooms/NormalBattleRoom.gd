extends RoomWorld
class_name NormalBattleRoom


# ==================================================
# Action Battle
# ==================================================

const ACTION_BATTLE_SCENE = preload(
	"res://Scenes/Battle/ActionBattleScene.tscn"
)


# ==================================================
# Roaming Enemies
# ==================================================

var roaming_enemies: Array[RoamingEnemy] = []


# ==================================================
# Roaming Enemy State
# ==================================================

var active_roaming_enemy: RoamingEnemy = null
var action_battle: ActionBattleScene = null


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	super._ready()

	print("================================")
	print("NORMAL BATTLE ROOM READY")
	print("================================")

	_connect_roaming_enemies()


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

	start_action_battle()


# ==================================================
# Action Battle
# ==================================================


func start_action_battle() -> void:

	print("!!! NORMAL BATTLE ROOM start_action_battle() CALLED !!!")

	if action_battle != null:
		push_warning(
			"NormalBattleRoom: Action battle already active."
		)
		return

	action_battle = ACTION_BATTLE_SCENE.instantiate()

	if action_battle == null:
		push_error(
			"NormalBattleRoom: Failed to create ActionBattleScene."
		)
		return

	if not action_battle.battle_completed.is_connected(
		_on_action_battle_completed
	):
		action_battle.battle_completed.connect(
			_on_action_battle_completed
		)

	print(
		"ACTION BATTLE SIGNAL CONNECTED:",
		action_battle.battle_completed.is_connected(
			_on_action_battle_completed
		)
	)

	add_child(action_battle)

	print("================================")
	print("ACTION BATTLE STARTED")
	print("================================")


func _on_action_battle_completed(
	won: bool
) -> void:

	print("================================")
	print("NORMAL BATTLE ROOM: ACTION BATTLE COMPLETED")
	print("Victory:", won)
	print("================================")


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

	if active:
		_disable_room_exits()
	else:
		enable_room_exits()
