extends Node2D
class_name NormalBattleRoom


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
# Battle Trigger
# ==================================================

@onready var battle_trigger: BattleTrigger = $BattleTrigger


# ==================================================
# Room Exits
# ==================================================

@onready var room_exits: Array[RoomExit] = []


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	print("================================")
	print("NORMAL BATTLE ROOM READY")
	print("================================")

	_connect_battle_trigger()
	_connect_room_exits()
	_spawn_player()


# ==================================================
# Battle Trigger
# ==================================================


func _connect_battle_trigger() -> void:

	if battle_trigger == null:

		push_error(
			"NormalBattleRoom: BattleTrigger not found."
		)

		return

	if not battle_trigger.player_entered.is_connected(
		_on_battle_trigger_entered
	):

		battle_trigger.player_entered.connect(
			_on_battle_trigger_entered
	)


func _on_battle_trigger_entered() -> void:

	print("================================")
	print("NORMAL BATTLE ROOM: BATTLE TRIGGERED")
	print("================================")

	if room_manager == null:

		push_error(
			"NormalBattleRoom: RoomManager not found."
		)

		return

	set_player_controls(false)

	room_manager.start_room_battle()


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
				child.exit_id
			)


# ==================================================
# Room Completion
# ==================================================\


func _disable_room_exits() -> void:

	print("================================")
	print("DISABLING ROOM EXITS")
	print("================================")

	for room_exit in room_exits:

		if is_instance_valid(room_exit):

			room_exit.set_enabled(false)

			print(
				"Exit disabled:",
				room_exit.exit_id
			)


func enable_room_exits() -> void:

	print("================================")
	print("ENABLING ROOM EXITS")
	print("================================")

	for room_exit in room_exits:

		if is_instance_valid(room_exit):

			room_exit.set_enabled(true)

			print(
				"Exit enabled:",
				room_exit.exit_id
			)


func _on_room_exit_entered(exit_id: int) -> void:

	print("================================")
	print("NORMAL BATTLE ROOM: EXIT ENTERED")
	print("Exit ID:", exit_id)
	print("================================")

	if room_manager == null:

		push_error(
			"NormalBattleRoom: RoomManager not found."
		)

		return

	room_manager.select_room_exit(
		exit_id
	)


# ==================================================
# Player
# ==================================================


func _spawn_player() -> void:

	room_player = ROOM_PLAYER_SCENE.instantiate()

	if room_player == null:

		push_error(
			"NormalBattleRoom: Failed to instantiate RoomPlayer."
		)

		return

	add_child(room_player)

	room_player.global_position = $PlayerSpawn.global_position

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
			"NormalBattleRoom: Cannot change controls. "
			+ "RoomPlayer is missing."
		)

		return

	room_player.set_controls_enabled(
		enabled
	)

	print(
		"NormalBattleRoom player controls:",
		enabled
	)


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

	set_player_controls(
		not active
	)
	
	#if room_player != null:
#
		#room_player.set_controls_enabled(
			#not active
		#)

	if battle_trigger != null:

		if active:

			battle_trigger.set_process_mode(
				Node.PROCESS_MODE_DISABLED
			)

		else:

			battle_trigger.set_process_mode(
				Node.PROCESS_MODE_INHERIT
			)

	if not active:

		enable_room_exits()
