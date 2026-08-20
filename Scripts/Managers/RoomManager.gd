extends Node
class_name RoomManager


# ==================================================
# Managers
# ==================================================


@onready var battle_manager = $"../BattleManager"
@onready var run_manager = $"../RunManager"
@onready var save_manager = $"../SaveManager"

# --------------------------------------------------
# Temporary Map Dependency
# --------------------------------------------------
@onready var map_manager = $"../MapManager"

# ==================================================
# UI
# ==================================================


@onready var ui = $"../../UI"
@onready var map_ui = $"../../UI/MapUI"


# ==================================================
# Room Scenes
# ==================================================


const TREASURE_SCENE = preload("res://Scenes/Rooms/TreasureRoom.tscn")
const MERCHANT_SCENE = preload("res://Scenes/Rooms/MerchantRoom.tscn")
const REST_SCENE = preload("res://Scenes/Rooms/RestRoom.tscn")
const ABANDONED_LAB_SCENE = preload("res://Scenes/Rooms/AbandonedLab.tscn")
const MYSTERY_SCENE = preload("res://Scenes/Rooms/MysteryRoom.tscn")
const REWARD_SCENE = preload("res://Scenes/Rooms/RewardRoom.tscn")


# ==================================================
# Room State
# ==================================================


var current_room: RoomResource = null
var active_room_scene: Node = null

# --------------------------------------------------
# temporary Map System
# --------------------------------------------------

var active_map_room: RoomData = null


# ==================================================
# Active Room Scenes
# ==================================================

var reward_room = null

var treasure_room = null
var merchant_room = null
var rest_room = null
var abandoned_lab = null
var mystery_room = null

# --------------------------------------------------
# Active Battle Room
# --------------------------------------------------

var active_battle_room: NormalBattleRoom = null


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	if not GameEvents.battle_finished.is_connected(
		_on_battle_finished
	):

		GameEvents.battle_finished.connect(
			_on_battle_finished
	)


# ==================================================
# Room System
# ==================================================


# --------------------------------------------------
# Create Room
# --------------------------------------------------

func create_room(
	room_type: RoomResource.RoomType,
	room_name: String = "",
	description: String = ""
) -> RoomResource:

	var room := RoomResource.new()

	room.room_type = room_type

	if room_name.is_empty():
		room.room_name = get_room_type_name(room_type)
	else:
		room.room_name = room_name

	room.description = description
	room.completed = false

	print(
		"ROOM CREATED:",
		room.room_name,
		" Type:",
		room.room_type
	)

	return room

# --------------------------------------------------
# Temporary RoomResource Test
# --------------------------------------------------

func test_room_resource_battle() -> void:

	var room: RoomResource = load(
		"res://Data/Rooms/NormalBattle.tres"
	)

	if room == null:

		push_error(
			"RoomManager: Failed to load NormalBattle.tres."
		)

		return

	room.completed = false

	print("================================")
	print("ROOM RESOURCE TEST")
	print("Loaded:", room.room_name)
	print("Type:", room.room_type)
	print("================================")

	start_room(room)
	
# --------------------------------------------------
# Start Room
# --------------------------------------------------

func start_room(room: RoomResource) -> void:

	if room == null:
		push_error(
			"RoomManager: Cannot start null RoomResource."
		)
		return

	if room.completed:
		push_error(
			"RoomManager: Cannot start completed room: "
			+ room.room_name
		)
		return

	current_room = room

	print("================================")
	print("ROOM MANAGER: START ROOM")
	print("Room:", room.room_name)
	print("Type:", room.room_type)
	print("================================")

	match room.room_type:

		RoomResource.RoomType.BATTLE:
			open_room_scene(room)

		RoomResource.RoomType.ELITE:
			start_new_elite_room(room)

		RoomResource.RoomType.REWARD:
			print("Reward room selected.")

		RoomResource.RoomType.SHOP:
			print("Shop room selected.")

		RoomResource.RoomType.EVENT:
			print("Event room selected.")

		RoomResource.RoomType.BOSS:
			start_new_boss_room(room)

		_:
			push_error(
				"RoomManager: Unknown RoomResource type."
			)


# ==================================================
# Room Scene
# ==================================================

