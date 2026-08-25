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

	room_manager.start_room_battle()


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

	print("================================")
	print("NORMAL BATTLE ROOM: ROAMING ENCOUNTER")
	print("Enemy:", enemy.name)
	print("================================")

	set_player_controls(
		false
	)

	print(
		"RoomPlayer controls:",
		false
	)

	# --------------------------------------------------
	# Temporary test
	# --------------------------------------------------

	print(
		"ROAMING ENCOUNTER DETECTION TEST PASSED"
	)


# ==================================================
# Room Exits
# ==================================================

#func _connect_room_exits() -> void:
#
	#room_exits.clear()
#
	#for child in get_children():
#
		#if child is RoomExit:
#
			#room_exits.append(child)
#
			#child.set_enabled(false)
#
			#if not child.exit_entered.is_connected(
				#_on_room_exit_entered
			#):
#
				#child.exit_entered.connect(
					#_on_room_exit_entered
				#)
#
			#print(
				#"Connected RoomExit:",
				#child.exit_id
			#)


# ==================================================
# Room Completion
# ==================================================\


#func _disable_room_exits() -> void:
#
	#print("================================")
	#print("DISABLING ROOM EXITS")
	#print("================================")
#
	#for room_exit in room_exits:
#
		#if is_instance_valid(room_exit):
#
			#room_exit.set_enabled(false)
#
			#print(
				#"Exit disabled:",
				#room_exit.exit_id
			#)
#

#func enable_room_exits() -> void:
#
	#print("================================")
	#print("ENABLING ROOM EXITS")
	#print("================================")
#
	#for room_exit in room_exits:
#
		#if is_instance_valid(room_exit):
#
			#room_exit.set_enabled(true)
#
			#print(
				#"Exit enabled:",
				#room_exit.exit_id
			#)
#
#
#func _on_room_exit_entered(exit_id: int) -> void:
#
	#print("================================")
	#print("NORMAL BATTLE ROOM: EXIT ENTERED")
	#print("Exit ID:", exit_id)
	#print("================================")
#
	#if room_manager == null:
#
		#push_error(
			#"NormalBattleRoom: RoomManager not found."
		#)
#
		#return
#
	#room_manager.select_room_exit(
		#exit_id
	#)
#
#
## ==================================================
## Player
## ==================================================
#
#
#func _spawn_player() -> void:
#
	#room_player = ROOM_PLAYER_SCENE.instantiate()
#
	#if room_player == null:
#
		#push_error(
			#"NormalBattleRoom: Failed to instantiate RoomPlayer."
		#)
#
		#return
#
	#add_child(room_player)
#
	#room_player.global_position = $PlayerSpawn.global_position
#
	#print(
		#"RoomPlayer spawned at:",
		#room_player.global_position
	#)
#
#
## ==================================================
## Player Controls
## ==================================================
#
#func set_player_controls(
	#enabled: bool
#) -> void:
#
	#if room_player == null:
#
		#push_error(
			#"NormalBattleRoom: Cannot change controls. "
			#+ "RoomPlayer is missing."
		#)
#
		#return
#
	#room_player.set_controls_enabled(
		#enabled
	#)
#
	#print(
		#"NormalBattleRoom player controls:",
		#enabled
	#)
#

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
