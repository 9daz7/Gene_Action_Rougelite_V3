extends Node
class_name BattleManager

signal  battle_won(enemy)
signal battle_lost

const BATTLE_SCENE = preload("res://Scenes/Battle/BattleScene.tscn")
const PLAYER_SCENE = preload("res://Scenes/Animals/PlayerAnimal.tscn")
const ENEMY_SCENE = preload("res://Scenes/Animals/EnemyAnimal.tscn")

@onready var turn_manager = $"../TurnManager"
@onready var run_manager = $"../RunManager"
@onready var battle_root = $"../../World/BattleRoot"

var current_battle = null
var player = null
var enemies:Array = []


func start_battle():
	print("Starting battle")

	current_battle = BATTLE_SCENE.instantiate()

	battle_root.add_child(current_battle)

	await get_tree().process_frame

	# Spawn player
	player = current_battle.spawn_player(PLAYER_SCENE)

	for gene in run_manager.player_genes:
		player.add_gene(gene)

	var enemy = current_battle.spawn_enemy(ENEMY_SCENE)

	enemies.append(enemy)

	current_battle.setup_hp_bars(player, enemy)

	initialize_battle()


func initialize_battle():
	print("Battle initialized")

	if player.has_method("start_battle"):
		player.start_battle()


	for enemy in enemies:
		if enemy.has_method("start_battle"):
			enemy.start_battle()

	if turn_manager:
		turn_manager.start_battle(
			player, 
			enemies,
			current_battle.battle_ui
		)
	else:
		print("ERROR: TurnManager not found")
		

func check_battle_result():
	if player == null:
		return
		
	if player.hp <= 0:
		print("BattleManager: Player defeated")
		
		battle_lost.emit()
		
		end_battle()
		return
		
	for enemy in enemies:
		if enemy.hp <= 0:
			print("Batt;eManager: Enemy defeated")
			
			battle_won.emit(enemy)
			
			end_battle()
			return
	
func end_battle():
	print("Cleaning battle")

	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()

	enemies.clear()

	if is_instance_valid(player):
		player.queue_free()

	if is_instance_valid(current_battle):
		current_battle.queue_free()

	current_battle = null
	player = null
