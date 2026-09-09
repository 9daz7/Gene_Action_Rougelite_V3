extends Node
class_name RunManager


# ==================================================
# Managers
# ==================================================

@onready var room_manager: RoomManager = get_node(
	"../RoomManager"
)

@onready var run_mutagen_manager: RunMutagenManager = get_node(
	"../RunMutagenManager"
)


# ==================================================
# Dependencies
# ==================================================

@onready var save_manager = $"../SaveManager"


# ==================================================
# Run Map
# ==================================================

var current_run_map: RunMapResource = null


# ==================================================
# World
# ==================================================

var current_world: int = 1


# ==================================================
# World Progression
# ==================================================

var tutorial_completed: bool = false

var world_transition_pending: bool = false


# ==================================================
# Room Pools
# ==================================================

var room_pools: Dictionary = {}


# ==================================================
# Run State
# ==================================================


var gold:int = 0

var player_hp:int = 100
var max_hp:int = 100

var run_active := false

var enemies_defeated: int = 0


# ==================================================
# Run Mutagens
# ==================================================

var run_mutagens: Array[MutagenResource] = []


# ==================================================
# Current Animal
# ==================================================

var current_animal_build:AnimalBuildResource


# ==================================================
# Run Pocket
# ==================================================

var run_potion_pocket: Array[PotionResource] = [
	null,
	null,
	null
]

var run_potion_brought_from_hub: Array[bool] = [
	false,
	false,
	false
]

const MAX_POTION_POCKET_SIZE: int = 3


# ==================================================
# Gene Collection
# ==================================================

var gene_collection: Array[GeneResource] = []


func remove_gene(
	gene: GeneResource
) -> bool:

	if gene == null:
		return false

	if not gene_collection.has(gene):
		return false

	gene_collection.erase(gene)

	print(
		"Gene removed from collection:",
		gene.gene_name
	)

	return true


func get_starting_world() -> int:

	#if tutorial_completed:
		#return 1

	return 1


# ==================================================
# Initialization
# ==================================================


func _ready():
	print("RUN MANAGER READY")


# ==================================================
# Room Pool Setup
# ==================================================

func initialize_room_pools() -> void:

	room_pools = {
		RoomResource.RoomType.START: {
			2: [],
		},

		RoomResource.RoomType.BATTLE: {
			1: [],
			2: [],
			3: []
		},

		RoomResource.RoomType.ELITE: {
			1: [],
			2: [],
			3: []
		},

		RoomResource.RoomType.SHOP: {
			1: [],
			2: [],
			3: []
		},

		RoomResource.RoomType.EVENT: {
			1: [],
			2: [],
			3: []
		},

		RoomResource.RoomType.REST: {
			1: [],
			2: [],
			3: []
		},

		RoomResource.RoomType.TREASURE: {
			1: [],
			2: [],
			3: []
		},

		RoomResource.RoomType.LAB: {
			1: [],
			2: [],
			3: []
		},

		RoomResource.RoomType.BOSS: {
			0: [],

		},
	}


func load_room_pools() -> void:

	print("================================")
	print("LOADING ROOM POOLS")
	print("================================")

	initialize_room_pools()


	_add_room_to_pool(
		"res://Data/Rooms/StartRoom.tres"
	)

	# ==================================================
	# Battle Rooms
	# ==================================================

	_add_room_to_pool(
		"res://Data/Rooms/NormalBattle_00.tres"
	)

	_add_room_to_pool(
		"res://Data/Rooms/NormalBattle_01.tres"
	)

	_add_room_to_pool(
		"res://Data/Rooms/NormalBattle_02.tres"
	)

	_add_room_to_pool(
		"res://Data/Rooms/NormalBattle_03.tres"
	)

	_add_room_to_pool(
		"res://Data/Rooms/NormalBattle_04.tres"
	)

	# ==================================================
	# Elite Rooms
	# ==================================================

	_add_room_to_pool(
		"res://Data/Rooms/EliteBattle_01.tres"
	)

	_add_room_to_pool(
		"res://Data/Rooms/EliteBattle_02.tres"
	)

	_add_room_to_pool(
		"res://Data/Rooms/EliteBattle_03.tres"
	)

	# ==================================================
	# Treasure Rooms
	# ==================================================

	_add_room_to_pool(
		"res://Data/Rooms/Treasure_01.tres"
	)

	_add_room_to_pool(
		"res://Data/Rooms/Treasure_02.tres"
	)

	# ==================================================
	# Shop Rooms
	# ==================================================

	_add_room_to_pool(
		"res://Data/Rooms/Merchant_01.tres"
	)


	# ==================================================
	# Rest Rooms
	# ==================================================

	_add_room_to_pool(
		"res://Data/Rooms/Rest_01.tres"
	)

	# ==================================================
	# Event Rooms
	# ==================================================

	_add_room_to_pool(
		"res://Data/Rooms/Event_01.tres"
	)

	#_add_room_to_pool(
		#"res://Data/Rooms/Event_02.tres"
	#)

	# ==================================================
	# Lab Rooms
	# ==================================================

	_add_room_to_pool(
		"res://Data/Rooms/AbandonedLab_01.tres"
	)

	_add_room_to_pool(
		"res://Data/Rooms/AbandonedLab_02.tres"
	)

	_add_room_to_pool(
		"res://Data/Rooms/AbandonedLab_03.tres"
	)

	# ==================================================
	# Boss Room
	# ==================================================

	_add_room_to_pool(
		"res://Data/Rooms/Boss_01.tres"
	)

	# ==================================================
	# Print Pool Summary
	# ==================================================

	print_pool_summary()

	print("================================")
	print("ROOM POOLS LOADED")
	print("================================")


