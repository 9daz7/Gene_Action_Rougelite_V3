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
var enemies: Array = []


# -------------------------------------------------------------------
# Battle setup
# -------------------------------------------------------------------

func start_battle(player, enemies, battle_ui):
	current_state = TurnState.NONE

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


# func start_battle(player, enemies, battle_ui):
#
# 	self.player = player
# 	self.enemies = enemies
# 	self.battle_ui = battle_ui
#
#
# 	battle_ui.move_selected.connect(
# 		_on_move_selected
# 	)
#
#
# 	print("Turn system started")
#
# 	start_player_turn()


# -------------------------------------------------------------------
# Player turn
# -------------------------------------------------------------------

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


# -------------------------------------------------------------------
# Move selection
# -------------------------------------------------------------------

func get_active_enemy():
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
	
	resolve_group_turn(
		player_move,
		target_enemy,
		enemy_moves
	)


# -------------------------------------------------------------------
# Turn resolution
# -------------------------------------------------------------------

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


func resolve_group_turn(player_move, target_enemy, enemy_moves):
	current_state = TurnState.ENEMY_TURN

	print("Player attacks:", target_enemy)

	player_move.execute(
		player,
		target_enemy
	)

	check_battle_end()

	if current_state == TurnState.BATTLE_OVER:
		return


	for data in enemy_moves:

		var enemy = data.enemy
		var move = data.move

		print(
			enemy.name,
			" uses ",
			move.move_name
		)

		move.execute(
			enemy,
			player
		)

		check_battle_end()

		if current_state == TurnState.BATTLE_OVER:
			return

	end_turn()
	
	
# -------------------------------------------------------------------
# Turn end
# -------------------------------------------------------------------

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


# -------------------------------------------------------------------
# Battle checks
# -------------------------------------------------------------------

func check_battle_end():
	if player == null:
		return

	if player.hp <= 0:
		print("Player defeated")

		current_state = TurnState.BATTLE_OVER
		battle_lost.emit()
		return
	
	var all_dead = true
	
	for enemy in enemies:
		if enemy.hp > 0:
			all_dead = false
			
	if all_dead:
		print("All enemies defeated")

		current_state = TurnState.BATTLE_OVER
			
		var defeated_enemy = null

		if enemies.size() > 0:
			defeated_enemy = enemies[0]

		battle_won.emit(defeated_enemy)

		if battle_ui:
			battle_ui.hide()
