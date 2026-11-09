extends Room3DBase
class_name BossRoom3D


# ==================================================
# Boss State
# ==================================================

var boss: CharacterBody3D = null
var boss_controller: Node = null
var boss_reward_data: EnemyResource = null

var boss_initialized: bool = false
var reward_requested_once: bool = false


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	super._ready()

	_register_boss()


func _register_boss() -> void:

	for node in find_children("*", "", true, false):

		if node.get_script() != preload(
			"res://Scripts/ActionBattle/ActionEnemyController3D.gd"
		):
			continue

		var enemy_controller := node as Node
		var enemy := enemy_controller.get_parent() as CharacterBody3D

		if enemy == null:
			continue

		if not enemy.has_signal("died"):
			continue

		boss = enemy
		boss_controller = enemy_controller
		boss_reward_data = enemy.get("enemy_data") as EnemyResource

		if boss_reward_data == null:
			push_error("BossRoom3D: Boss has no EnemyResource assigned.")
			continue

		if not boss.died.is_connected(_on_boss_died):
			boss.died.connect(_on_boss_died)

		boss_initialized = true

		print("================================")
		print("BOSS REGISTERED: ", boss_reward_data.enemy_name)
		print("Player reference: ", is_instance_valid(player))
		print("Deebo reference: ", is_instance_valid(deebo))
		print("================================")

		return

	push_error("BossRoom3D: No valid boss enemy found.")


# ==================================================
# Boss Defeated
# ==================================================

func _on_boss_died() -> void:

	if reward_requested_once or run_failed:
		return

	reward_requested_once = true

	print("================================")
	print("BOSS DEFEATED")
	print("REQUESTING BOSS REWARD")
	print("Boss: ", boss_reward_data.enemy_name)
	print("================================")

	if is_instance_valid(boss_controller):
		boss_controller.set_physics_process(false)

	reward_requested.emit(boss_reward_data)
