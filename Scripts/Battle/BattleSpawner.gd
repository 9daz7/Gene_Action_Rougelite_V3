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
	
	if current_battle == null:
		push_error("BattleSpawner received no BattleScene")

	if run_manager == null:
		push_error("BattleSpawner received no RunManager")
		
	
# ==================================================
# Player
# ==================================================

func spawn_player() -> PlayerAnimal:
	
	if current_battle == null:
		push_error("Cannot spawn player. No battle scene.")
		return null
		
	var player = current_battle.spawn_player(
		PLAYER_SCENE
	)
	
	if run_manager == null:
		push_error("No RunManager available")
		return null
	
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

func spawn_enemy(
	enemy_resource: EnemyResource,
	index:int
) -> EnemyAnimal:
	
	if enemy_resource == null:
		push_error(
			"Cannot spawn enemy. Resource missing."
		)
		return null
	
	var enemy = current_battle.spawn_enemy(
		ENEMY_SCENE,
		index
	)
	
	if enemy == null:
		push_error(
			"BattleScene failed to spawn enemy"
		)
		return null
	
	enemy.enemy_data = enemy_resource
	
	return enemy
	
	
func spawn_enemies(resources:Array):

	var enemies:Array[EnemyAnimal] = []
	
	var max_enemies = min(
		resources.size(),
		3
	)
	
	for i in range(max_enemies):
		
		var enemy = spawn_enemy(
			resources[i],
			i
		)
		
		if enemy:
			enemies.append(enemy)
		
	return enemies
	
	
#temp
func get_enemy_position(index:int) -> Vector2:

	match index:

		0:
			return Vector2(250, 0)
		1:
			return Vector2(350, -50)
		2:
			return Vector2(350, 50)

	return Vector2.ZERO
