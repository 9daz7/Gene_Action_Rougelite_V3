extends RoomWorld
class_name NormalBattleRoom


# ==================================================
# Action Player
# ==================================================

const ACTION_PLAYER_CHARACTER_SCENE = preload(
	"res://Scenes/Battle/ActionPlayerCharacter.tscn"
)

const PLAYER_ANIMAL_SCENE = preload(
	"res://Scenes/Animals/PlayerAnimal.tscn"
)

var action_player_character: ActionPlayerCharacter = null
var deebo: PlayerAnimal = null
var action_combat_controller: ActionCombatController = null


# ==================================================
# Roaming Enemies
# ==================================================

var roaming_enemies: Array[RoamingEnemy] = []


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	super._ready()

	print("================================")
	print("NORMAL BATTLE ROOM READY")
	print("================================")

	_connect_roaming_enemies()
	_setup_action_player()


# ==================================================
# Action Player Setup
# ==================================================

func _setup_action_player() -> void:

	var spawn_point := get_node_or_null("PlayerSpawn")

	if spawn_point == null:

		push_error(
			"NormalBattleRoom: PlayerSpawn not found."
		)

		return

	# --------------------------------------------------
	# Human Player
	# --------------------------------------------------

	action_player_character = (
		ACTION_PLAYER_CHARACTER_SCENE.instantiate()
	)

	if action_player_character == null:

		push_error(
			"NormalBattleRoom: Failed to create "
			+ "ActionPlayerCharacter."
		)

		return

	add_child(action_player_character)

	action_player_character.global_position = (
		spawn_point.global_position
	)

	# --------------------------------------------------
	# Deebo
	# --------------------------------------------------

	deebo = PLAYER_ANIMAL_SCENE.instantiate()

	if deebo == null:

		push_error(
			"NormalBattleRoom: Failed to create PlayerAnimal."
		)

		return

	add_child(deebo)

	deebo.global_position = (
		action_player_character.global_position
		+ Vector2(-60.0, 0.0)
	)

	# --------------------------------------------------
	# Controllers
	# --------------------------------------------------

	var deebo_controller := (
		deebo.get_node_or_null(
			"ActionPlayerController"
		)
	)

	var player_controller := (
		action_player_character.get_node_or_null(
			"ActionPlayerCharacterController"
		)
	)

	var player_combat := (
		action_player_character.get_node_or_null(
			"ActionPlayerCombatController"
		)
	)

	if deebo_controller == null:

		push_error(
			"NormalBattleRoom: ActionPlayerController "
			+ "not found on PlayerAnimal."
		)

		return

	if player_controller == null:

		push_error(
			"NormalBattleRoom: "
			+ "ActionPlayerCharacterController "
			+ "not found."
		)

		return

	if player_combat == null:

		push_error(
			"NormalBattleRoom: "
			+ "ActionPlayerCombatController "
			+ "not found."
		)

		return

	# --------------------------------------------------
	# Combat Controller
	# --------------------------------------------------

	action_combat_controller = (
		ActionCombatController.new()
	)

	add_child(action_combat_controller)

	action_combat_controller.setup(
		action_player_character,
		deebo
	)

	action_combat_controller.set_player_combat_controller(
		player_combat
	)

	deebo_controller.set_player_character(
		action_player_character
	)

	deebo_controller.set_combat_controller(
		action_combat_controller
	)

	player_controller.set_deebo_controller(
		deebo_controller
	)

	player_controller.set_player_combat_controller(
		player_combat
	)

	player_combat.set_combat_controller(
		action_combat_controller
	)

	print("================================")
	print("NORMAL BATTLE ROOM ACTION PLAYER READY")
	print("================================")


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

	#active_roaming_enemy = enemy

	print("================================")
	print("NORMAL BATTLE ROOM: ROAMING ENCOUNTER")
	print("Enemy:", enemy.name)
	print("================================")

	print(
		"Action combat migration in progress."
	)

	#set_player_controls(
		#false
	#)
#
	#start_action_battle()


# ==================================================
# Action Battle
# ==================================================


#func start_action_battle() -> void:
#
	#print("!!! NORMAL BATTLE ROOM start_action_battle() CALLED !!!")
#
	#if action_battle != null:
		#push_warning(
			#"NormalBattleRoom: Action battle already active."
		#)
		#return
#
	#action_battle = ACTION_BATTLE_SCENE.instantiate()
#
	#if action_battle == null:
		#push_error(
			#"NormalBattleRoom: Failed to create ActionBattleScene."
		#)
		#return
#
	#if not action_battle.battle_completed.is_connected(
		#_on_action_battle_completed
	#):
		#action_battle.battle_completed.connect(
			#_on_action_battle_completed
		#)
#
	#print(
		#"ACTION BATTLE SIGNAL CONNECTED:",
		#action_battle.battle_completed.is_connected(
			#_on_action_battle_completed
		#)
	#)
#
	#add_child(action_battle)
#
	#print("================================")
	#print("ACTION BATTLE STARTED")
	#print("================================")
#
#
#func _on_action_battle_completed(
	#won: bool
#) -> void:
#
	#print("================================")
	#print("NORMAL BATTLE ROOM: ACTION BATTLE COMPLETED")
	#print("Victory:", won)
	#print("================================")
#
	#if action_battle != null:
#
		#action_battle.queue_free()
		#action_battle = null
#
	#active_roaming_enemy = null
#
	#if not won:
#
		#set_player_controls(true)
#
		#return
#
	## --------------------------------------------------
	## Complete Room
	## --------------------------------------------------
#
	#print(
		#"NormalBattleRoom: Completing room."
	#)
#
	#room_manager.complete_room()


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
