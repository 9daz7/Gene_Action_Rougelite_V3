extends Node3D
class_name Room3DBase


# ==================================================
# Signals
# ==================================================

signal room_exit_selected(exit_id: int)
signal room_finished


# ==================================================
# Room References
# ==================================================

var player: CharacterBody3D = null
var deebo: CharacterBody3D = null

var room_exits: Array[RoomExit3D] = []


# ==================================================
# Room State
# ==================================================

var run_failed: bool = false
var room_completed: bool = false


# ==================================================
# Initialization
# ==================================================

func configure_party(
	player_ref: CharacterBody3D,
	deebo_ref: CharacterBody3D
) -> void:

	player = player_ref
	deebo = deebo_ref


func _ready() -> void:

	if is_instance_valid(player):
		player.add_to_group("player")

		if player.has_signal("died"):
			if not player.died.is_connected(_on_required_character_died):
				player.died.connect(_on_required_character_died)

	if is_instance_valid(deebo):
		if deebo.has_signal("died"):
			if not deebo.died.is_connected(_on_required_character_died):
				deebo.died.connect(_on_required_character_died)

	_register_room_exits()

	_configure_enemy_references()

	# Initialize health UI after room setup.
	call_deferred("_setup_action_battle_ui")


func _configure_enemy_references() -> void:

	for node in find_children("*", "", true, false):
		if node.get_script() == preload(
			"res://Scripts/ActionBattle/ActionEnemyController3D.gd"
		):
			node.set("player", player)
			node.set("deebo", deebo)


func _setup_action_battle_ui() -> void:

	if not is_instance_valid(player) or not is_instance_valid(deebo):
		push_warning("Room3DBase: Cannot initialize UI; party references are missing.")
		return

	for node in find_children("*", "", true, false):
		if node is ActionBattleUI:
			var action_ui := node as ActionBattleUI
			var controller: ActionCombatController3D = null

			for child in find_children("*", "", true, false):
				if child is ActionCombatController3D:
					controller = child as ActionCombatController3D
					break

			action_ui.setup(player, deebo, controller)
			print("ROOM BASE: ActionBattleUI initialized.")
			return

	print("ROOM BASE: No ActionBattleUI found in this room.")
# ==================================================
# Room Exits
# ==================================================

func _register_room_exits() -> void:

	room_exits.clear()

	for node in find_children("*", "RoomExit3D", true, false):
		if not node is RoomExit3D:
			continue

		var room_exit := node as RoomExit3D

		room_exits.append(room_exit)
		room_exit.set_enabled(false)

		if not room_exit.exit_entered.is_connected(_on_room_exit_entered):
			room_exit.exit_entered.connect(_on_room_exit_entered)

		print(
			"Registered 3D exit: ",
			room_exit.name,
			" | ID: ",
			room_exit.exit_id
		)

	print("Total 3D exits registered: ", room_exits.size())


func _on_room_exit_entered(exit_id: int) -> void:

	if run_failed or not room_completed:
		return

	print("Room exit selected: ", exit_id)
	room_exit_selected.emit(exit_id)


func complete_room() -> void:

	if run_failed or room_completed:
		return

	room_completed = true
	print("ROOM COMPLETED")

	for room_exit in room_exits:
		if is_instance_valid(room_exit):
			room_exit.set_enabled(true)

	room_finished.emit()


# ==================================================
# Run Failure
# ==================================================

func _on_required_character_died() -> void:

	if run_failed:
		return

	run_failed = true
	print("RUN FAILED: Player or Deebo died.")

	_stop_combat()


func _stop_combat() -> void:

	if is_instance_valid(player):
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO

	if is_instance_valid(deebo):
		deebo.set_physics_process(false)
		deebo.velocity = Vector3.ZERO

	# Only stop controllers belonging to this room.
	for node in find_children("*", "", true, false):
		if node.is_in_group("enemy_controllers_3d"):
			node.set_physics_process(false)

	print("Combat stopped.")
