extends Room3DBase
class_name EliteRoom3D


# ==================================================
# References
# ==================================================

@onready var action_battle_ui: ActionBattleUI = $ActionBattleUI

var combat_controller: ActionCombatController3D = null


# ==================================================
# Battle State
# ==================================================

var remaining_enemies: int = 0
var battle_initialized: bool = false


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	super._ready()

	print("================================")
	print("ELITE ROOM INITIALIZING")
	print("================================")

	if not is_instance_valid(player):
		push_error("EliteRoom3D: Player reference is missing.")
		return

	if not is_instance_valid(deebo):
		push_error("EliteRoom3D: Deebo reference is missing.")
		return

	var party_root := player.get_parent()

	if party_root == null:
		push_error("EliteRoom3D: Player has no party root.")
		return

	combat_controller = party_root.get_node_or_null(
		"ActionCombatController3D"
	) as ActionCombatController3D

	if combat_controller == null:
		push_error(
			"EliteRoom3D: ActionCombatController3D "
			+ "was not found in the party root."
		)
		return

	if not is_instance_valid(action_battle_ui):
		push_error("EliteRoom3D: ActionBattleUI is missing.")
		return

	action_battle_ui.setup(
		player,
		deebo,
		combat_controller
	)

	action_battle_ui.update_move_names()

	_register_enemies()


# ==================================================
# Enemy Registration
# ==================================================

func _register_enemies() -> void:

	var connected_enemies: Array[Node] = []

	for controller in find_children("*", "", true, false):
		if controller.get_script() != preload(
			"res://Scripts/ActionBattle/ActionEnemyController3D.gd"
		):
			continue

		var enemy := controller.get_parent() as CharacterBody3D

		if enemy == null or connected_enemies.has(enemy):
			continue

		if not enemy.has_signal("died"):
			push_warning(
				"EliteRoom3D: Enemy has no died signal: "
				+ enemy.name
			)
			continue

		connected_enemies.append(enemy)

		if not enemy.died.is_connected(_on_enemy_died):
			enemy.died.connect(_on_enemy_died)

	remaining_enemies = connected_enemies.size()

	print("ELITE ENEMIES REGISTERED: ", remaining_enemies)

	if remaining_enemies == 0:
		push_error(
			"EliteRoom3D: No valid enemies found. "
			+ "Check enemy nodes and their controller groups."
		)
		return

	battle_initialized = true

	print("ELITE BATTLE READY")


# ==================================================
# Battle Completion
# ==================================================

func _on_enemy_died() -> void:

	if room_completed or run_failed or not battle_initialized:
		return

	remaining_enemies = maxi(remaining_enemies - 1, 0)

	print("ELITE ENEMIES REMAINING: ", remaining_enemies)

	if remaining_enemies == 0:
		_on_elite_defeated()


func _on_elite_defeated() -> void:

	if room_completed or run_failed:
		return

	print("================================")
	print("ELITE ENCOUNTER DEFEATED")
	print("================================")

	complete_room()
