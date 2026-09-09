extends Node
class_name RoomManager


# ==================================================
# Managers
# ==================================================


@onready var battle_manager = $"../BattleManager"
@onready var run_manager = $"../RunManager"
@onready var save_manager = $"../SaveManager"

@onready var run_mutagen_manager: RunMutagenManager = get_node(
	"../RunMutagenManager"
)

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


const TREASURE_SCENE = preload("res://Scenes/Rooms/TreasureRoom_01.tscn")
#const MERCHANT_SCENE = preload("res://Scenes/Rooms/MerchantRoom.tscn")
#const REST_SCENE = preload("res://Scenes/Rooms/RestRoom.tscn")
#const ABANDONED_LAB_SCENE = preload("res://Scenes/Rooms/AbandonedLab.tscn")
#const MYSTERY_SCENE = preload("res://Scenes/Rooms/MysteryRoom.tscn")
const REWARD_SCENE = preload("res://Scenes/Rooms/RewardRoom.tscn")


# ==================================================
# Room State
# ==================================================


var current_room: RoomResource = null
var active_room_scene: Node = null
var current_run_node: RunMapNode = null


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


# ==================================================
# Start Run Map Node
# ==================================================

func start_room_node(
	node: RunMapNode
) -> void:

	if node == null:

		push_error(
			"RoomManager: Cannot start null RunMapNode."
		)

		return

	if node.room == null:

		push_error(
			"RoomManager: RunMapNode has no RoomResource."
		)

		return

	current_run_node = node
	current_room = node.room

	if map_manager != null:

		#if map_manager.run_map != run_manager.current_run_map:
#
			#map_manager.set_run_map(
				#run_manager.current_run_map
			#)

		map_manager.set_current_node(
			node
		)

	print("================================")
	print("ROOM MANAGER: STARTING MAP NODE")
	print("Room:", node.room.room_name)
	print("Layer:", node.layer)
	print("Node:", node.index)
	print("Next paths:", node.next_nodes.size())
	print("================================")

	start_room(
		node.room
	)


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

		RoomResource.RoomType.START:
			open_room_scene(room)

		RoomResource.RoomType.BATTLE:
			open_room_scene(room)

		RoomResource.RoomType.ELITE:
			start_new_elite_room(room)

		RoomResource.RoomType.LAB:
			start_new_lab_room(room)

		RoomResource.RoomType.REWARD:
			start_new_reward_room(room)

		RoomResource.RoomType.SHOP:
			start_new_shop_room(room)

		RoomResource.RoomType.EVENT:
			start_new_event_room(room)

		RoomResource.RoomType.REST:
			start_new_rest_room(room)

		RoomResource.RoomType.TREASURE:
			start_new_treasure_room(room)

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
	# RoomWorld handles its own exits
	# --------------------------------------------------

	if active_room_scene is RoomWorld:

		print(
			"Exits available on entry:",
			active_room_scene.exits_available_on_entry
		)


# ==================================================
# Room Exits
# ==================================================

func connect_room_exits() -> void:

	if active_room_scene == null:
		push_error(
			"RoomManager: Cannot connect exits without an active room scene."
		)
		return

	var exits := active_room_scene.find_children(
		"*",
		"RoomExit",
		true,
		false
	)

	print("================================")
	print("ROOM MANAGER: CONNECTING EXITS")
	print("Found exits:", exits.size())
	print("================================")

	for exit in exits:

		if not exit is RoomExit:
			continue

		if not exit.exit_entered.is_connected(
			_on_room_exit_entered
		):

			exit.exit_entered.connect(
				_on_room_exit_entered
			)

		print(
			"Connected RoomExit:",
			exit.name,
			" Exit ID:",
			exit.exit_id
		)


func set_room_exits_enabled(enabled: bool) -> void:

	if active_room_scene == null:
		return

	var exits := active_room_scene.find_children(
		"*",
		"RoomExit",
		true,
		false
	)

	for exit in exits:

		if exit is RoomExit:

			exit.set_enabled(
				enabled
			)

			print(
				"RoomExit",
				exit.exit_id,
				"enabled:",
				enabled
			)


