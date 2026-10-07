extends RoomWorld
class_name NormalBattleRoom


# ==================================================
# Action Player
# ==================================================

const ACTION_PLAYER_CHARACTER_SCENE = preload(
	"res://Scenes/Battle/ActionPlayerCharacter.tscn"
)

const PLAYER_ANIMAL_SCENE = preload(
	"res://Scenes/Animals/PlayerAnimal.tscn"
)

const ENEMY_ANIMAL_SCENE = preload(
	"res://Scenes/Animals/EnemyAnimal.tscn"
)

@onready var run_manager: RunManager = get_node(
	"/root/Main/Managers/RunManager"
)

var action_player_character: ActionPlayerCharacter = null
var deebo: PlayerAnimal = null
var action_combat_controller: ActionCombatController = null
var active_combat_enemy: EnemyAnimal = null
var action_battle_ui: ActionBattleUI = null


# ==================================================
# Roaming Enemies
# ==================================================

# Roaming Enemies
var roaming_enemies: Array[RoamingEnemy] = []

# Battle State
var battle_active: bool = false
var active_roaming_enemy: RoamingEnemy = null


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	super._ready()

	print("================================")
	print("NORMAL BATTLE ROOM READY")
	print("================================")

	_connect_roaming_enemies()
	_setup_action_player()


# ==================================================
# Action Player Setup
# ==================================================

func _setup_action_player() -> void:

	var spawn_point := get_node_or_null("PlayerSpawn")

	if spawn_point == null:

		push_error(
			"NormalBattleRoom: PlayerSpawn not found."
		)

		return

	# --------------------------------------------------
	# Human Player
	# --------------------------------------------------

	action_player_character = (
		ACTION_PLAYER_CHARACTER_SCENE.instantiate()
	)

	if action_player_character == null:

		push_error(
			"NormalBattleRoom: Failed to create "
			+ "ActionPlayerCharacter."
		)

		return

	add_child(action_player_character)

	action_player_character.global_position = (
		spawn_point.global_position
	)

	# --------------------------------------------------
	# Deebo
	# --------------------------------------------------

	deebo = PLAYER_ANIMAL_SCENE.instantiate()

	if deebo == null:

		push_error(
			"NormalBattleRoom: Failed to create PlayerAnimal."
		)

		return

	add_child(deebo)

	deebo.global_position = (
		action_player_character.global_position
		+ Vector2(-60.0, 0.0)
	)

	deebo.initialize_player(
		run_manager
	)

	deebo.start_battle()

	# --------------------------------------------------
	# Controllers
	# --------------------------------------------------

	var deebo_controller := ActionPlayerController.new()

	if deebo_controller == null:

		push_error(
			"NormalBattleRoom: Failed to create "
			+ "ActionPlayerController."
		)

		return

	deebo_controller.name = "ActionPlayerController"

	deebo.add_child(
		deebo_controller
	)

	var player_controller := (
		action_player_character.get_node_or_null(
			"ActionPlayerCharacterController"
		)
	)

	var player_combat := (
		action_player_character.get_node_or_null(
			"ActionPlayerCombatController"
		)
	)

	if player_controller == null:

		push_error(
			"NormalBattleRoom: "
			+ "ActionPlayerCharacterController "
			+ "not found."
		)

		return

	if player_combat == null:

		push_error(
			"NormalBattleRoom: "
			+ "ActionPlayerCombatController "
			+ "not found."
		)

		return

	# --------------------------------------------------
	# Combat Controller
	# --------------------------------------------------

	action_combat_controller = (
		ActionCombatController.new()
	)

	add_child(action_combat_controller)

	action_combat_controller.setup(
		action_player_character,
		deebo
	)

	action_combat_controller.set_player_combat_controller(
		player_combat
	)

	deebo_controller.set_player_character(
		action_player_character
	)

	deebo_controller.set_combat_controller(
		action_combat_controller
	)

	player_controller.set_deebo_controller(
		deebo_controller
	)

	player_controller.set_player_combat_controller(
		player_combat
	)

	player_combat.set_combat_controller(
		action_combat_controller
	)

	# ==================================================
	# Action Battle UI
	# ==================================================

	action_battle_ui = get_node_or_null(
		"/root/Main/UI/ActionBattleUI"
	) as ActionBattleUI

	if action_battle_ui == null:
		push_error("NormalBattleRoom: Persistent ActionBattleUI not found.")
		return

	action_battle_ui.setup(
		deebo,
		action_player_character,
		deebo_controller
	)

	action_battle_ui.visible = true

	print("================================")
	print("NORMAL BATTLE ROOM ACTION PLAYER READY")
	print("================================")