func print_pool_summary() -> void:

	print("================================")
	print("ROOM POOL SUMMARY")
	print("================================")

	for type in room_pools.keys():

		print(
			"Room Type:",
			get_room_type_name(type)
		)

		for exit_count in room_pools[type].keys():

			var pool: Array = (
				room_pools[type][exit_count]
			)

			print(
				"  Exits:",
				exit_count,
				" Rooms:",
				pool.size()
			)

			for room in pool:

				print(
					"    -",
					room.room_name
				)


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

		RoomResource.RoomType.LAB:
			return "Lab"

		_:
			return "Unknown"


func _add_room_to_pool(
	path: String
) -> void:

	print(
		"Loading room:",
		path
	)

	var room := load(
		path
	) as RoomResource

	if room == null:

		push_error(
			"RunManager: Failed to load room: "
			+ path
		)

		return

	var type := room.room_type
	var exits := room.exit_count

	if not room_pools.has(type):

		push_error(
			"RunManager: No pool exists for room type: "
			+ str(type)
		)

		return

	if not room_pools[type].has(exits):

		push_error(
			"RunManager: Invalid exit count "
			+ str(exits)
			+ " for room: "
			+ room.room_name
		)

		return

	room_pools[type][exits].append(
		room
	)

	print(
		"Added room:",
		room.room_name,
		" Type:",
		type,
		" Exits:",
		exits
	)


# ==================================================
# Room Selection
# ==================================================

func get_random_room(
	room_type: RoomResource.RoomType,
	exit_count: int
) -> RoomResource:

	if not room_pools.has(room_type):

		push_error(
			"RunManager: No room pool for type: "
			+ str(room_type)
		)

		return null

	if not room_pools[room_type].has(exit_count):

		push_error(
			"RunManager: No room pool for exit count: "
			+ str(exit_count)
		)

		return null

	var pool: Array = (
		room_pools[room_type][exit_count]
	)

	if pool.is_empty():

		push_error(
			"RunManager: Empty pool for "
			+ get_room_type_name(room_type)
			+ " with "
			+ str(exit_count)
			+ " exits."
		)

		return null

	return pool.pick_random()


func _get_random_room_with_exit_count(
	room_type: RoomResource.RoomType,
	next_layer_size: int
) -> RoomResource:

	var possible_exit_counts: Array[int] = []

	for exit_count in room_pools[room_type].keys():

		if exit_count <= next_layer_size:

			if not room_pools[room_type][exit_count].is_empty():

				possible_exit_counts.append(
					exit_count
				)

	if possible_exit_counts.is_empty():

		push_error(
			"RunManager: No "
			+ get_room_type_name(room_type)
			+ " room can connect to a layer with "
			+ str(next_layer_size)
			+ " nodes."
		)

		return null

	var selected_exit_count: int = (
		possible_exit_counts.pick_random()
	)

	return get_random_room(
		room_type,
		selected_exit_count
	)


func _get_random_non_battle_room(
	exit_count: int
) -> RoomResource:

	var candidates: Array[RoomResource] = []

	_add_available_rooms(
		candidates,
		RoomResource.RoomType.TREASURE,
		exit_count
	)

	_add_available_rooms(
		candidates,
		RoomResource.RoomType.SHOP,
		exit_count
	)

	_add_available_rooms(
		candidates,
		RoomResource.RoomType.REST,
		exit_count
	)

	_add_available_rooms(
		candidates,
		RoomResource.RoomType.EVENT,
		exit_count
	)

	#_add_available_rooms(
		#candidates,
		#RoomResource.RoomType.LAB,
		#exit_count
	#)

	if candidates.is_empty():

		push_error(
			"RunManager: No non-battle room with "
			+ str(exit_count)
			+ " exits."
		)

		return null

	return candidates.pick_random()


func _add_available_rooms(
	candidates: Array[RoomResource],
	room_type: RoomResource.RoomType,
	exit_count: int
) -> void:

	if not room_pools.has(room_type):

		return

	if not room_pools[room_type].has(exit_count):

		return

	for room in room_pools[room_type][exit_count]:

		candidates.append(
			room
		)


func _get_random_mixed_room(
	exit_count: int
) -> RoomResource:

	var roll := randf()

	# ==================================================
	# Elite - 10%
	# ==================================================

	if roll < 0.10:

		var elite := _get_random_room_with_exit_count(
			RoomResource.RoomType.ELITE,
			exit_count
		)

		if elite != null:

			return elite


	# ==================================================
	# Normal Battle - 45%
	# ==================================================

	if roll < 0.55:

		var battle := _get_random_room_with_exit_count(
			RoomResource.RoomType.BATTLE,
			exit_count
		)

		if battle != null:

			return battle


	# ==================================================
	# Non-Battle - 45%
	# ==================================================

	return _get_random_non_battle_room(
			exit_count
	)