func open_room_scene(room: RoomResource) -> void:

	if room == null:
		push_error(
			"RoomManager: Cannot open null RoomResource."
		)
		return

	if room.room_scene == null:
		push_error(
			"RoomManager: Room has no assigned scene: "
			+ room.room_name
		)
		return

	# --------------------------------------------------
	# Clean Up Previous Room
	# --------------------------------------------------

	if is_instance_valid(active_room_scene):

		active_room_scene.queue_free()

		active_room_scene = null

	# --------------------------------------------------
	# Create Room
	# --------------------------------------------------

	active_room_scene = room.room_scene.instantiate()

	if active_room_scene == null:

		push_error(
			"RoomManager: Failed to instantiate room scene: "
			+ room.room_name
		)

		return

	get_tree().current_scene.add_child(
		active_room_scene
	)

	# --------------------------------------------------
	# Track Active Battle Room
	# --------------------------------------------------

	if active_room_scene is NormalBattleRoom:

		active_battle_room = active_room_scene

	else:

		active_battle_room = null

	print("================================")
	print("ROOM SCENE OPENED")
	print("Room:", room.room_name)
	print("Scene:", active_room_scene.name)
	print("================================")

	if active_battle_room != null:

		print(
			"Active battle room:",
			active_battle_room.name
		)


# --------------------------------------------------
# Complete Room
# --------------------------------------------------

func complete_room() -> void:

	if current_room == null:
		push_error(
			"RoomManager: No active RoomResource to complete."
		)
		return

	if current_room.completed:
		print(
			"RoomManager: Room already completed:",
			current_room.room_name
		)
		return

	current_room.completed = true

	print(
		"ROOM COMPLETED:",
		current_room.room_name
	)

	GameEvents.room_completed.emit(
		current_room
	)


# --------------------------------------------------
# Advance Room
# --------------------------------------------------

func advance_room() -> void:

	print("================================")
	print("ROOM MANAGER: ADVANCING ROOM")
	print("================================")

	if current_room != null:

		if not current_room.completed:

			print(
				"Current room not completed:",
				current_room.room_name
			)

			return

	print("Ready to create/select next room.")

	# --------------------------------------------------
	# temp
	# --------------------------------------------------

	current_room = null

# --------------------------------------------------
# Room Type Name
# --------------------------------------------------

func get_room_type_name(
	room_type: RoomResource.RoomType
) -> String:

	match room_type:

		RoomResource.RoomType.BATTLE:
			return "Battle"

		RoomResource.RoomType.ELITE:
			return "Elite"

		RoomResource.RoomType.REWARD:
			return "Reward"

		RoomResource.RoomType.SHOP:
			return "Shop"

		RoomResource.RoomType.EVENT:
			return "Event"

		RoomResource.RoomType.BOSS:
			return "Boss"

		_:
			return "Unknown"


# ==================================================
# Battle Rooms
# ==================================================

func start_new_battle_room(room: RoomResource) -> void:

	print(
		"Starting RoomResource battle room:"
	)

	print(
		room.room_name
	)

	open_room_scene(room)


func start_new_elite_room(room: RoomResource) -> void:

	print(
		"Starting new RoomResource elite battle:"
	)

	print(
		room.room_name
	)

	open_room_scene(room)


func start_new_boss_room(room: RoomResource) -> void:

	print(
		"Starting new RoomResource boss battle:"
	)

	print(
		room.room_name
	)

	open_room_scene(room)


# ==================================================
# Room Encounters
# ==================================================

func start_room_battle() -> void:

	if current_room == null:

		push_error(
			"RoomManager: Cannot start battle without current room."
		)

		return

	if battle_manager == null:

		push_error(
			"RoomManager: BattleManager is missing."
		)

		return

	print("================================")
	print("ROOM MANAGER: STARTING ROOM BATTLE")
	print("Room:", current_room.room_name)
	print("================================")

	# --------------------------------------------------
	# Lock current room
	# --------------------------------------------------

	if active_room_scene != null:

		if active_room_scene.has_method(
			"set_battle_active"
		):

			active_room_scene.set_battle_active(
				true
			)

	# --------------------------------------------------
	# Start battle
	# --------------------------------------------------

	battle_manager.start_battle(
		RoomData.RoomType.ENEMY
	)


# ==================================================
# Legacy Map Room Compatibility (temp)
# ==================================================

func enter_room(room: RoomData) -> void:

	if room == null:

		push_error(
			"RoomManager: Cannot enter null RoomData."
		)

		return

	active_map_room = room

	print(
		"ROOM MANAGER ENTERED:",
		room.room_type,
		" ID:",
		room.room_id
	)

	match room.room_type:

		RoomData.RoomType.ENEMY:
			start_enemy(room)

		RoomData.RoomType.ELITE:
			start_elite(room)

		RoomData.RoomType.GROUP_ENEMY:
			start_group_enemy(room)

		RoomData.RoomType.BOSS:
			start_boss(room)

		RoomData.RoomType.TREASURE:
			open_treasure(room)

		RoomData.RoomType.MERCHANT:
			open_shop(room)

		RoomData.RoomType.REST:
			open_rest(room)

		RoomData.RoomType.ABANDONED_LAB:
			open_lab(room)

		RoomData.RoomType.MYSTERY_ROOM:
			open_mystery(room)

		_:
			print("Unknown legacy room type.")