func _connect_roaming_enemies() -> void:

	roaming_enemies.clear()

	var enemies := find_children(
		"*",
		"RoamingEnemy",
		true,
		false
	)

	for enemy in enemies:

		if not enemy is RoamingEnemy:
			continue

		roaming_enemies.append(
			enemy
		)

		if not enemy.encounter_requested.is_connected(
			_on_roaming_enemy_encounter
		):

			enemy.encounter_requested.connect(
				_on_roaming_enemy_encounter
			)

	print(
		"Roaming enemies found:",
		roaming_enemies.size()
	)


func _on_roaming_enemy_encounter(
	enemy: RoamingEnemy
) -> void:

	if enemy == null:
		return

	if battle_active:
		return

	if enemy.enemy_data == null:

		push_error(
			"NormalBattleRoom: Roaming enemy has no EnemyResource."
		)

		return

	print("================================")
	print("NORMAL BATTLE ROOM: ROAMING ENCOUNTER")
	print("Enemy:", enemy.name)
	print("================================")

	_start_room_battle(enemy)


func _start_room_battle(
	enemy: RoamingEnemy
) -> void:

	battle_active = true

	print("================================")
	print("ROOM BATTLE START")
	print("Enemy:", enemy.name)
	print("Enemy Resource:", enemy.enemy_data.enemy_name)
	print("================================")

	# --------------------------------------------------
	# Create Combat Enemy
	# --------------------------------------------------

	active_combat_enemy = ENEMY_ANIMAL_SCENE.instantiate()

	if active_combat_enemy == null:

		push_error(
			"NormalBattleRoom: Failed to create EnemyAnimal."
		)

		return

	var enemies_container := get_node_or_null("Enemies")

	if enemies_container == null:

		push_error(
			"NormalBattleRoom: Enemies container not found."
		)

		active_combat_enemy.queue_free()
		active_combat_enemy = null

		return

	enemies_container.add_child(
		active_combat_enemy
	)

	# --------------------------------------------------
	# Copy Encounter Data
	# --------------------------------------------------

	active_combat_enemy.enemy_data = enemy.enemy_data

	active_combat_enemy.global_position = (
		enemy.global_position
	)

	# --------------------------------------------------
	# Add Action Enemy Controller
	# --------------------------------------------------

	var enemy_controller := ActionEnemyController.new()

	enemy_controller.name = "ActionEnemyController"

	active_combat_enemy.add_child(
		enemy_controller
	)

	enemy_controller.target = deebo

	enemy_controller.set_combat_controller(
		action_combat_controller
	)

	# --------------------------------------------------
	# Initialize Combat Enemy
	# --------------------------------------------------

	active_combat_enemy.start_battle()

	if not active_combat_enemy.animal_died.is_connected(
		_on_combat_enemy_died
	):

		active_combat_enemy.animal_died.connect(
			_on_combat_enemy_died
		)

	# --------------------------------------------------
	# Remove Roaming Enemy
	# --------------------------------------------------

	roaming_enemies.erase(enemy)

	enemy.queue_free()

	# --------------------------------------------------
	# Activate Battle
	# --------------------------------------------------

	set_battle_active(true)


# ==================================================
# Battle State
# ==================================================

func set_battle_active(
	active: bool
) -> void:

	print(
		"NormalBattleRoom battle active:",
		active
	)

	if active:
		_disable_room_exits()
	else:
		enable_room_exits()


func _on_combat_enemy_died() -> void:

	print("================================")
	print("ROOM BATTLE WON")
	print("================================")

	battle_active = false

	active_combat_enemy = null

	set_battle_active(false)
