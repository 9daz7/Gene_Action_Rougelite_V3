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
# Initialization
# ==================================================


func _ready() -> void:

	print("================================")
	print("NORMAL BATTLE ROOM READY")
	print("================================")

	_connect_battle_trigger()
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

	# --------------------------------------------------
	# Disable room controls immediately
	# --------------------------------------------------

	if room_player != null:

		room_player.set_controls_enabled(false)

	# --------------------------------------------------
	# Disable the trigger
	# --------------------------------------------------

	if battle_trigger != null:

		battle_trigger.set_process_mode(
			Node.PROCESS_MODE_DISABLED
		)

	# --------------------------------------------------
	# Start battle
	# --------------------------------------------------

	room_manager.start_room_battle()


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
# Battle State
# ==================================================


func set_battle_active(
	active: bool
) -> void:

	print(
		"NormalBattleRoom battle active:",
		active
	)

	if room_player != null:

		room_player.set_controls_enabled(
			not active
		)

	if battle_trigger != null:

		if active:

			battle_trigger.set_process_mode(
				Node.PROCESS_MODE_DISABLED
			)

		else:

			battle_trigger.set_process_mode(
				Node.PROCESS_MODE_INHERIT
			)