func _get_random_boss_room() -> RoomResource:

	if not room_pools.has(
		RoomResource.RoomType.BOSS
	):

		push_error(
			"RunManager: Boss pool does not exist."
		)

		return null

	var pool: Array = (
		room_pools[
			RoomResource.RoomType.BOSS
		].get(0, [])
	)

	if pool.is_empty():

		push_error(
			"RunManager: No 0-exit Boss room exists."
		)

		return null

	return pool.pick_random()


func validate_run_graph() -> bool:

	if current_run_map == null:

		push_error(
			"RunManager: No generated run map."
		)

		return false

	var final_layer_index := (
		current_run_map.layers.size() - 1
	)

	for node in current_run_map.all_nodes:

		if node.room == null:

			push_error(
				"RunManager: Node has no room."
			)

			return false

		# ==================================================
		# Exit Count Validation
		# ==================================================

		if node.next_nodes.size() != (
			node.room.exit_count
		):

			push_error(
				"RunManager: Exit mismatch in "
				+ node.room.room_name
				+ " | Physical exits: "
				+ str(node.room.exit_count)
				+ " | Generated paths: "
				+ str(node.next_nodes.size())
			)

			return false

		# ==================================================
		# Previous Path Validation
		# ==================================================

		if node.layer > 0:

			if node.previous_nodes.is_empty():

				push_error(
					"RunManager: Orphan node: "
					+ node.room.room_name
				)

				return false

		# ==================================================
		# Final Layer Validation
		# ==================================================
		
		if node.layer == final_layer_index:

			if not node.next_nodes.is_empty():

				push_error(
					"RunManager: Final node has "
					+ "outgoing paths: "
					+ node.room.room_name
				)

				return false

			if node.room.exit_count != 0:

				push_error(
					"RunManager: Final room must have "
					+ "0 exits: "
					+ node.room.room_name
				)

				return false


	print(
		"RUN GRAPH VALIDATION PASSED"
	)

	return true


# ==================================================
# World Layer Sizes
# ==================================================


func get_world_layer_sizes() -> Array[int]:

	match current_world:

		1:

			# --------------------------------------------------
			# First-time tutorial
			# --------------------------------------------------

			if not tutorial_completed:

				return [
					1,
					2,
					4,
					5,
					5,
					4,
					3,
					2,
					1
				]

			# --------------------------------------------------
			# Regular World 1
			# --------------------------------------------------

			return [
				1,
				2,
				3,
				4,
				4,
				4,
				3,
				2,
				1
			]

		_:

			# --------------------------------------------------
			# World 2
			# --------------------------------------------------

			return [
				1,
				randi_range(2, 3),
				randi_range(3, 5),
				randi_range(4, 5),
				randi_range(4, 5),
				randi_range(3, 5),
				randi_range(3, 4),
				2,
				1
			]

			## --------------------------------------------------
			## World 3+
			## --------------------------------------------------
#
			#return [
				#1,
				#randi_range(2, 3),
				#randi_range(3, 5),
				#randi_range(4, 5),
				#randi_range(4, 6),
				#randi_range(4, 6),
				#randi_range(4, 5),
				#randi_range(4, 5),
				#randi_range(3, 5),
				#randi_range(3, 4),
				#2,
				#1
			#]


# ==================================================
# Room Pool Availability
# ==================================================

func _has_room_with_exit_count(
	room_type: RoomResource.RoomType,
	exit_count: int
) -> bool:

	if not room_pools.has(room_type):

		return false

	if not room_pools[room_type].has(exit_count):

		return false

	var pool: Array = (
		room_pools[room_type][exit_count]
	)

	return not pool.is_empty()


# ==================================================
# Create Room For Node
# ==================================================

func _create_room_for_node(
	node: RunMapNode,
	total_layers: int
) -> RoomResource:

	if node == null:

		return null

	var required_exit_count : int = (
		node.next_nodes.size()
	)

	# ==================================================
	# Start
	# ==================================================

	if node.layer == 0:

		return _duplicate_room_template(
			get_random_room(
				RoomResource.RoomType.START,
				2
			)
		)

	# ==================================================
	# Boss
	# ==================================================

	if node.layer == total_layers - 1:

		return _duplicate_room_template(
			_get_random_boss_room()
		)

	# ==================================================
	# Rest Before Boss
	# ==================================================

	if node.layer == total_layers - 2:

		return _duplicate_room_template(
			get_random_room(
				RoomResource.RoomType.REST,
				required_exit_count
			)
		)

	# ==================================================
	# Tutorial World
	# ==================================================

	if current_world == 1 and not tutorial_completed:

		return _create_world_one_room(
			node,
			required_exit_count,
			total_layers
		)

	# ==================================================
	# Middle Layer Lab
	# ==================================================

	var middle_layer := int(
		total_layers / 2
	)

	if node.layer == middle_layer:

		return _duplicate_room_template(
			get_random_room(
				RoomResource.RoomType.LAB,
				required_exit_count
			)
		)

	# ==================================================
	# Procedural World
	# ==================================================

	return _create_procedural_world_room(
		node,
		required_exit_count,
		total_layers
	)

	## ==================================================
	## World 1 Tutorial
	## ==================================================
