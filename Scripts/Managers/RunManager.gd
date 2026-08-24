extends Node
class_name RunManager


# ==================================================
# Managers
# ==================================================

@onready var room_manager: RoomManager = get_node(
	"../RoomManager"
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
# Current Animal
# ==================================================

var current_animal_build:AnimalBuildResource


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

	_add_available_rooms(
		candidates,
		RoomResource.RoomType.LAB,
		exit_count
	)

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


func create_run_map() -> void:

	print("================================")
	print("GENERATING RUN MAP")
	print("================================")

	current_run_map = RunMapResource.new()

	# --------------------------------------------------
	# Layer Structure
	# --------------------------------------------------

	var layer_sizes := [
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
	# Create Layers
	# --------------------------------------------------

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

			var next_layer_size := 0

			if layer_index < layer_sizes.size() - 1:

				next_layer_size = (
					layer_sizes[layer_index + 1]
				)

			var room := _create_layer_room(
				layer_index,
				node_index,
				layer_size,
				next_layer_size
			)

			if room == null:

				push_error(
					"RunManager: Failed to create "
					+ "room for layer "
					+ str(layer_index)
					+ " node "
					+ str(node_index)
				)

				return

			var node := RunMapNode.new(
				room,
				layer_index,
				node_index
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


	# --------------------------------------------------
	# Start Node
	# --------------------------------------------------

	current_run_map.start_node = (
		current_run_map.layers[0][0]
	)

	current_run_map.current_node = (
		current_run_map.start_node
	)


	# --------------------------------------------------
	# Connect Layers
	# --------------------------------------------------

	for layer_index in range(
		current_run_map.layers.size() - 1
	):

		var current_layer: Array = (
			current_run_map.layers[layer_index]
		)

		var next_layer: Array = (
			current_run_map.layers[layer_index + 1]
		)

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
	# Start Run At Starting Node
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


func _connect_graph_layers(
	current_layer: Array,
	next_layer: Array
) -> bool:

	if current_layer.is_empty():
		return false

	if next_layer.is_empty():
		return false

	# ==================================================
	# Calculate Path Capacity
	# ==================================================

	var total_paths := 0

	for node in current_layer:

		total_paths += (
			node.room.exit_count
		)

	# ==================================================
	# Validate Capacity
	# ==================================================

	if total_paths < next_layer.size():

		push_error(
			"RunManager: Not enough outgoing paths "
			+ "to connect every node in next layer."
		)

		return false

	# ==================================================
	# next node parent check
	# ==================================================

	for next_index in range(
		next_layer.size()
	):

		var next_node: RunMapNode = (
			next_layer[next_index]
		)

		var parent_index := (
			next_index % current_layer.size()
		)

		var parent: RunMapNode = (
			current_layer[parent_index]
		)

		if parent.next_nodes.size() >= (
			parent.room.exit_count
		):

			# Find another parent with space.
			var found_parent := false

			for candidate in current_layer:

				if candidate.next_nodes.size() < (
					candidate.room.exit_count
				):

					parent = candidate
					found_parent = true
					break

			if not found_parent:

				push_error(
					"RunManager: Failed to assign parent."
				)

				return false

		parent.connect_to(
			next_node
		)

	# ==================================================
	# Fill Remaining Exits
	# ==================================================
	
	for parent in current_layer:

		while parent.next_nodes.size() < (
			parent.room.exit_count
		):

			var candidates: Array[RunMapNode] = []

			for next_node in next_layer:

				if not parent.next_nodes.has(
					next_node
				):

					candidates.append(
						next_node
					)

			if candidates.is_empty():

				push_error(
					"RunManager: Could not fill all "
					+ "room exits."
				)

				return false

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
					" (",
					next_node.room.room_name,
					")"
				)

	print("================================")


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

	enemies_defeated = 0

	current_animal_build = null

	GameEvents.gold_changed.emit(gold)

	GameEvents.hp_changed.emit(
		player_hp,
		max_hp
	)

	print("Run reset")


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
