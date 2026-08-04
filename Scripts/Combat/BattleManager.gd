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
	preload("res://Data/Enemies/Normal/Marten.tres"),
	preload("res://Data/Enemies/Normal/Cheetah.tres"),
	preload("res://Data/Enemies/Normal/SnappingTurtle.tres"),
	preload("res://Data/Enemies/Normal/HoneyBadger.tres"),
]

const ELITE_POOL = [
	#preload("res://Data/Enemies/Elite/AlphaWolf.tres"),
	#preload("res://Data/Enemies/Elite/AlphaBoar.tres"),
	#preload("res://Data/Enemies/Elite/GiantMarten.tres")
	preload("res://Data/Enemies/Normal/Wolf.tres"),
	preload("res://Data/Enemies/Normal/Boar.tres"),
	preload("res://Data/Enemies/Normal/Marten.tres"),
	preload("res://Data/Enemies/Normal/Cheetah.tres"),
	preload("res://Data/Enemies/Normal/SnappingTurtle.tres"),
	preload("res://Data/Enemies/Normal/HoneyBadger.tres"),
]

const BOSS_POOL = [
	preload("res://Data/Enemies/Boss/ModifiedWolf.tres")
]


# ==================================================
# Scene References
# ==================================================


const BATTLE_SCENE = preload("res://Scenes/Battle/BattleScene.tscn")


# ==================================================
# Dependencies
# ==================================================


var turn_manager: TurnManager
var run_manager: RunManager
var battle_root: Node
var spawner:BattleSpawner


# ==================================================
# Battle State
# ==================================================


var current_battle: Node = null
var player: PlayerAnimal
var enemies: Array[EnemyAnimal] = []

var current_battle_type = null
var critical_experiment := false


func initialize(
	manager: RunManager,
	turns: TurnManager,
	root: Node,
	spawn: BattleSpawner
):

	run_manager = manager
	turn_manager = turns
	battle_root = root
	spawner = spawn

	if turn_manager:

		if not turn_manager.battle_won.is_connected(
			_on_turn_battle_won
		):
			turn_manager.battle_won.connect(
				_on_turn_battle_won
			)

		if not turn_manager.battle_lost.is_connected(
			_on_turn_battle_lost
		):
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


func start_battle(
	room_type = RoomData.RoomType.ENEMY
):

	if room_type != RoomData.RoomType.ELITE:

		critical_experiment = false

	if spawner == null:

		push_error(
			"BattleSpawner missing"
		)

		return


	current_battle_type = room_type

	enemies.clear()

	await create_battle_scene()

	player = spawner.spawn_player()

	var enemy_count := get_enemy_count(
		room_type
	)

	var enemy_resources:Array[EnemyResource] = []

	for i in range(enemy_count):

		var resource = get_enemy(
			room_type
		)

		if resource:

			enemy_resources.append(
				resource
			)

	enemies = spawner.spawn_enemies(
		enemy_resources
	)

	initialize_battle()


func create_battle_scene():

	if battle_root == null:
		push_error("Battle root missing")
		return

	if is_instance_valid(current_battle):
		current_battle.queue_free()

	current_battle = BATTLE_SCENE.instantiate()

	battle_root.add_child(current_battle)

	await get_tree().process_frame

	spawner.initialize(
		current_battle,
		run_manager
	)

# dont think i need this
#func start_group_battle(
	#room_type = RoomData.RoomType.GROUP_ENEMY
#):
#
	#current_battle_type = RoomData.RoomType.GROUP_ENEMY
#
	#enemies.clear()
#
	#await create_battle_scene()
#
	#player = spawner.spawn_player()
#
	#var resources:Array[EnemyResource] = []
#
	#for i in range(2):
#
		#resources.append(
			#get_enemy(
				#RoomData.RoomType.GROUP_ENEMY
			#)
		#)
#
	#enemies = spawner.spawn_enemies(
		#resources
	#)
#
	#initialize_battle()
#

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


func get_enemy_count(
	room_type
) -> int:

	match room_type:

		RoomData.RoomType.ENEMY:

			return 1

		RoomData.RoomType.GROUP_ENEMY:

			return 3

		RoomData.RoomType.ELITE:

			return 2

		RoomData.RoomType.BOSS:

			return 1

	return 1


func initialize_battle():
	print("Battle initialized")

	if player == null:
		push_error("Battle initialized without player")
		return

	if current_battle == null:
		push_error("Battle initialized without scene")
		return

	if enemies.is_empty():
		push_error("Battle initialized without enemies")
		return

	if player.has_method("start_battle"):
		player.start_battle()

	for enemy in enemies:

		if enemy == null:
			push_error("Enemy list contains null enemy")
			continue

		if enemy.has_method("start_battle"):
			enemy.start_battle()

	GameEvents.battle_initialized.emit(
		player,
		enemies
	)

	GameEvents.battle_names_updated.emit(
		player,
		enemies
	)

	GameEvents.hp_changed.emit(
	player,
	player.hp,
	player.get_max_hp()
)


	for enemy in enemies:

		GameEvents.hp_changed.emit(
			enemy,
			enemy.hp,
			enemy.get_max_hp()
		)

	print("==========================")
	print("BattleManager enemy list")

	for enemy in enemies:
		print(enemy.name)

	print("==========================")

	turn_manager.initialize(
		player,
		enemies,
	)

	GameEvents.battle_started.emit(
		enemies
	)

func show_battle_start(enemy):

	print("Battle started against ", enemy.get_display_name())


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

	GameEvents.battle_finished.emit(
		"win"
	)

	battle_won.emit(enemy)

	#if critical_experiment:
		#print("Resetting critical experiment flag")
		#critical_experiment = false

	await get_tree().process_frame

	end_battle()


func _on_turn_battle_lost():

	print("BattleManager received defeat")

	if turn_manager:
		turn_manager.current_state = TurnManager.TurnState.BATTLE_OVER


	GameEvents.battle_finished.emit(
		"lose"
	)

	battle_lost.emit()

	await get_tree().process_frame

	end_battle()


func end_battle():

	print("Cleaning battle")

	critical_experiment = false

	# Reset turn manager references
	if turn_manager:
		
		turn_manager.current_state = TurnManager.TurnState.BATTLE_OVER

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

	if turn_manager:
		turn_manager.reset()

	print("Battle cleanup complete")


func reset_battle_state():
	current_battle_type = null
	critical_experiment = false