#
	#if current_world == 1:
#
		#return _create_world_one_room(
			#node,
			#required_exit_count,
			#total_layers
		#)
#
	## ==================================================
	## World 2+
	## ==================================================
#
	#return _create_procedural_world_room(
		#node,
		#required_exit_count,
		#total_layers
	#)


# ==================================================
# World 1 Room Selection
# ==================================================

func _create_world_one_room(
	node: RunMapNode,
	exit_count: int,
	total_layers: int
) -> RoomResource:

	if node.layer == 1:

		return _duplicate_room_template(
			get_random_room(
				RoomResource.RoomType.BATTLE,
				exit_count
			)
		)

	# ==================================================
	# Layer 2 = treasure / shop / battle
	# ==================================================

	if node.layer == 2:

		var candidates: Array[RoomResource.RoomType] = []

		# --------------------------------------------------
		# Battle
		# --------------------------------------------------

		if _has_room_with_exit_count(
			RoomResource.RoomType.BATTLE,
			exit_count
		):

			# 40 weight units
			for i in range(40):
				candidates.append(
					RoomResource.RoomType.BATTLE
				)


		# --------------------------------------------------
		# Treasure
		# --------------------------------------------------

		if _has_room_with_exit_count(
			RoomResource.RoomType.TREASURE,
			exit_count
		):

			# 30 weight units
			for i in range(30):
				candidates.append(
					RoomResource.RoomType.TREASURE
				)


		# --------------------------------------------------
		# Shop
		# --------------------------------------------------

		if _has_room_with_exit_count(
			RoomResource.RoomType.SHOP,
			exit_count
		):

			# 30 weight units
			for i in range(30):
				candidates.append(
					RoomResource.RoomType.SHOP
				)


		if candidates.is_empty():

			push_error(
				"RunManager: No World 1 room available for "
				+ str(exit_count)
				+ " exits."
			)

			return null


		var selected_type: RoomResource.RoomType = (
			candidates.pick_random()
		)

		return _duplicate_room_template(
			get_random_room(
				selected_type,
				exit_count
			)
		)

	var room_type := (
		_get_random_world_one_type(
			node.layer,
			total_layers,
			exit_count
		)
	)

	return _duplicate_room_template(
		get_random_room(
			room_type,
			exit_count
		)
	)


# ==================================================
# World 1 Type
# ==================================================

func _get_random_world_one_type(
	layer_index: int,
	total_layers: int,
	exit_count: int
) -> RoomResource.RoomType:

	var candidates: Array[RoomResource.RoomType] = []

	# --------------------------------------------------
	# Battle
	# --------------------------------------------------

	if _has_room_with_exit_count(
		RoomResource.RoomType.BATTLE,
		exit_count
	):

		candidates.append(
			RoomResource.RoomType.BATTLE
		)


	# --------------------------------------------------
	# Event
	# --------------------------------------------------

	if _has_room_with_exit_count(
		RoomResource.RoomType.EVENT,
		exit_count
	):

		candidates.append(
			RoomResource.RoomType.EVENT
		)

	# --------------------------------------------------
	# Treasure
	# --------------------------------------------------

	if _has_room_with_exit_count(
		RoomResource.RoomType.TREASURE,
		exit_count
	):

		candidates.append(
			RoomResource.RoomType.TREASURE
		)

	# --------------------------------------------------
	# Shop
	# --------------------------------------------------

	if _has_room_with_exit_count(
		RoomResource.RoomType.SHOP,
		exit_count
	):

		candidates.append(
			RoomResource.RoomType.SHOP
		)


	if candidates.is_empty():

		return RoomResource.RoomType.BATTLE


	return candidates.pick_random()

# --------------------------------------------------
# Lab
# --------------------------------------------------

	if _has_room_with_exit_count(
		RoomResource.RoomType.LAB,
		exit_count
	):

		candidates.append(
			RoomResource.RoomType.LAB
		)


# ==================================================
# Procedural World Room
# ==================================================

func _create_procedural_world_room(
	node: RunMapNode,
	exit_count: int,
	total_layers: int
) -> RoomResource:

	var roll := randf()

	# ==================================================
	# 10% Elite
	# ==================================================

	if roll < 0.10:

		var elite := get_random_room(
			RoomResource.RoomType.ELITE,
			exit_count
		)

		if elite != null:

			return _duplicate_room_template(
				elite
			)

	# ==================================================
	# 45% Normal Battle
	# ==================================================

	if roll < 0.55:

		var battle := get_random_room(
			RoomResource.RoomType.BATTLE,
			exit_count
		)

		if battle != null:

			return _duplicate_room_template(
				battle
			)

	# ==================================================
	# 45% Non-Battle
	# ==================================================

	var non_battle_type := (
		_choose_non_battle_type(
			node.layer,
			total_layers,
			exit_count
		)
	)

	var non_battle := get_random_room(
		non_battle_type,
		exit_count
	)

	if non_battle != null:

		return _duplicate_room_template(
			non_battle
		)

	# ==================================================
	# Fallback to Battle
	# ==================================================

	return _duplicate_room_template(
		get_random_room(
			RoomResource.RoomType.BATTLE,
			exit_count
		)
	)


