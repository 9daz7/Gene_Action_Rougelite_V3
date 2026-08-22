extends Node2D
class_name RoomWorld


# ==================================================
# Player
# ==================================================

const ROOM_PLAYER_SCENE = preload(
	"res://Scenes/Rooms/RoomPlayer.tscn"
)

var room_player: RoomPlayer


# ==================================================
# Managers
# ==================================================

@onready var room_manager: RoomManager = get_node(
	"../Managers/RoomManager"
)


# ==================================================
# Room Exits
# ==================================================

var room_exits: Array[RoomExit] = []


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("================================")
	print("ROOM WORLD READY")
	print("Room:", name)
	print("================================")

	_connect_room_exits()
	_spawn_player()


# ==================================================
# Room Exits
# ==================================================


func _connect_room_exits() -> void:

	room_exits.clear()

	for child in get_children():

		if child is RoomExit:

			room_exits.append(child)

			child.set_enabled(false)

			if not child.exit_entered.is_connected(
				_on_room_exit_entered
			):

				child.exit_entered.connect(
					_on_room_exit_entered
				)

			print(
				"Connected RoomExit:",
				child.name,
				"Exit ID:",
				child.exit_id
			)


func _on_room_exit_entered(
	exit_id: int
) -> void:

	print("================================")
	print("ROOM WORLD: EXIT ENTERED")
	print("Exit ID:", exit_id)
	print("================================")

	if room_manager == null:

		push_error(
			"RoomWorld: RoomManager not found."
		)

		return

	room_manager.select_room_exit(
		exit_id
	)


func _disable_room_exits() -> void:

	for room_exit in room_exits:

		if is_instance_valid(room_exit):

			room_exit.set_enabled(false)


func enable_room_exits() -> void:

	print("================================")
	print("ENABLING ROOM EXITS")
	print("Room:", name)
	print("================================")

	for room_exit in room_exits:

		if is_instance_valid(room_exit):

			room_exit.set_enabled(true)

			print(
				"Exit enabled:",
				room_exit.exit_id
			)


# ==================================================
# Player
# ==================================================

func _spawn_player() -> void:

	var spawn_point := get_node_or_null(
		"PlayerSpawn"
	)

	if spawn_point == null:

		push_error(
			"RoomWorld: PlayerSpawn not found in "
			+ name
		)

		return

	room_player = ROOM_PLAYER_SCENE.instantiate()

	if room_player == null:

		push_error(
			"RoomWorld: Failed to instantiate RoomPlayer."
		)

		return

	add_child(room_player)

	room_player.global_position = (
		spawn_point.global_position
	)

	print(
		"RoomPlayer spawned at:",
		room_player.global_position
	)


# ==================================================
# Player Controls
# ==================================================

func set_player_controls(
	enabled: bool
) -> void:

	if room_player == null:

		push_error(
			"RoomWorld: Cannot change controls. "
			+ "RoomPlayer is missing."
		)

		return

	room_player.set_controls_enabled(
		enabled
	)

	print(
		"RoomWorld player controls:",
		enabled
	)


# ==================================================
# Room Completion
# ==================================================

func complete_room() -> void:

	if room_manager == null:

		push_error(
			"RoomWorld: RoomManager not found."
		)

		return

	room_manager.complete_room()
