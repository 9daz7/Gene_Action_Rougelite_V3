extends Node2D


@onready var player_container = $PlayerContainer
@onready var enemy_container = $EnemyContainer
@onready var battle_ui = $BattleUI

@onready var player_hp = $BattleUI/PlayerHP
@onready var enemy_hp = $BattleUI/EnemyHP

func setup_hp_bars(player, enemy):
	
	player_hp.set_player(player)
	enemy_hp.set_enemy(enemy)
	
func spawn_player(scene):
	var player = scene.instantiate()
	player_container.add_child(player)
	player.position = $PlayerContainer/PlayerSpawn.position
	return player


func spawn_enemy(scene):
	var enemy = scene.instantiate()
	enemy_container.add_child(enemy)
	return enemy