# ==================================================
# Non-Battle Type Selection
# ==================================================

func _choose_non_battle_type(
	layer_index: int,
	total_layers: int,
	exit_count: int
) -> RoomResource.RoomType:

	var candidates: Array[RoomResource.RoomType] = []

	var possible_types := [
		RoomResource.RoomType.TREASURE,
		RoomResource.RoomType.EVENT,
		RoomResource.RoomType.SHOP,
		RoomResource.RoomType.REST
	]

	for room_type in possible_types:

		if not room_pools.has(room_type):

			continue

		if not room_pools[room_type].has(exit_count):

			continue

		if room_pools[room_type][exit_count].is_empty():

			continue

		candidates.append(
			room_type
		)
	if candidates.is_empty():

		push_error(
			"RunManager: No non-battle room supports "
			+ str(exit_count)
			+ " exits."
		)

		return RoomResource.RoomType.BATTLE

	var middle_start := int(
		total_layers * 0.35
	)

	var middle_end := int(
		total_layers * 0.65
	)

	var is_middle := (
		layer_index >= middle_start
		and
		layer_index <= middle_end
	)

	var roll := randf()

	if is_middle:

		if roll < 0.55 and (
			RoomResource.RoomType.TREASURE in candidates
		):

			return RoomResource.RoomType.TREASURE

		if roll < 0.75 and (
			RoomResource.RoomType.EVENT in candidates
		):

			return RoomResource.RoomType.EVENT

		if roll < 0.90 and (
			RoomResource.RoomType.SHOP in candidates
		):

			return RoomResource.RoomType.SHOP

	else:

		if roll < 0.35 and (
			RoomResource.RoomType.EVENT in candidates
		):

			return RoomResource.RoomType.EVENT

		if roll < 0.60 and (
			RoomResource.RoomType.SHOP in candidates
		):

			return RoomResource.RoomType.SHOP

		if roll < 0.80 and (
			RoomResource.RoomType.TREASURE in candidates
		):

			return RoomResource.RoomType.TREASURE

	return candidates.pick_random()


func complete_world() -> void:

	print("================================")
	print("WORLD COMPLETED")
	print("Current World:", current_world)
	print("================================")

	# ==================================================
	# Tutorial completion
	# ==================================================

	if current_world == 1 and not tutorial_completed:

		tutorial_completed = true

		print(
			"Tutorial World completed permanently."
		)

		# Save the permanent tutorial unlock immediately.
		save_manager.save_game(
			PermanentProgressionManager,
			self
		)

		world_transition_pending = true

		current_world = 2

		print(
			"Next World:",
			current_world
		)

		return

	# ==================================================
	# Normal World Progression
	# ==================================================

	if current_world < 2:

		current_world += 1

		world_transition_pending = true

		print(
			"Advanced to World:",
			current_world
		)


# ==================================================
# Layer Column
# ==================================================

func get_layer_column(
	node_index: int,
	layer_size: int
) -> int:

	match layer_size:

		1:
			return 2

		2:
			return node_index + 1

		3:
			return node_index + 1

		4:
			return node_index

		5:
			return node_index

		_:
			return node_index


# ==================================================
# Create Run Map
# ==================================================


func create_run_map() -> void:

	print("================================")
	print("GENERATING RUN MAP")
	print("World:", current_world)
	print("================================")

	current_run_map = RunMapResource.new()

	var layer_sizes := (
		get_world_layer_sizes()
	)

	# ==================================================
	# Create graph nodes without choosing rooms yet
	# ==================================================

	for layer_index in range(
		layer_sizes.size()
	):

		var layer_size: int = (
			layer_sizes[layer_index]
		)

		var layer_nodes: Array[RunMapNode] = []

		for node_index in range(
			layer_size
		):

			var column: int = get_layer_column(
				node_index,
				layer_size
			)

			var node := RunMapNode.new(
				null,
				layer_index,
				node_index,
				column
			)

			layer_nodes.append(
				node
			)

			current_run_map.all_nodes.append(
				node
			)

		current_run_map.layers.append(
			layer_nodes
		)

	# ==================================================
	# Start Node
	# ==================================================

	current_run_map.start_node = (
		current_run_map.layers[0][0]
	)

	current_run_map.current_node = (
		current_run_map.start_node
	)

	# ==================================================
	# Connect Graph
	# ==================================================

	for layer_index in range(
		current_run_map.layers.size() - 1
	):

		var current_layer: Array = (
			current_run_map.layers[layer_index]
		)

		var next_layer: Array = (
			current_run_map.layers[layer_index + 1]
		)

		# ==================================================
		# The start room is handled separately.
		# ==================================================

		if layer_index == 0:

			_connect_start_layer(
				current_layer,
				next_layer
			)

			continue

		# ==================================================
		# Normal procedural layers
		# ==================================================

		var connected := _connect_graph_layers(
			current_layer,
			next_layer
		)

		if not connected:

			push_error(
				"RunManager: Failed to connect graph layer "
				+ str(layer_index)
				+ " to "
				+ str(layer_index + 1)
			)

			return

	# ==================================================
	# Assign Rooms After Connections Exist
	# ==================================================

	for layer_index in range(
		current_run_map.layers.size()
	):

		var layer: Array = (
			current_run_map.layers[layer_index]
		)

		for node in layer:

			var room := (
				_create_room_for_node(
					node,
					layer_sizes.size()
				)
			)

			if room == null:

				push_error(
					"RunManager: Failed to assign room to node "
					+ str(node.index)
					+ " in layer "
					+ str(node.layer)
				)

				return

			node.room = room

	# ==================================================
	# Print Graph
	# ==================================================

	print_run_graph()

	# ==================================================
	# Validate Generated Graph
	# ==================================================

	if not validate_run_graph():

		push_error(
			"RunManager: Generated graph is invalid."
		)

		return

	# ==================================================
	# Start Run
	# ==================================================

	if current_run_map.start_node == null:

		push_error(
			"RunManager: Start node is missing."
		)

		return

	current_run_map.current_node = (
		current_run_map.start_node
	)

	var map_manager: MapManager = get_node(
		"../MapManager"
	)

	map_manager.set_run_map(
		current_run_map
	)

	map_manager.scanner_view_range = 0
	map_manager.enable_scanner()

	print(
		"Starting room:",
		current_run_map.current_node.room.room_name
	)

	room_manager.start_room_node(
		current_run_map.current_node
	)

	print("================================")
	print("RUN GRAPH READY")
	print("STARTING ROOM OPENED")
	print("================================")


