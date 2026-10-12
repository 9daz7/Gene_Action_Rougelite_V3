extends Node3D


@onready var player: CharacterBody3D = $Player
@onready var deebo: CharacterBody3D = $Deebo
@onready var action_battle_ui: ActionBattleUI = $ActionBattleUI
@onready var combat_controller: ActionCombatController3D = $ActionCombatController3D
@onready var room_exit: RoomExit3D = $RoomExit3D

var run_failed: bool = false
var room_completed: bool = false
var remaining_enemies: int = 0


func _ready() -> void:

	action_battle_ui.setup(player, deebo, combat_controller)
	action_battle_ui.update_move_names()

	room_exit.set_enabled(false)

	if not room_exit.exit_entered.is_connected(_on_room_exit_entered):
		room_exit.exit_entered.connect(_on_room_exit_entered)

	_register_enemies()

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


func _register_enemies() -> void:

	var enemies := get_tree().get_nodes_in_group("enemies_3d")
	var connected_enemies: Array[Node] = []

	for controller in enemies:
		if not is_instance_valid(controller):
			continue

		var enemy := controller.get_parent() as CharacterBody3D

		if enemy == null or connected_enemies.has(enemy):
			continue

		connected_enemies.append(enemy)

		if enemy.has_signal("died"):
			if not enemy.died.is_connected(_on_enemy_died):
				enemy.died.connect(_on_enemy_died)

	remaining_enemies = connected_enemies.size()
	print("Enemies registered: ", remaining_enemies)


func _on_enemy_died() -> void:

	if room_completed:
		return

	remaining_enemies = maxi(remaining_enemies - 1, 0)

	print("Enemies remaining: ", remaining_enemies)

	if remaining_enemies == 0:
		room_completed = true
		print("ROOM COMPLETED!")
		room_exit.set_enabled(true)


func _on_room_exit_entered(exit_id: int) -> void:

	if not room_completed:
		return

	print("Room exit selected: ", exit_id)


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
