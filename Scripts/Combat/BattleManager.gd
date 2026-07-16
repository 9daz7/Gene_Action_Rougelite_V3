extends Node
class_name BattleManager

signal battle_won(enemy)
signal battle_lost

const ENEMY_POOL = [
	preload("res://Data/Enemies/Normal/Wolf.tres"),
	preload("res://Data/Enemies/Normal/Boar.tres"),
	preload("res://Data/Enemies/Normal/Marten.tres")
]

const ELITE_POOL = [
	preload("res://Data/Enemies/Elite/AlphaWolf.tres"),
	preload("res://Data/Enemies/Elite/AlphaBoar.tres"),
	preload("res://Data/Enemies/Elite/GiantMarten.tres")
]

const BOSS_POOL = [
	preload("res://Data/Enemies/Boss/ModifiedWolf.tres")
]

const BATTLE_SCENE = preload("res://Scenes/Battle/BattleScene.tscn")
const PLAYER_SCENE = preload("res://Scenes/Animals/PlayerAnimal.tscn")
const ENEMY_SCENE = preload("res://Scenes/Animals/EnemyAnimal.tscn")

@onready var turn_manager = $"../TurnManager"
@onready var run_manager = $"../RunManager"
@onready var battle_root = $"../../World/BattleRoot"

var current_battle = null
var player = null
var enemies: Array = []

var current_battle_type = null
var critical_experiment := false
	

func _ready():

	turn_manager.battle_won.connect(_on_turn_battle_won)
	turn_manager.battle_lost.connect(_on_turn_battle_lost)
	
	
func start_critical_experiment():

	print("Starting critical experiment battle")
	
	critical_experiment = true

	start_battle(RoomData.RoomType.ELITE) # elite until criticalexperiment.tres is ready
	
	
func start_battle(room_type = RoomData.RoomType.ENEMY):
	print("Starting battle:", room_type)
	
	current_battle = BATTLE_SCENE.instantiate()
	battle_root.add_child(current_battle)

	await get_tree().process_frame
	
	enemies.clear()
	
	# Spawn player
	player = current_battle.spawn_player(PLAYER_SCENE)

	for gene in run_manager.player_genes:
		player.add_gene(gene)

	player.setup_player_hp(run_manager)
		
	# Spawn ONE enemy
	var enemy = current_battle.spawn_enemy(
		ENEMY_SCENE,
		0
	)

	enemy.enemy_data = get_enemy(room_type)

	print(
		"Enemy selected:",
		enemy.enemy_data.enemy_name
	)

	enemies.append(enemy)

	initialize_battle()
		
		
func start_group_battle():
	print("Starting 1v2 battle")
	current_battle = BATTLE_SCENE.instantiate()
	battle_root.add_child(current_battle)

	await get_tree().process_frame
	
	enemies.clear()
	
	# Spawn player
	player = current_battle.spawn_player(PLAYER_SCENE)

	for gene in run_manager.player_genes:
		player.add_gene(gene)

	player.setup_player_hp(run_manager)

	# Spawn two enemies
	for i in range(2):
		var enemy = current_battle.spawn_enemy(
			ENEMY_SCENE,
			i
		)

		enemy.enemy_data = get_enemy(
			RoomData.RoomType.GROUP_ENEMY
		)

		print(
			"Group enemy:",
			enemy.enemy_data.enemy_name
		)

		enemies.append(enemy)

	initialize_battle()
	

func get_enemy(room_type) -> EnemyResource:

	var pool = []
	
	match  room_type:
		
		RoomData.RoomType.ENEMY:
			pool = ENEMY_POOL
			
		RoomData.RoomType.GROUP_ENEMY:
			pool = ENEMY_POOL
			
		RoomData.RoomType.ELITE:
			pool = ELITE_POOL

		RoomData.RoomType.BOSS:
			pool = BOSS_POOL

	if pool.is_empty():
		print("ERROR: Enemy pool empty")
		return null
	
	var choices = pool.duplicate()

	choices.shuffle()

	return choices[0]
	

func get_random_elite() -> EnemyResource:

	var pool = ELITE_POOL.duplicate()
	
	if pool.is_empty():
		print("ERROR: Elite pool empty")
		return null

	pool.shuffle()

	return pool[0]


#func initialize_battle():
	#print("Battle initialized")
#
	#if player.has_method("start_battle"):
		#player.start_battle()
#
	#for enemy in enemies:
		#if enemy.has_method("start_battle"):
			#enemy.start_battle()
			#
	#current_battle.setup_hp_bars(player, enemies)
	##current_battle.setup_hp_bars(player, enemies[0])
#
	#turn_manager.start_battle(
		#player,
		#enemies,
		#current_battle.battle_ui
	#)
func initialize_battle():
	print("Battle initialized")

	if player.has_method("start_battle"):
		player.start_battle()

	for enemy in enemies:
		if enemy.has_method("start_battle"):
			enemy.start_battle()


	current_battle.setup_hp_bars(
		player,
		enemies
	)


	turn_manager.start_battle(
		player,
		enemies,
		current_battle.battle_ui
	)

 #func check_battle_result():
 	#if player == null:
 		#return
#
 	#if player.hp <= 0:
 		#print("BattleManager: Player defeated")
#
 		#battle_lost.emit()
#
 		#end_battle()
 		#return
#
 	#for enemy in enemies:
 		#if enemy.hp <= 0:
 			#print("Batt;eManager: Enemy defeated")
#
 			#battle_won.emit(enemy)
#
 			#end_battle()
 			#return


func _on_turn_battle_won(enemy):
	print("BattleManager received victory")
	
	if enemy == null:
		print("WARNING: Victory received with no enemy")
	else:
		print(
			"Battle won against:",
			enemy.enemy_data.enemy_name
		)
		
	battle_won.emit(enemy)

	end_battle()


func _on_turn_battle_lost():
	print("BattleManager received defeat")

	battle_lost.emit()

	end_battle()


func end_battle():
	print("Cleaning battle")

	if is_instance_valid(current_battle):
		current_battle.queue_free()

	enemies.clear()

	if is_instance_valid(player):
		player.queue_free()


	current_battle = null
	player = null