# ==================================================
# Legacy Battle Rooms (temp)
# ==================================================

func start_enemy(room: RoomData) -> void:

	print("Starting normal battle")

	battle_manager.start_battle(
		RoomData.RoomType.ENEMY
	)


func start_group_enemy(room: RoomData) -> void:

	print("Starting group battle")

	battle_manager.start_battle(
		RoomData.RoomType.GROUP_ENEMY
	)


func start_elite(room: RoomData) -> void:

	print("Starting elite battle")

	battle_manager.start_battle(
		RoomData.RoomType.ELITE
	)


func start_boss(room: RoomData) -> void:

	print("Starting boss")

	battle_manager.start_battle(
		RoomData.RoomType.BOSS
	)

# ==================================================
# Special Rooms
# ==================================================

func open_shop(room: RoomData) -> void:

	print("Opening merchant")

	merchant_room = MERCHANT_SCENE.instantiate()

	get_tree().current_scene.add_child(
		merchant_room
	)

	merchant_room.merchant_finished.connect(
		_on_merchant_finished
	)

	merchant_room.open(
		run_manager
	)


func open_treasure(room: RoomData) -> void:

	print("Opening treasure")

	treasure_room = TREASURE_SCENE.instantiate()

	get_tree().current_scene.add_child(
		treasure_room
	)

	treasure_room.treasure_finished.connect(
		_on_treasure_finished
	)

	treasure_room.open(
		run_manager
	)


func open_rest(room: RoomData) -> void:

	print("Opening rest room")

	rest_room = REST_SCENE.instantiate()

	get_tree().current_scene.add_child(
		rest_room
	)

	rest_room.rest_finished.connect(
		_on_rest_finished
	)

	rest_room.open(
		run_manager
	)


func open_lab(room: RoomData) -> void:

	print("Opening abandoned lab")

	if room.lab_data == null:

		print(
			"ERROR: Lab room has no LabResource"
		)

		return

	abandoned_lab = ABANDONED_LAB_SCENE.instantiate()

	get_tree().current_scene.add_child(
		abandoned_lab
	)

	abandoned_lab.open(
		room.lab_data,
		battle_manager
	)

	if not abandoned_lab.lab_finished.is_connected(
		_on_lab_finished
	):

		abandoned_lab.lab_finished.connect(
			_on_lab_finished
		)


func open_mystery(room: RoomData) -> void:

	print("Opening a mystery room")

	mystery_room = MYSTERY_SCENE.instantiate()

	get_tree().current_scene.add_child(
		mystery_room
	)

	mystery_room.mystery_finished.connect(
		_on_mystery_finished
	)

	mystery_room.open()


# ==================================================
# Reward Room
# ==================================================

func open_reward(rewards) -> void:

	print("================================")
	print("ROOM MANAGER: OPENING REWARD")
	print("================================")

	#map_ui.hide()

	print(
		"Rewards object:",
		rewards
	)

	reward_room = REWARD_SCENE.instantiate()

	if reward_room == null:

		push_error(
			"RoomManager: Failed to instantiate RewardRoom."
		)

		return

	ui.add_child(
		reward_room
	)

	reward_room.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	if not reward_room.reward_finished.is_connected(
		_on_reward_finished
	):

		reward_room.reward_finished.connect(
			_on_reward_finished
		)

	reward_room.open(
		rewards
	)


# ==================================================
# Reward Handling
# ==================================================

func _on_reward_finished(reward) -> void:

	print("================================")
	print("ROOM MANAGER: REWARD FINISHED")
	print("================================")

	if reward:

		print(
			"Chosen:",
			reward
		)

	else:

		print("Skipped reward")

	# ==================================================
	# Apply Reward
	# ==================================================

	if reward:

		apply_reward(
			reward
		)

	# ==================================================
	# Close Reward Room
	# ==================================================

	if is_instance_valid(reward_room):

		reward_room.queue_free()

	reward_room = null

	# ==================================================
	# Complete Current Room
	# ==================================================

	if current_room != null:

		complete_room()

	# ==================================================
	# Return To Battle Room
	# ==================================================

	if active_battle_room != null:

		print(
			"Returning to NormalBattleRoom"
		)

		active_battle_room.set_battle_active(
			false
		)

	else:

		push_error(
			"RoomManager: Current scene has no return_to_map()."
		)

	print("================================")
	print("RETURNED TO NORMAL BATTLE ROOM")
	print("PLAYER CONTROLS RESTORED")
	print("================================")


