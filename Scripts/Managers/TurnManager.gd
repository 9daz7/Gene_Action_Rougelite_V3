extends Node
class_name TurnManager

signal battle_won(enemy)
signal battle_lost

enum TurnState {
	NONE,
	PLAYER_TURN,
	ENEMY_TURN,
	BATTLE_OVER
}


var current_state := TurnState.NONE

var battle_ui = null
var player = null
var enemies:Array = []

#temp start battle
func start_battle(player, enemies, battle_ui):

	self.player = player
	self.enemies = enemies
	self.battle_ui = battle_ui


	print("TurnManager received UI:", battle_ui)


	battle_ui.move_selected.connect(
		_on_move_selected
	)


	print(
		"Signal connections:",
		battle_ui.move_selected.get_connections()
	)


	print("Turn system started")

	start_player_turn()
#func start_battle(player, enemies, battle_ui):
#
	#self.player = player
	#self.enemies = enemies
	#self.battle_ui = battle_ui
#
#
	#battle_ui.move_selected.connect(
		#_on_move_selected
	#)
#
#
	#print("Turn system started")
#
	#start_player_turn()


func start_player_turn():

	if current_state == TurnState.BATTLE_OVER:
		return

	current_state = TurnState.PLAYER_TURN

	# Reset temporary effects from previous turn
	if player:
		player.reset_turn_state()

	# Trigger passive effects
	start_turn_effects()

	print("Player turn")


func start_turn_effects():

	if player:
		player.trigger_passive_event("turn_start")

	for enemy in enemies:
		enemy.trigger_passive_event("turn_start")


func _on_move_selected(move_index:int):

	if current_state != TurnState.PLAYER_TURN:
		print("Not player turn")
		return

	if enemies.size() == 0:
		print("No enemies")
		return

	var enemy = enemies[0]

	var player_move = player.get_move(move_index)
	var enemy_move = enemy.choose_action(player)

	print("Player move:", player_move)
	print("Enemy move:", enemy_move)
	
	if player_move == null:
		print("Invalid player move")
		return

	if enemy_move == null:
		print("Enemy has no move")
		return


	print(
		"Player selected:",
		player_move.move_name
	)

	print(
		"Enemy selected:",
		enemy_move.move_name
	)

	resolve_turn(
		player_move,
		enemy_move,
		enemy
	)


func resolve_turn(player_move, enemy_move, enemy):

	current_state = TurnState.ENEMY_TURN

	# Higher priority acts first
	if player_move.priority >= enemy_move.priority:

		print("Player moves first")

		player_move.execute(
			player,
			enemy
		)

		check_battle_end()

		if current_state == TurnState.BATTLE_OVER:
			return

		enemy_move.execute(
			enemy,
			player
		)

	else:

		print("Enemy moves first")

		enemy_move.execute(
			enemy,
			player
		)

		check_battle_end()

		if current_state == TurnState.BATTLE_OVER:
			return

		player_move.execute(
			player,
			enemy
		)


	check_battle_end()

	if current_state != TurnState.BATTLE_OVER:

		end_turn()


func end_turn():

	# Future:
	# poison damage
	# regeneration
	# parasite healing
	# damage over time

	trigger_turn_end_effects()

	start_player_turn()


func trigger_turn_end_effects():

	if player:
		player.trigger_passive_event("turn_end")
		
	for enemy in enemies:
		enemy.trigger_passive_event("turn_end")


func check_battle_end():

	if player == null:
		return

	if player.hp <= 0:

		print("Player defeated")

		current_state = TurnState.BATTLE_OVER
		battle_lost.emit()

		return


	for enemy in enemies:

		if enemy.hp <= 0:

			print("Enemy defeated")

			current_state = TurnState.BATTLE_OVER
			battle_won.emit(enemy)

			return