func _on_room_exit_entered(exit_id: int) -> void:

	print("================================")
	print("ROOM MANAGER: ROOM EXIT ENTERED")
	print("Exit ID:", exit_id)
	print("================================")

	select_room_exit(
		exit_id
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

	if current_run_node != null:

		current_run_node.completed = true

	if map_manager != null:

		map_manager.mark_current_node_complete()

	print(
		"ROOM COMPLETED:",
		current_room.room_name
	)

	set_room_exits_enabled(true)

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

		RoomResource.RoomType.START:
			return "Start"

		RoomResource.RoomType.BATTLE:
			return "Battle"

		RoomResource.RoomType.ELITE:
			return "Elite"

		RoomResource.RoomType.LAB:
			return "Lab"

		RoomResource.RoomType.REWARD:
			return "Reward"

		RoomResource.RoomType.SHOP:
			return "Shop"

		RoomResource.RoomType.EVENT:
			return "Event"

		RoomResource.RoomType.BOSS:
			return "Boss"

		RoomResource.RoomType.REST:
			return "Rest"

		RoomResource.RoomType.TREASURE:
			return "Treasure"

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


func start_new_lab_room(room: RoomResource) -> void:

	print(
		"Starting new RoomResource lab room:"
	)

	print(
		room.room_name
	)

	open_room_scene(room)

# ==================================================
# Non-Battle Rooms
# ==================================================

func start_new_treasure_room(
	room: RoomResource
) -> void:

	print("================================")
	print("STARTING TREASURE ROOM")
	print("Room:", room.room_name)
	print("================================")

	open_room_scene(room)


func start_new_rest_room(
	room: RoomResource
) -> void:

	print("================================")
	print("STARTING REST ROOM")
	print("Room:", room.room_name)
	print("================================")

	open_room_scene(room)


func start_new_shop_room(
	room: RoomResource
) -> void:

	print("================================")
	print("STARTING SHOP ROOM")
	print("Room:", room.room_name)
	print("================================")

	open_room_scene(room)


func start_new_event_room(
	room: RoomResource
) -> void:

	print("================================")
	print("STARTING EVENT ROOM")
	print("Room:", room.room_name)
	print("================================")

	open_room_scene(room)


func start_new_reward_room(
	room: RoomResource
) -> void:

	print("================================")
	print("STARTING REWARD ROOM")
	print("Room:", room.room_name)
	print("================================")

	open_room_scene(room)


# ==================================================
# Room Encounters
# ==================================================

func start_room_battle() -> void:

	print("================================")
	print("ROOM MANAGER: STARTING ROOM BATTLE")
	print("================================")


	if current_room == null:

		push_error(
			"RoomManager: No current room."
		)

		return

	if battle_manager == null:

		push_error(
			"RoomManager: BattleManager not found."
		)

		return

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

	match current_room.room_type:

		RoomResource.RoomType.BATTLE:

			print("Starting NORMAL battle")

			battle_manager.start_battle(
				RoomData.RoomType.ENEMY
			)

		RoomResource.RoomType.ELITE:

			print("Starting ELITE battle")

			battle_manager.start_battle(
				RoomData.RoomType.ELITE
			)

		RoomResource.RoomType.BOSS:

			print("Starting BOSS battle")

			battle_manager.start_battle(
				RoomData.RoomType.BOSS
			)

		_:

			push_error(
				"RoomManager: Room cannot start a battle: "
				+ str(current_room.room_type)
			)


# ==================================================
# Roaming Battle
# ==================================================

func start_roaming_battle(
	enemy_resource: EnemyResource
) -> void:

	if battle_manager == null:

		push_error(
			"RoomManager: BattleManager is missing."
		)

		return

	battle_manager.start_roaming_battle(
		enemy_resource
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

	#merchant_room = MERCHANT_SCENE.instantiate()

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

	#rest_room = REST_SCENE.instantiate()

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

	#abandoned_lab = ABANDONED_LAB_SCENE.instantiate()

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

	#mystery_room = MYSTERY_SCENE.instantiate()

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


func apply_reward(
	reward
) -> void:

	if reward == null:

		print(
			"No reward selected"
		)

		return

	print(
		"Applying reward:",
		reward
	)

	print(
		"Reward runtime class:",
		reward.get_class()
	)

	print(
		"Reward script:",
		reward.get_script()
	)

	# ==================================================
	# Gene
	# ==================================================

	if reward is GeneResource:

		var added: bool = (
			PermanentProgressionManager.add_gene(
				reward
			)
		)

		if added:

			save_manager.save_game(
				PermanentProgressionManager,
				run_manager
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
	# Mutagen
	# ==================================================

	if reward is MutagenResource:

		if run_mutagen_manager == null:

			push_error(
				"RoomManager: RunMutagenManager is missing."
			)

			return

		var added_mutagen: bool = (
			run_mutagen_manager.add_mutagen_with_reserve(
				reward
			)
		)

		if added_mutagen:

			print(
				"RUN MUTAGEN ADDED:",
				reward.mutagen_name
			)

		else:

			print(
				"COULD NOT ADD MUTAGEN:",
				reward.mutagen_name
			)

		return

	# ==================================================
	# Unknown
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

	# ==================================================
	# Roaming battle
	# ==================================================

	if battle_manager.roaming_battle:

		print(
			"RoomManager: Roaming battle victory."
		)

		return

	# ==================================================
	# Normal RoomResource battle
	# ==================================================

	if current_room != null:

		var defeated_room_type := (
			current_room.room_type
		)

		# --------------------------------------------------
		# Complete the room first
		# --------------------------------------------------

		complete_room()

		# --------------------------------------------------
		# Boss defeated
		# --------------------------------------------------

		if defeated_room_type == RoomResource.RoomType.BOSS:

			print("================================")
			print("BOSS DEFEATED")
			print("World:", run_manager.current_world)
			print("================================")

			run_manager.complete_world()

			return

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
	print("================================")

	# ==================================================
	# Validate Current Node
	# ==================================================

	if current_run_node == null:

		push_error(
			"RoomManager: No current RunMapNode."
		)

		return


	# ==================================================
	# Validate Exit
	# ==================================================

	if exit_id < 0:

		push_error(
			"RoomManager: Invalid exit ID."
		)

		return

	if exit_id >= current_run_node.next_nodes.size():

		push_error(
			"RoomManager: Exit "
			+ str(exit_id)
			+ " has no generated path."
		)

		return

	# ==================================================
	# Get Next Node
	# ==================================================

	var next_node: RunMapNode = (
		current_run_node.next_nodes[exit_id]
	)

	if next_node == null:

		push_error(
			"RoomManager: Generated path is null."
		)

		return


	if next_node.room == null:

		push_error(
			"RoomManager: Next node has no room."
		)

		return


	print(
		"Next room:",
		next_node.room.room_name
	)

	print(
		"Next room type:",
		next_node.room.room_type
	)

	print(
		"Next layer:",
		next_node.layer
	)


	# ==================================================
	# Advance Run Map
	# ==================================================

	current_run_node.visited = true
	current_run_node.completed = true

	var previous_node := current_run_node

	current_run_node = next_node
	current_run_node.visited = true

	current_room = current_run_node.room


	if map_manager != null:

		map_manager.set_current_node(
			current_run_node
		)

	# ==================================================
	# Start Next Room
	# ==================================================

	print(
	"Leaving node:",
	previous_node.get_id()
)

	print(
		"Entering node:",
		current_run_node.get_id()
	)

	call_deferred(
		"start_room_node",
		current_run_node
	)


func close_active_room() -> void:

	print("================================")
	print("ROOM MANAGER: CLOSING ACTIVE ROOM")
	print("================================")

	if active_room_scene == null:

		print("No active room scene.")

		return

	if is_instance_valid(active_room_scene):

		print(
			"Closing room:",
			active_room_scene.name
		)

		active_room_scene.hide()
		active_room_scene.process_mode = Node.PROCESS_MODE_DISABLED

		active_room_scene.queue_free()

	active_room_scene = null


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
