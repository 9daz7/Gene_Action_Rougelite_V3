extends Node2D


@onready var player_container = $PlayerContainer
@onready var enemy_container = $EnemyContainer
@onready var battle_ui = $BattleUI


func spawn_player(scene):
	var player = scene.instantiate()
	player_container.add_child(player)
	player.position = $PlayerContainer/PlayerSpawn.position
	return player


func spawn_enemy(scene):
	var enemy = scene.instantiate()
	enemy_container.add_child(enemy)
	return enemy
