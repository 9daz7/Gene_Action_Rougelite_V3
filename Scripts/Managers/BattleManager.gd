extends Node

signal battle_started
signal battle_finished

@onready var battle_root = $"../../World/BattleRoot"

const PLAYER_SCENE = preload("res://Scenes/Animals/PlayerAnimal.tscn")
const ENEMY_SCENE = preload("res://Scenes/Animals/EnemyAnimal.tscn")

var player
var enemy

func start_battle():

	print("Starting Battle")

	player = PLAYER_SCENE.instantiate()
	enemy = ENEMY_SCENE.instantiate()

	battle_root.add_child(player)
	battle_root.add_child(enemy)

	player.position = Vector2(-250, 0)
	enemy.position = Vector2(250, 0)

	battle_started.emit()
