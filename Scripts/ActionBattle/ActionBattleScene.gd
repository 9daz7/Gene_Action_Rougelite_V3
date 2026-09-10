extends Node2D
class_name ActionBattleScene


# ==================================================
# Preloads
# ==================================================

const PLAYER_SCENE_PATH = (
	"res://Scenes/Animals/PlayerAnimal.tscn"
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


# ==================================================
# Lifecycle
# ==================================================

func _ready() -> void:

	print("========================================")
	print("ACTION BATTLE SCENE READY")
	print("========================================")

	print("Arena:", arena)
	print("Player Spawn:", player_spawn.global_position)
	print("Enemy Spawn:", enemy_spawn.global_position)
	print("Enemies Container:", enemies)

	spawn_player()


# ==================================================
# Player Setup
# ==================================================

func spawn_player() -> void:

	var player_scene = load(PLAYER_SCENE_PATH)

	if player_scene == null:
		push_error(
			"Failed to load PlayerAnimal scene: "
			+ PLAYER_SCENE_PATH
		)
		return

	player = player_scene.instantiate()

	if player == null:
		push_error("Failed to instantiate PlayerAnimal.")
		return

	add_child(player)

	player.global_position = player_spawn.global_position

	# --------------------------------------------------
	# Make Deebo visible for the prototype.
	# --------------------------------------------------

	var sprite = player.get_node_or_null("Sprite2D")

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
