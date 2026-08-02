extends Node
class_name TurnManager


# ==================================================
# Signals
# ==================================================


signal battle_won(enemy)
signal battle_lost


# ==================================================
# Enums
# ==================================================


enum TurnState {
	NONE,
	PLAYER_TURN,
	ENEMY_TURN,
	BATTLE_OVER
}


# ==================================================
# Member Variables
# ==================================================


var current_state := TurnState.NONE

var player: PlayerAnimal
var enemies:Array[EnemyAnimal] = []


# ==================================================
# Initialization
# ==================================================


func initialize(
	player_ref:PlayerAnimal,
	enemy_refs:Array[EnemyAnimal],
):

	player = player_ref
	enemies = enemy_refs

	start_battle()

func _ready():

	if not GameEvents.move_selected.is_connected(
		_on_move_selected
	):

		GameEvents.move_selected.connect(
			_on_move_selected
		)


# ==================================================
# Battle Setup
# ==================================================

func start_battle():

	current_state = TurnState.NONE

	print("Turn system started")

	player.trigger_passive_event(
		"battle_start"
	)

	for enemy in enemies:

		enemy.trigger_passive_event(
			"battle_start"
		)

	GameEvents.battle_started.emit()

	##battle_ui.setup_moves(player)
	GameEvents.turn_changed.emit(
		current_state
	)

	GameEvents.moves_updated.emit(
		player
	)

	start_player_turn()


# ==================================================
# Player Turn
# ==================================================

func start_player_turn():

	if current_state == TurnState.BATTLE_OVER:
		return

	if player == null:
		print("Cannot start player turn. Player is missing.")
		return

	current_state = TurnState.PLAYER_TURN

	print("Player turn")
	
	player.reset_turn_state()

	# -----------------------------------
	# Status damage first
	# -----------------------------------

	player.process_status_effects()

	for enemy in enemies:

		if enemy.hp > 0:

			enemy.process_status_effects()

	# -----------------------------------
	# Passive turn start effects
	# -----------------------------------

	player.trigger_passive_event(
		"turn_start"
	)

	for enemy in enemies:

		if enemy.hp > 0:
			
			enemy.trigger_passive_event(
				"turn_start"
			)

	# -----------------------------------
	# Update UI
	# -----------------------------------

	GameEvents.status_changed.emit(
		player,
		get_active_enemy()
	)


	GameEvents.turn_changed.emit(
		current_state
	)


	GameEvents.moves_updated.emit(
		player
	)

	#player.process_status_effects()
#
	#for enemy in enemies:
#
		#if enemy.hp > 0:
			#enemy.process_status_effects()
#
	#GameEvents.status_changed.emit(
		#player,
		#get_active_enemy()
	#)
#
	## allow buttons
	#GameEvents.turn_changed.emit(
		#current_state
	#)
#
	#GameEvents.moves_updated.emit(
		#player
	#)


# ==================================================
# Move Selection
# ==================================================



func get_active_enemy() -> EnemyAnimal:
	
	for enemy in enemies:
		if enemy.hp > 0:
			return enemy

	return null
	
	
func _on_move_selected(move_index: int):
	
	if current_state != TurnState.PLAYER_TURN:
		print("Not player turn")
		return

	var target_enemy = get_active_enemy()
	
	if target_enemy == null:
		print("No living enemies")
		return
		
	var player_move = player.get_move(move_index)
	
	if player_move == null:
		print("Invalid player move")
		return
	
	print(
		"Player selected:",
		player_move.move_name
	)
	
	var enemy_moves:Array = []

	for enemy in enemies:
		if enemy.hp > 0:
			var move = enemy.choose_action(player)

			if move:
				enemy_moves.append(
					{
						"enemy":enemy,
						"move":move
					}
				)
				
	print(
		"Enemies attacking:",
		enemy_moves.size()
	)
	
	resolve_turn(
		player_move,
		target_enemy,
		enemy_moves
	)


# ==================================================
# Turn Resolution
# ==================================================


func resolve_turn(
	player_move: MoveResource,
	target_enemy: EnemyAnimal,
	enemy_moves:Array
):
	
	current_state = TurnState.ENEMY_TURN
	
	GameEvents.turn_changed.emit(
		current_state
	)
	
	# Player action
	print(
		"Player uses:",
		player_move.move_name
	)

	GameEvents.move_used.emit(
		player,
		player_move
	)

	player_move.execute(
		player,
		target_enemy
	)

	#battle_ui.update_status_labels(
		#player,
		#get_active_enemy()
	#)

	check_battle_end()

	if current_state == TurnState.BATTLE_OVER:
		return

	# Enemy actions
	for data in enemy_moves:

		var enemy = data.enemy
		var move = data.move

		print(
			enemy.name,
			" uses ",
			move.move_name
		)

		GameEvents.move_used.emit(
			enemy,
			move
		)

		move.execute(
			enemy,
			player
		)

		#battle_ui.update_status_labels(
			#player,
			#get_active_enemy()
		#)

		check_battle_end()

		if current_state == TurnState.BATTLE_OVER:
			return

	end_turn()


# ==================================================
# Turn End
# ==================================================

func end_turn():
	
	if current_state == TurnState.BATTLE_OVER:
		return

	if player == null:
		return

	trigger_turn_end_effects()

	start_player_turn()


func trigger_turn_end_effects():

	if player:
		player.trigger_passive_event(
			"turn_end"
		)

	for enemy in enemies:

		if enemy.hp > 0:

			enemy.trigger_passive_event(
				"turn_end"
			)


# ==================================================
# Battle Checks
# ==================================================


func check_battle_end():

	if player == null:
		return

	if player.hp <= 0:
		print("Player defeated")

		current_state = TurnState.BATTLE_OVER

		player.trigger_passive_event(
			"battle_end"
		)

		for defeated_enemy in enemies:

			defeated_enemy.trigger_passive_event(
				"battle_end"
			)

		battle_lost.emit()

		return

	for enemy in enemies:

		if enemy.hp > 0:
			return

		print("All enemies defeated")

		current_state = TurnState.BATTLE_OVER

		player.trigger_passive_event(
			"battle_end"
		)

		for defeated_enemy in enemies:

			defeated_enemy.trigger_passive_event(
				"battle_end"
			)

		var defeated_enemy := enemies[0] if enemies.size() > 0 else null

		battle_won.emit(
			defeated_enemy
		)

		#if battle_ui:
			#battle_ui.hide()


# ==================================================
# Cleanup
# ==================================================

func reset():

	current_state = TurnState.NONE

	player = null

	enemies.clear()

	print("TurnManager reset")
