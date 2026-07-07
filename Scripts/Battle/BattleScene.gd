extends Node2D


@onready var player_container = $PlayerContainer
@onready var player_spawn = $PlayerContainer/PlayerSpawn

@onready var enemy_container = $EnemyContainer
@onready var enemy_spawn = $EnemyContainer/EnemySpawn


func spawn_player(player_scene):

	var player = player_scene.instantiate()

	player_container.add_child(player)

	player.position = player_spawn.position

	return player



func spawn_enemy(enemy_scene):

	var enemy = enemy_scene.instantiate()

	enemy_container.add_child(enemy)

	enemy.position = enemy_spawn.position

	return enemy



func clear_battle():

	for enemy in enemy_container.get_children():

		enemy.queue_free()


	for player in player_container.get_children():

		player.queue_free()
