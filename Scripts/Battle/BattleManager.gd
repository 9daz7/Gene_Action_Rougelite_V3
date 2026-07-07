extends Node


const BATTLE_SCENE = preload("res://Scenes/Battle/BattleScene.tscn")

const PLAYER_SCENE = preload("res://Scenes/Animals/PlayerAnimal.tscn")

const ENEMY_SCENE = preload("res://Scenes/Animals/EnemyAnimal.tscn")


var current_battle

var player

var enemies = []



func start_battle():

	print("Starting battle")


	current_battle = BATTLE_SCENE.instantiate()

	get_tree().current_scene.add_child(current_battle)



	player = current_battle.spawn_player(PLAYER_SCENE)



	var enemy = current_battle.spawn_enemy(ENEMY_SCENE)

	enemies.append(enemy)



	initialize_battle()



func initialize_battle():

	print("Battle initialized")



	if player.has_method("start_battle"):

		player.start_battle()



	for enemy in enemies:

		if enemy.has_method("start_battle"):

			enemy.start_battle()




func end_battle():

	print("Cleaning battle")


	for enemy in enemies:

		enemy.queue_free()


	enemies.clear()


	if player:

		player.queue_free()


	if current_battle:

		current_battle.queue_free()


	current_battle = null

	player = null