func _get_required_exit_count(
	current_layer_size: int,
	next_layer_size: int
) -> int:

	if next_layer_size <= 0:
		return 0

	return ceili(
		float(next_layer_size)
		/
		float(current_layer_size)
	)


func _create_layer_room(
	layer_index: int,
	node_index: int,
	current_layer_size: int,
	next_layer_size: int
) -> RoomResource:

	# ==================================================
	# Start
	# ==================================================

	if layer_index == 0:

		return _duplicate_room_template(
			get_random_room(
				RoomResource.RoomType.START,
				2
			)
		)

	# ==================================================
	# Normal Battle Layer
	# ==================================================

	if layer_index == 1:

		var exit_count := _get_required_exit_count(
			current_layer_size,
			next_layer_size
		)

		return _duplicate_room_template(
			get_random_room(
				RoomResource.RoomType.BATTLE,
				exit_count
			)
		)

	# ==================================================
	# Non-Battle Layer
	# ==================================================

	if layer_index == 2:

		var exit_count := _get_required_exit_count(
			current_layer_size,
			next_layer_size
		)

		return _duplicate_room_template(
			_get_random_non_battle_room(
				exit_count
			)
		)

	# ==================================================
	# Mixed Layers
	# ==================================================

	if layer_index >= 3 and layer_index <= 6:

		var exit_count := _get_required_exit_count(
			current_layer_size,
			next_layer_size
		)

		return _duplicate_room_template(
			_get_random_mixed_room(
				exit_count
			)
		)


	# ==================================================
	# Elite Layer
	# ==================================================

	if layer_index == 7:

		return _duplicate_room_template(
			get_random_room(
				RoomResource.RoomType.ELITE,
				1
			)
		)

	# ==================================================
	# Boss Layer
	# ==================================================

	if layer_index == 8:

		return _duplicate_room_template(
			_get_random_boss_room()
		)

	return null


func get_required_next_layer_size(
	current_layer: Array
) -> int:

	var required_size := 1

	for node in current_layer:

		required_size = max(
			required_size,
			node.room.exit_count
		)

	return required_size


func _duplicate_room_template(
	template: RoomResource
) -> RoomResource:

	if template == null:

		return null

	var room := (
		template.duplicate(true)
		as RoomResource
	)

	if room == null:

		push_error(
			"RunManager: Failed to duplicate room template."
		)

		return null

	room.completed = false

	return room


func can_connect_nodes(
	from_node: RunMapNode,
	to_node: RunMapNode
) -> bool:

	if from_node == null:
		return false

	if to_node == null:
		return false

	# Must move exactly one layer forward.

	if to_node.layer != from_node.layer + 1:
		return false

	# ==================================================
	# Maximum horizontal movement is one column.
	# ==================================================

	if abs(
		to_node.column - from_node.column
	) > 1:

		return false

	return true


# ==================================================
# Connect Start Layer
# ==================================================

func _connect_start_layer(
	start_layer: Array,
	next_layer: Array
) -> void:

	if start_layer.is_empty():
		return

	if next_layer.is_empty():
		return

	var start_node: RunMapNode = (
		start_layer[0]
	)

	# ==================================================
	# Prefer the two nodes closest to the center.
	# ==================================================

	var candidates: Array[RunMapNode] = []

	for node in next_layer:

		if can_connect_nodes(
			start_node,
			node
		):

			candidates.append(
				node
			)

	candidates.sort_custom(
		func(a: RunMapNode, b: RunMapNode) -> bool:

			return abs(
				a.column - start_node.column
			) < abs(
				b.column - start_node.column
			)
	)

	var connection_count: int = min(
		2,
		candidates.size()
	)

	for index in range(
		connection_count
	):

		start_node.connect_to(
			candidates[index]
		)


