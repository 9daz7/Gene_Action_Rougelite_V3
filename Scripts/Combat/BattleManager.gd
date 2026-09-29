extends Node
class_name BattleManager


# ==================================================
# Enemy Pools
# ==================================================


const ENEMY_POOL = [
	#preload("res://Data/Enemies/Normal/Wolf.tres"),
	#preload("res://Data/Enemies/Normal/Boar.tres"),
	preload("res://Data/Enemies/Normal/Marten.tres"),
	preload("res://Data/Enemies/Normal/Cheetah.tres"),
	#preload("res://Data/Enemies/Normal/SnappingTurtle.tres"),
	#preload("res://Data/Enemies/Normal/HoneyBadger.tres"),
	preload("res://Data/Enemies/Normal/Rattlesnake.tres")
]

const ELITE_POOL = [
	#preload("res://Data/Enemies/Elite/AlphaWolf.tres"),
	#preload("res://Data/Enemies/Elite/AlphaBoar.tres"),
	#preload("res://Data/Enemies/Elite/GiantMarten.tres")
	preload("res://Data/Enemies/Normal/Wolf.tres"),
	preload("res://Data/Enemies/Normal/Boar.tres"),
	preload("res://Data/Enemies/Normal/Marten.tres"),
	preload("res://Data/Enemies/Normal/Cheetah.tres"),
	preload("res://Data/Enemies/Normal/SnappingTurtle.tres"),
	preload("res://Data/Enemies/Normal/HoneyBadger.tres"),
]

const BOSS_POOL = [
	preload("res://Data/Enemies/Boss/ModifiedWolf.tres")
]

const CRITICAL_LAB_POOL = [
	preload("res://Data/Enemies/Labs/MutatedEnemy.tres")
]


# ==================================================
# Dependencies
# ==================================================

# temp
var battle_number := 0 


# ==================================================
# Battle State
# ==================================================


var current_battle: Node = null
var player: PlayerAnimal
var enemies: Array[EnemyAnimal] = []

var current_battle_type = null
var critical_experiment := false

var roaming_battle: bool = false


# ==================================================
# Enemy Selection
# ==================================================

func get_enemy(
	room_type
) -> EnemyResource:

	var pool = []

	# ==================================================
	# Critical Lab
	# ==================================================

	if critical_experiment:

		pool = CRITICAL_LAB_POOL

	else:

		match room_type:

			RoomData.RoomType.ENEMY:
				pool = ENEMY_POOL

			RoomData.RoomType.GROUP_ENEMY:
				pool = ENEMY_POOL

			RoomData.RoomType.ELITE:
				pool = ELITE_POOL

			RoomData.RoomType.BOSS:
				pool = BOSS_POOL

			_:
				push_error(
					"BattleManager: Unknown room type: "
					+ str(room_type)
				)

	if pool.is_empty():

		push_error(
			"BattleManager: Enemy pool is empty."
		)

		return null

	var choices = pool.duplicate()

	choices.shuffle()

	return choices[0]


func get_enemy_count(
	room_type
) -> int:

	# Critical Labs always contain exactly one enemy.
	if critical_experiment:

		return 1

	match room_type:

		RoomData.RoomType.ENEMY:

			return 1

		RoomData.RoomType.GROUP_ENEMY:

			return 3

		RoomData.RoomType.ELITE:

			return 2

		RoomData.RoomType.BOSS:

			return 1

	return 1


func reset_battle_state():
	current_battle_type = null
	critical_experiment = false

	print("==============================")
	print("BATTLE STATE RESET")
	print("critical flag:", critical_experiment)
	print("battle type:", current_battle_type)
	print("==============================")
