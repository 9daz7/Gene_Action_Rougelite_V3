extends Node
class_name TurnManager

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

func start_battle(player_ref, enemy_refs:Array, ui):
	player = player_ref
	enemies = enemy_refs
	battle_ui = ui
	
	print("Turn system started")
	
	if battle_ui:
		battle_ui.move_selected.connect(
			_on_move_selected
		)
		
	start_player_turn()
	
func start_player_turn():
	if current_state == TurnState.BATTLE_OVER:
		return
		
	player.reset_turn_state()
	current_state = TurnState.PLAYER_TURN
	print("Player turn")
	
#func start_enemy_turn():
	#if current_state == TurnState.BATTLE_OVER:
		#return
	#current_state = TurnState.ENEMY_TURN
	#print("Enemy turn")
	#
	#if enemies.size() > 0:
		#
		#var enemy = enemies[0]
		#var action = enemy.choose_action(player)
		#
		#match action:
			#"attack":
				#enemy.attack(player)
			#"protect":
				#print("Enemy protects")
			#
	#check_battle_end()
	#
	#if current_state != TurnState.BATTLE_OVER:
		#
		#start_player_turn()
	#
	
func _on_move_selected(move_index:int):
	if current_state != TurnState.PLAYER_TURN:
		return

	if enemies.size() == 0:
		return

	var enemy = enemies[0]
	
	var player_move = player.get_move(move_index)
	var enemy_move = enemy.choose_action(player)
	
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
	
	if player_move.priority >= enemy_move.priority:
		print("Player moves first")
		
		player_move.execute(player,enemy)
		
		check_battle_end()
		

		if current_state != TurnState.BATTLE_OVER:
			enemy_move.execute(enemy,player)
			
	else:
		print("Enemy moves first")
		
		enemy_move.execute(enemy,player)
		
		check_battle_end()
		
		if current_state != TurnState.BATTLE_OVER:
			player_move.execute(player,enemy)
			
	check_battle_end()
	
	if current_state != TurnState.BATTLE_OVER:
		
		start_player_turn()
	
#func player_attack():
	#if current_state != TurnState.PLAYER_TURN:
		#return
	#
	#print("Player attacks")
	#
	#var enemy = enemies[0]
	#var damage = player.get_attack()
	#enemy.take_damage(damage)
	#check_battle_end()
	#
	#if current_state != TurnState.BATTLE_OVER:
		#start_enemy_turn()
	
func check_battle_end():
	if player == null:
		return

	if player.hp <= 0:
		print("Player defeated")
		current_state = TurnState.BATTLE_OVER
		return

	for enemy in enemies:
		if enemy.hp <= 0:
			print("Enemy defeated")
			current_state = TurnState.BATTLE_OVER
			return
		
