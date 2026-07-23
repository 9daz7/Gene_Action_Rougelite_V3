extends Node
class_name BattleManager


# ==================================================
# Signals
# ==================================================


signal battle_won(enemy)
signal battle_lost


# ==================================================
# Enemy Pools
# ==================================================


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


# ==================================================
# Scene References
# ==================================================


const BATTLE_SCENE = preload("res://Scenes/Battle/BattleScene.tscn")
const PLAYER_SCENE = preload("res://Scenes/Animals/PlayerAnimal.tscn")
const ENEMY_SCENE = preload("res://Scenes/Animals/EnemyAnimal.tscn")


# ==================================================
# Dependencies
# ==================================================


var turn_manager: TurnManager
var run_manager: RunManager
var battle_root: Node


# ==================================================
# Battle State
# ==================================================


var current_battle = null
var player = null
var enemies: Array = []

var current_battle_type = null
var critical_experiment := false


func initialize(
	manager: RunManager,
	turns: TurnManager,
	root: Node
):

	run_manager = manager
	turn_manager = turns
	battle_root = root
	
	if turn_manager:
		
		turn_manager.battle_won.connect(
			_on_turn_battle_won
		)

		turn_manager.battle_lost.connect(
			_on_turn_battle_lost
		)
		
	else:
		
		push_error(
			"BattleManager initialized without TurnManager"
		)
	

func start_critical_experiment():

	print("Starting critical experiment battle")
	
	critical_experiment = true
	
	current_battle_type = RoomData.RoomType.ELITE
	
	print("Critical flag set:", critical_experiment)

	start_battle(RoomData.RoomType.ELITE) # elite until criticalexperiment.tres is ready
	
	
# ==================================================
# Battle Creation
# ==================================================


func start_battle(room_type = RoomData.RoomType.ENEMY):
	
	current_battle_type = room_type
	
	enemies.clear()

	create_battle_scene()

	spawn_player()

	spawn_enemy(room_type)
	
	initialize_battle()
	
		
func create_battle_scene():

	current_battle = BATTLE_SCENE.instantiate()

	battle_root.add_child(current_battle)

	await get_tree().process_frame
		

func spawn_player():

	player = current_battle.spawn_player(
		PLAYER_SCENE
	)

	var build = run_manager.current_animal_build

	if build:
		player.load_build(build)

	player.setup_player_hp(
		run_manager
	)
	

func spawn_enemy(room_type):

	var enemy = current_battle.spawn_enemy(
		ENEMY_SCENE,
		0
	)

	enemy.enemy_data = get_enemy(room_type)
	
	if enemy.enemy_data == null:
		push_error("No enemy resource found")
		return

	enemies.append(enemy)
	
		
func start_group_battle():
	
	current_battle_type = RoomData.RoomType.GROUP_ENEMY

	enemies.clear()

	create_battle_scene()

	spawn_player()

	spawn_multiple_enemies(2)

	initialize_battle()
	

func spawn_multiple_enemies(amount:int):

	for i in range(amount):

		var enemy = current_battle.spawn_enemy(
			ENEMY_SCENE,
			i
		)

		enemy.enemy_data = get_enemy(
			RoomData.RoomType.GROUP_ENEMY
		)

		enemies.append(enemy)
		
		
# ==================================================
# Enemy Selection
# ==================================================


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


func initialize_battle():
	print("Battle initialized")

	if player == null:
		push_error("Battle initialized without player")
		return

	if enemies.is_empty():
		push_error("Battle initialized without enemies")
		return
		
	if player.has_method("start_battle"):
		player.start_battle()

	for enemy in enemies:
		if enemy.has_method("start_battle"):
			enemy.start_battle()


	current_battle.setup_hp_bars(
		player,
		enemies
	)

	current_battle.battle_ui.setup_names(
		player,
		enemies[0]
	)

	turn_manager.start_battle(
		player,
		enemies,
		current_battle.battle_ui
	)


# ==================================================
# Battle Results
# ==================================================


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
	
	await get_tree().process_frame
	
	end_battle()


func _on_turn_battle_lost():
	print("BattleManager received defeat")

	battle_lost.emit()

	end_battle()


	
func end_battle():
	print("Cleaning battle")

	# Remove battle scene
	if is_instance_valid(current_battle):
		current_battle.queue_free()

	# Remove player
	if is_instance_valid(player):
		player.queue_free()

	# Remove enemies
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()

	enemies.clear()
	
	current_battle = null
	player = null
	

	print("Battle cleanup complete")
	
	
func reset_battle_state():
	current_battle_type = null
	critical_experiment = false
