extends Node2D

@onready var player_container = $PlayerContainer
@onready var enemy_container = $EnemyContainer
@onready var battle_ui = $BattleUI

@onready var player_hp = $BattleUI/PlayerHP
@onready var enemy_hp = $BattleUI/EnemyHP


func _ready():
	print("PlayerContainer =", player_container)
	print("EnemyContainer =", enemy_container)
	print("BattleUI =", battle_ui)


# -------------------------------------------------------------------
# HP UI
# -------------------------------------------------------------------

func setup_hp_bars(player, enemy):
	player_hp.set_player(player)
	enemy_hp.set_enemy(enemy)


# -------------------------------------------------------------------
# Spawning
# -------------------------------------------------------------------

func spawn_player(scene):
	print("Spawning player")

	if player_container == null:
		print("ERROR: PlayerContainer missing")
		return null

	var player = scene.instantiate()
	player_container.add_child(player)

	var spawn_point = player_container.get_node("PlayerSpawn")
	player.position = spawn_point.position

	print("Player created:", player)

	return player


func spawn_enemy(scene):
	print("Spawning enemy")

	if enemy_container == null:
		print("ERROR: EnemyContainer missing")
		return null

	var enemy = scene.instantiate()
	enemy_container.add_child(enemy)

	var spawn_point = enemy_container.get_node("EnemySpawn")
	enemy.position = spawn_point.position

	print("Enemy created:", enemy)

	return enemy
