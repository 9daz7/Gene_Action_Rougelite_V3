extends Node2D

@onready var player_container = $PlayerContainer
@onready var enemy_container = $EnemyContainer
@onready var battle_ui = $BattleUI
#@onready var target_selection_ui = $TargetSelectionUI

@onready var player_hp = $BattleUI/PlayerPanel/PlayerHP
#@onready var enemy_hp = $BattleUI/EnemyPanel/EnemyHP # old hp bars


func _ready():
	print("PlayerContainer =", player_container)
	print("EnemyContainer =", enemy_container)
	print("BattleUI =", battle_ui)

	print("Enemy children:")

	for child in enemy_container.get_children():
		print("Enemy child", child.name)


# -------------------------------------------------------------------
# HP UI
# -------------------------------------------------------------------

# old hp bars
#func setup_hp_bars(player, enemies):
	#player_hp.set_player(player)
#
	#if enemies.size() > 0:
		#enemy_hp.set_enemy(
			#enemies[0]
		#)
func setup_hp_bars(player, enemies):

	player_hp.set_player(player)
	

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


func spawn_enemy(scene, spawn_index:int = 0):
	
	print("Spawning enemy")

	if enemy_container == null:
		print("ERROR: EnemyContainer missing")
		return null

	var enemy = scene.instantiate()
	
	enemy_container.add_child(enemy)

	var spawn_point = null #= enemy_container.get_node("EnemySpawn1")
	
	match spawn_index:
		0:
			spawn_point = enemy_container.get_node_or_null(
				"EnemySpawn1"
			)
		1:
			spawn_point = enemy_container.get_node_or_null(
				"EnemySpawn2"
			)
		2:
			spawn_point = enemy_container.get_node_or_null(
				"EnemySpawn3"
			)
			
	if spawn_point == null:
		push_error(
			"Enemy spawn point missing for index: ",
			spawn_index
		)
		enemy.queue_free()
		return null
		
	enemy.position = spawn_point.position

	print(
		"Enemy created:",
		enemy
	)

	return enemy


#func show_target_selection(
	#enemies:Array[EnemyAnimal]
#):
#
	#target_selection_ui.open(
		#enemies
	#)
