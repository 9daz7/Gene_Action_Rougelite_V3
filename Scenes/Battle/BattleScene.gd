extends Node2D


@onready var player_container = $PlayerContainer
@onready var player_spawn = $PlayerContainer/PlayerSpawn

@onready var enemy_container = $EnemyContainer

var player
var enemy

func spawn_player(player_scene):
	player = player_scene.instantiate()
	player_container.add_child(player)
	player.global_position = player_spawn.global_position
	return player



func spawn_enemy(enemy_scene):
	enemy = enemy_scene.instantiate()
	enemy_container.add_child(enemy)
	enemy.global_position = Vector2(500, 300)
	return enemy
