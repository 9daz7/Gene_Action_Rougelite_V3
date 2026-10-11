extends Node3D


@onready var player: CharacterBody3D = $Player
@onready var deebo: CharacterBody3D = $Deebo
@onready var action_battle_ui: ActionBattleUI = $ActionBattleUI

var run_failed: bool = false


func _ready() -> void:

	action_battle_ui.setup(player, deebo)

	if player.has_signal("died"):
		player.died.connect(_on_required_character_died)

	if deebo.has_signal("died"):
		deebo.died.connect(_on_required_character_died)


func _on_required_character_died() -> void:

	if run_failed:
		return

	run_failed = true
	print("RUN FAILED: Player or Deebo died.")

	_stop_combat()


func _stop_combat() -> void:

	# Stop the player.
	if is_instance_valid(player):
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO

	# Stop Deebo.
	if is_instance_valid(deebo):
		deebo.set_physics_process(false)
		deebo.velocity = Vector3.ZERO

	# Stop enemy controllers.
	for enemy_controller in get_tree().get_nodes_in_group("enemy_controllers_3d"):
		if is_instance_valid(enemy_controller):
			enemy_controller.set_physics_process(false)

	print("Combat stopped.")
