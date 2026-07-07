extends Node
class_name TurnManager

enum TurnState {
	NONE,
	PLAYER_TURN,
	ENEMY_TURN,
	BATTLE_OVER
}

var current_state := TurnState.NONE

var player
var enemies:Array = []

func start_battle(player_ref, enemy_refs:Array):
	player = player_ref
	enemies = enemy_refs
	
	print("Turn system started")
	
	start_player_turn()
	
func start_player_turn():
	current_state = TurnState.PLAYER_TURN
	print("Player turn")
	
func start_enemy_turn():
	current_state = TurnState.ENEMY_TURN
	print("Enemy turn")
	
	if enemies.size() > 0:
		
		var enemy = enemies[0]
		var action = enemy.choose_action(player)
		
		if action == "attack":
			enemy.attack(player)
		else:
			print("Enemy protects")
			
	check_battle_end()
	
	
func player_attack():
	if current_state != TurnState.PLAYER_TURN:
		return
	
	print("Player attacks")
	
	var enemy = enemies[0]
	var damage = player.get_attack()
	enemy.take_damage(damage)
	check_battle_end()
	
	if current_state != TurnState.BATTLE_OVER:
		start_enemy_turn()
	
func check_battle_end():
	if player.hp <= 0:
		print("Player defeated")
		current_state = TurnState.BATTLE_OVER
	
	for enemy in enemies:
		if enemy.hp <= 0:
			print("Enemy defeated")
			current_state = TurnState.BATTLE_OVER
		