# ==================================================
# Connect Graph Layers
# ==================================================


func _connect_graph_layers(
	current_layer: Array,
	next_layer: Array
) -> bool:

	if current_layer.is_empty():
		return false

	if next_layer.is_empty():
		return false

	const MAX_CONNECTIONS: int = 3

	# ==================================================
	# Give every next-layer node at least one parent
	# ==================================================

	for parent in current_layer:

		var candidates: Array[RunMapNode] = []

		for next_node in next_layer:

			if not can_connect_nodes(
				parent,
				next_node
			):

				continue

			if not parent.next_nodes.has(
				next_node
			):

				candidates.append(
					next_node
				)

		if candidates.is_empty():

			push_error(
				"RunManager: No legal path from "
				+ "layer "
				+ str(parent.layer)
				+ " column "
				+ str(parent.column)
			)

			return false

		var selected: RunMapNode = (
			candidates.pick_random()
		)

		parent.connect_to(
			selected
		)

	# ==================================================
	# Prefer the parent with fewer connections.
	# ==================================================

	for next_node in next_layer:

		if not next_node.previous_nodes.is_empty():

			continue

		var candidates: Array[RunMapNode] = []

		for parent in current_layer:

			if parent.next_nodes.size() >= MAX_CONNECTIONS:

				continue

			if not can_connect_nodes(
				parent,
				next_node
			):

				continue

			candidates.append(
				parent
			)

		if candidates.is_empty():

			push_error(
				"RunManager: Could not assign parent to node "
				+ str(next_node.index)
				+ " in layer "
				+ str(next_node.layer)
				+ " column "
				+ str(next_node.column)
			)

			return false

		var selected_parent: RunMapNode = (
			candidates.pick_random()
		)

		selected_parent.connect_to(
			next_node
		)

	for parent in current_layer:

		while (
			parent.next_nodes.size()
			<
			MAX_CONNECTIONS
		):

			var candidates: Array[RunMapNode] = []

			for next_node in next_layer:

				if parent.next_nodes.has(
					next_node
				):

					continue

				if not can_connect_nodes(
					parent,
					next_node
				):

					continue

				candidates.append(
					next_node
				)

			if candidates.is_empty():

				break

			# 50% chance of creating another branch.

			if randf() > 0.50:

				break

			var selected: RunMapNode = (
				candidates.pick_random()
			)

			parent.connect_to(
				selected
			)

	return true


# ==================================================
# Debug Graph Output
# ==================================================

func print_run_graph() -> void:

	print("================================")
	print("GENERATED RUN GRAPH")
	print("================================")


	for layer_index in range(
		current_run_map.layers.size()
	):

		var layer: Array = (
			current_run_map.layers[layer_index]
		)

		print(
			"----- LAYER ",
			layer_index,
			" -----"
		)

		for node in layer:

			print(
				"Node:",
				node.index,
				"| Column:",
				node.column,
				"| Room:",
				node.room.room_name,
				"| Type:",
				get_room_type_name(
					node.room.room_type
				),
				"| Exits:",
				node.room.exit_count
			)

			for next_node in node.next_nodes:

				print(
					"   -> Layer ",
					next_node.layer,
					" Node ",
					next_node.index,
					" Column ",
					next_node.column,
					" (",
					next_node.room.room_name,
					")"
				)

	print("================================")


func add_potion_to_bag(
	potion: PotionResource
) -> bool:

	if potion == null:
		return false

	return add_potion_to_run(potion)


func add_potion_to_run(
	potion: PotionResource,
	brought_from_hub: bool = false
) -> bool:

	if potion == null:
		return false

	for i in range(
		run_potion_pocket.size()
	):

		if run_potion_pocket[i] == null:

			run_potion_pocket[i] = potion

			run_potion_brought_from_hub[i] = (
				brought_from_hub
			)

			print(
				"Potion added to run slot:",
				i,
				"|",
				potion.potion_name,
				"| From Hub:",
				brought_from_hub
			)

			return true

	print("Potion pocket full.")

	return false


func remove_potion_from_run(
	slot_index: int
) -> PotionResource:

	if slot_index < 0:
		return null

	if slot_index >= run_potion_pocket.size():
		return null

	var potion: PotionResource = (
		run_potion_pocket[slot_index]
	)

	if potion == null:
		return null

	run_potion_pocket[slot_index] = null
	run_potion_brought_from_hub[slot_index] = false

	print(
		"Potion removed from run slot:",
		slot_index,
		"|",
		potion.potion_name
	)

	return potion


func has_run_potion(
	potion: PotionResource
) -> bool:

	if potion == null:
		return false

	return run_potion_pocket.has(
		potion
	)


func get_run_potions() -> Array[PotionResource]:

	return run_potion_pocket.duplicate()


func get_potion_pocket_capacity() -> int:

	return MAX_POTION_POCKET_SIZE


func get_empty_potion_slot() -> int:

	for i in range(
		run_potion_pocket.size()
	):

		if run_potion_pocket[i] == null:
			return i

	return -1


