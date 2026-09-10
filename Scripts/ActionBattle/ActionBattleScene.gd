extends Node2D
class_name ActionBattleScene


# ==================================================
# Preloads
# ==================================================

const PLAYER_SCENE_PATH = (
	"res://Scenes/Animals/PlayerAnimal.tscn"
)

const ENEMY_SCENE_PATH = (
	"res://Scenes/Animals/EnemyAnimal.tscn"
)

const BITE_MOVE_PATH = (
	"res://Data/Moves/Bite.tres"
)

const ACTION_PLAYER_CONTROLLER = preload(
	"res://Scripts/ActionBattle/ActionPlayerController.gd"
)

const ACTION_ENEMY_CONTROLLER = preload(
	"res://Scripts/ActionBattle/ActionEnemyController.gd"
)


# ==================================================
# Scene References
# ==================================================

@onready var arena = $Arena
@onready var player_spawn = $Arena/PlayerSpawn
@onready var enemy_spawn = $Arena/EnemySpawn
@onready var enemies = $Enemies


# ==================================================
# Player
# ==================================================

var player = null
var enemy = null


# ==================================================
# Lifecycle
# ==================================================

func _ready() -> void:

	print("========================================")
	print("ACTION BATTLE SCENE READY")
	print("========================================")

	print("Arena:", arena)
	print(
		"Player Spawn:",
		player_spawn.global_position
	)
	print(
		"Enemy Spawn:",
		enemy_spawn.global_position
	)
	print("Enemies Container:", enemies)

	spawn_player()
	spawn_enemy()


# ==================================================
# Player Setup
# ==================================================

func spawn_player() -> void:

	var player_scene = load(
		PLAYER_SCENE_PATH
	)

	if player_scene == null:

		push_error(
			"Failed to load PlayerAnimal scene: "
			+ PLAYER_SCENE_PATH
		)

		return

	player = player_scene.instantiate()

	if player == null:

		push_error(
			"Failed to instantiate PlayerAnimal."
		)

		return

	add_child(player)

	var controller = ACTION_PLAYER_CONTROLLER.new()

	player.add_child(controller)

	player.global_position = (
		player_spawn.global_position
	)

	if player.has_method("start_battle"):
		player.start_battle()

	# --------------------------------------------------
	# Load prototype player move
	# --------------------------------------------------

	_setup_player_moves()

	# --------------------------------------------------
	# Make Deebo visible for the prototype.
	# --------------------------------------------------

	var sprite = player.get_node_or_null(
		"Sprite2D"
	)

	if sprite != null:

		sprite.visible = true
		sprite.scale = Vector2(0.1, 0.1)

	else:

		push_warning(
			"PlayerAnimal Sprite2D was not found."
		)

	print("========================================")
	print("PLAYER SPAWNED")
	print("========================================")
	print("Player:", player)
	print("Position:", player.global_position)


# ==================================================
# Player Move Setup
# ==================================================

func _setup_player_moves() -> void:

	var bite_move = load(
		BITE_MOVE_PATH
	)

	if bite_move == null:

		push_error(
			"Failed to load Bite move: "
			+ BITE_MOVE_PATH
		)

		return

	if not player.has_method("add_move"):

		push_error(
			"PlayerAnimal does not have add_move()."
		)

		return

	player.add_move(bite_move)

	print("========================================")
	print("PLAYER MOVE SETUP")
	print("========================================")
	print("Loaded move:", bite_move.move_name)

	if player.has_method("get_battle_moves"):

		var moves = player.get_battle_moves()

		print(
			"Player battle moves:",
			moves.size()
		)

		for move in moves:

			if move == null:
				continue

			print(
				" - ",
				move.move_name
			)


# ==================================================
# Enemy Setup
# ==================================================

func spawn_enemy() -> void:

	var enemy_scene = load(
		ENEMY_SCENE_PATH
	)

	if enemy_scene == null:

		push_error(
			"Failed to load EnemyAnimal scene: "
			+ ENEMY_SCENE_PATH
		)

		return

	enemy = enemy_scene.instantiate()

	if enemy == null:

		push_error(
			"Failed to instantiate EnemyAnimal."
		)

		return

	enemies.add_child(enemy)

	var controller = ACTION_ENEMY_CONTROLLER.new()

	enemy.add_child(controller)

	controller.target = player

	enemy.global_position = (
		enemy_spawn.global_position
	)

	# --------------------------------------------------
	# Initialize Wolf
	# --------------------------------------------------

	var wolf_resource = load(
		"res://Data/Enemies/Normal/Wolf.tres"
	)

	if wolf_resource != null:

		enemy.enemy_data = wolf_resource

		if enemy.has_method("start_battle"):
			enemy.start_battle()

	else:

		push_error(
			"Failed to load Wolf.tres."
		)

	# --------------------------------------------------
	# Make sure the Wolf sprite is visible.
	# --------------------------------------------------

	var sprite = enemy.get_node_or_null(
		"EnemySprite"
	)

	if sprite != null:

		sprite.visible = true

	print("========================================")
	print("WOLF SPAWNED")
	print("========================================")
	print("Enemy:", enemy)
	print("Position:", enemy.global_position)