func apply_reward(reward) -> void:

	if reward == null:

		print("No reward selected")

		return

	print(
		"Applying reward:",
		reward
	)


	# ==================================================
	# Gene Reward
	# ==================================================

	if reward is GeneResource:

		var added: bool = (
			PermanentProgressionManager.add_gene(
				reward
			)
		)

		if added:

			save_manager.save_game(
				PermanentProgressionManager
			)

			print(
				"Permanent gene reward added:",
				reward.gene_name
			)

		else:

			print(
				"Could not add gene reward:",
				reward.gene_name
			)

		return


	# ==================================================
	# Unknown Reward
	# ==================================================

	print(
		"Unknown reward type:",
		reward
	)


# ==================================================
# Battle Completion
# ==================================================

func _on_battle_finished(result) -> void:

	print("================================")
	print("ROOM MANAGER: BATTLE FINISHED")
	print("Result:", result)
	print("================================")

	match result:

		"win":
			_on_battle_won()

		"lose":
			_on_battle_lost()

		_:
			push_error(
				"RoomManager received unknown battle result: "
				+ str(result)
			)


func _on_battle_won() -> void:

	print(
		"RoomManager: Battle won"
	)

	# --------------------------------------------------
	# New RoomResource path
	# --------------------------------------------------

	if current_room != null:

		complete_room()

	# --------------------------------------------------
	# Legacy map path
	# --------------------------------------------------

	else:

		if get_tree().current_scene.has_method(
			"return_to_map"
		):

			get_tree().current_scene.return_to_map()

		else:

			push_error(
				"RoomManager: Current scene has no return_to_map()."
			)


func _on_battle_lost() -> void:

	print(
		"RoomManager: Battle lost"
	)


# ==================================================
# Room Exits
# ==================================================

func select_room_exit(exit_id: int) -> void:

	print("================================")
	print("ROOM MANAGER: EXIT SELECTED")
	print("Exit ID:", exit_id)
	print("Current Room:", current_room)
	print("================================")

	if current_room == null:

		push_error(
			"RoomManager: Cannot select exit without current room."
		)

		return

	if not current_room.completed:

		print(
			"RoomManager: Current room is not completed."
		)

		return

	print(
		"Exit selected:",
		exit_id
	)

	# --------------------------------------------------
	# Get Next Room
	# --------------------------------------------------

	var next_room: RoomResource = (
		current_room.get_next_room(
			exit_id
		)
	)

	if next_room == null:

		push_error(
			"RoomManager: Exit "
			+ str(exit_id)
			+ " has no connected room."
		)

		return

	print(
		"Exit selected:",
		exit_id
	)

	print(
		"Next room:",
		next_room.room_name
	) 

	print(
		"Next room type:",
		next_room.room_type
	)

	# --------------------------------------------------
	# Start Next Room
	# --------------------------------------------------

	start_room(
		next_room
	)


# ==================================================
# Legacy Room Completion (temp)
# ==================================================


func complete_current_room() -> void:

	if map_manager == null:

		push_error(
			"RoomManager: MapManager is missing."
		)

		return

	if map_manager.current_room == null:

		push_error(
			"RoomManager: MapManager has no current room."
		)

		return

	map_manager.complete_current_room()

	GameEvents.room_completed.emit(
		map_manager.current_room
	)


# ==================================================
# Special Room Completion
# ==================================================

func _on_treasure_finished(reward) -> void:

	print(
		"Treasure complete:",
		reward
	)

	complete_current_room()

	treasure_room = null

	get_tree().current_scene.return_to_map()


func _on_merchant_finished() -> void:

	print("Merchant complete")

	complete_current_room()

	if is_instance_valid(merchant_room):

		merchant_room.close()
		merchant_room.queue_free()

	merchant_room = null

	get_tree().current_scene.return_to_map()


func _on_rest_finished() -> void:

	print("Rest complete")

	complete_current_room()

	rest_room = null

	get_tree().current_scene.return_to_map()


func _on_lab_finished() -> void:

	print("Lab complete")

	complete_current_room()

	if is_instance_valid(abandoned_lab):

		abandoned_lab.close()
		abandoned_lab.queue_free()

	abandoned_lab = null

	get_tree().current_scene.return_to_map()


func _on_mystery_finished() -> void:

	if is_instance_valid(mystery_room):

		mystery_room.queue_free()

	complete_current_room()

	mystery_room = null

	print(
		"Mystery complete"
	)

	get_tree().current_scene.return_to_map()