func start_run():

	if current_animal_build == null:

		push_error(
			"No animal build selected"
		)

		return

# ----------------------------------------------
# Start Run
# ----------------------------------------------

	run_active = true

	current_world = get_starting_world()

	gold = 35

	GameEvents.gold_changed.emit(gold)

# ----------------------------------------------
# Setup Animal
# ----------------------------------------------

	current_animal_build.calculate_stats()

	max_hp = (
		current_animal_build.animal.base_hp
		+
		current_animal_build.hp_bonus
	)

	player_hp = max_hp

	run_mutagens.clear()

# test test
	run_mutagen_manager.reset()

	GameEvents.hp_changed.emit(
		player_hp,
		max_hp
	)

	print(
		"Run started. Gold:",
		gold,
		"HP:",
		player_hp
	)

	print("=== Run Start ===")

	print(
		"Animal:",
		current_animal_build.animal_name
	)


func reset_run() -> void:

	gold = 0
	player_hp = max_hp
	run_active = false

	run_mutagens.clear()

	enemies_defeated = 0

	current_animal_build = null

	if run_mutagen_manager != null:

		run_mutagen_manager.reset()

	GameEvents.gold_changed.emit(gold)

	GameEvents.hp_changed.emit(
		player_hp,
		max_hp
	)

	print("Run reset")

	print(
		"Player bag:",
		get_run_potions()
	)


# ==================================================
# Enemy Defeats
# ==================================================


func record_battle_victory(defeated_enemies: Array) -> void:

	var defeated_count := 0

	for enemy in defeated_enemies:

		if enemy == null:
			continue

		if not enemy.is_alive():
			defeated_count += 1

	enemies_defeated += defeated_count

	print(
		"Battle victory:",
		defeated_count,
		" enemies defeated"
	)

	print(
		"Total enemies defeated this run:",
		enemies_defeated
	)


# ==================================================
# Animal Management
# ==================================================


func set_animal_build(
	build:AnimalBuildResource
):
	
	if build == null:
		push_error("Cannot set null animal build")
		return
		
	current_animal_build = build
	
	current_animal_build.calculate_stats()
	
	print(
		"Animal build saved:",
		build.animal_name
	)


# ==================================================
# Run Setup
# ==================================================


func initialize_starting_collection(gene_database):

	if gene_collection.size() > 0:
		return

	var starter_genes = [
	]

	for gene in gene_database.all_genes:

		if starter_genes.has(gene.gene_name):
			gene_collection.append(gene)

	print("Starting collection:")

	for gene in gene_collection:
		print(gene.gene_name)


func get_random_owned_genes(count:int) -> Array[GeneResource]:

	var available = gene_collection.duplicate()

	available.shuffle()

	if available.size() > count:
		available.resize(count)

	return available


func add_gene_to_run(gene: GeneResource) -> bool:

	if gene == null:
		return false

	gene_collection.append(
		gene
	)

	print(
		"Gene added to run collection:",
		gene.gene_name
	)

	return true


func owns_gene(gene: GeneResource) -> bool:

	return gene_collection.has(gene)


func spend_gold(amount:int) -> bool:

	if gold < amount:
		print("Not enough gold")
		return false

	gold -= amount

	GameEvents.gold_changed.emit(gold)

	print(
		"Gold remaining:",
		gold
	)

	return true


func add_gold(amount:int):

	gold += amount

	GameEvents.gold_changed.emit(gold)

	print(
		"Gold gained:",
		amount,
		" Total:",
		gold
	)


func add_mutagen(
	mutagen: MutagenResource
) -> bool:

	if mutagen == null:
		return false

	if run_mutagens.has(mutagen):
		return false

	run_mutagens.append(
		mutagen
	)

	print(
		"Mutagen added:",
		mutagen.mutagen_name
	)

	return true


func remove_mutagen(
	mutagen: MutagenResource
) -> bool:

	if mutagen == null:
		return false

	if not run_mutagens.has(mutagen):
		return false

	run_mutagens.erase(
		mutagen
	)

	return true


func heal_player(amount:int):

	player_hp += amount

	if player_hp > max_hp:
		player_hp = max_hp

	GameEvents.hp_changed.emit(
		player_hp,
		max_hp
	)

	GameEvents.player_healed.emit(amount)

	print(
		"Player healed:",
		player_hp,
		"/",
		max_hp
	)


func get_hp_percent() -> float:

	return float(player_hp) / float(max_hp)


func damage_player(amount: int):

	player_hp -= amount

	if player_hp < 0:
		player_hp = 0

	GameEvents.hp_changed.emit(
		player_hp,
		max_hp
	)

	GameEvents.player_damaged.emit(
		amount
	)

	print(
		"Player damaged:",
		player_hp,
		"/",
		max_hp
	)


func discard_unbrought_run_potions() -> void:

	for i in range(
		run_potion_pocket.size()
	):

		if run_potion_pocket[i] == null:
			continue

		if run_potion_brought_from_hub[i]:
			continue

		print(
			"Discarding run-found potion:",
			run_potion_pocket[i].potion_name
		)

		run_potion_pocket[i] = null
		run_potion_brought_from_hub[i] = false
