extends Node

const BATTLE_SCENE = preload("res://Scenes/Battle/BattleScene.tscn")
const PLAYER_SCENE = preload("res://Scenes/Animals/PlayerAnimal.tscn")
const ENEMY_SCENE = preload("res://Scenes/Animals/EnemyAnimal.tscn")

var current_battle
var player
var enemies: Array = []


func start_battle():
	print("Starting battle")

	# Create battle scene
	current_battle = BATTLE_SCENE.instantiate()
	print("BattleScene created")

	get_tree().root.add_child(current_battle)
	print("BattleScene added")

	# Spawn player
	player = current_battle.spawn_player(PLAYER_SCENE)
	print("Player spawned: ", player)

	# Spawn enemy
	var enemy = current_battle.spawn_enemy(ENEMY_SCENE)
	print("Enemy spawned: ", enemy)

	enemies.append(enemy)

	initialize_battle()


func initialize_battle():
	print("Battle initialized")

	if player:
		if player.has_method("start_battle"):
			player.start_battle()


	for enemy in enemies:
		if enemy.has_method("start_battle"):
			enemy.start_battle()

	test_turn()



func test_turn():
	print("---- TURN ----")

	if enemies.size() == 0:
		return

	var enemy = enemies[0]

	var action = enemy.choose_action(player)

	if action == "attack":
		enemy.attack(player)
	else:
		print("Enemy protects")



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
