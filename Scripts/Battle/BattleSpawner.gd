extends Node
class_name BattleSpawner


# ==================================================
# Scene References
# ==================================================

const PLAYER_SCENE = preload("res://Scenes/Animals/PlayerAnimal.tscn")

const ENEMY_SCENE = preload("res://Scenes/Animals/EnemyAnimal.tscn")


# ==================================================
# Dependencies
# ==================================================

var current_battle
var run_manager:RunManager


func initialize(
	battle_scene,
	manager:RunManager
):
	
	current_battle = battle_scene
	run_manager = manager
	
	
# ==================================================
# Player
# ==================================================

func spawn_player():
	
	var player = current_battle.spawn_player(
		PLAYER_SCENE
	)
	
	
	var build = run_manager.current_animal_build
	
	if build:
		player.load_build(build)

	player.setup_player_hp(
		run_manager
	)

	return player
	
	
# ==================================================
# Enemies
# ==================================================

func spawn_enemy(enemy_resource:EnemyResource,index:int):
	
	var enemy = current_battle.spawn_enemy(
		ENEMY_SCENE,
		index
	)
	
	enemy.enemy_data = enemy_resource
	
	return enemy
	
	
func spawn_enemies(resources:Array):

	var enemies:Array = []
	
	for i in resources.size():
		
		var enemy = spawn_enemy(
			resources[i],
			i
		)
		
		enemies.append(enemy)
		
	return enemies
