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
#var battle_rooms: Array[RoomResource] = []
#var elite_rooms: Array[RoomResource] = []
#
#var treasure_rooms: Array[RoomResource] = []
#var shop_rooms: Array[RoomResource] = []
#var rest_rooms: Array[RoomResource] = []
#var event_rooms: Array[RoomResource] = []
#var lab_rooms: Array[RoomResource] = []


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

		RoomResource.RoomType.REWARD: {
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
	}


func load_room_pools() -> void:

	print("================================")
	print("LOADING ROOM POOLS")
	print("================================")

	initialize_room_pools()

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

	_add_room_to_pool(
		"res://Data/Rooms/Event_02.tres"
	)

	# ==================================================
	# Lab Rooms
	# ==================================================

	_add_room_to_pool(
		"res://Data/Rooms/AbandonedLab_01.tres"
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


# ==================================================
# Run Map Test
# ==================================================

#func create_run_map() -> void:
#
	#print("================================")
	#print("CREATING TEST RUN MAP")
	#print("================================")
#
	## --------------------------------------------------
	## Load Rooms
	## --------------------------------------------------
#
	#var battle := load(
		#"res://Data/Rooms/NormalBattle_01.tres"
	#) as RoomResource
#
	#var treasure := load(
		#"res://Data/Rooms/Treasure_01.tres"
	#) as RoomResource
#
	#var shop := load(
		#"res://Data/Rooms/Merchant_01.tres"
	#) as RoomResource
#
	#var event := load(
		#"res://Data/Rooms/Event_01.tres"
	#) as RoomResource
#
	#var lab := load(
		#"res://Data/Rooms/AbandonedLab_01.tres"
	#) as RoomResource
#
#var battle := get_random_room(
	#battle_rooms
#)
#
#var treasure := get_random_room(
	#treasure_rooms
#)
#
#var shop := get_random_room(
	#shop_rooms
#)
#
#var event := get_random_room(
	#event_rooms
#)
#
#var lab := get_random_room(
	#lab_rooms
#)
	## --------------------------------------------------
	## Validate Rooms
	## --------------------------------------------------
#
	#if battle == null:
		#push_error(
			#"RunManager: Failed to load NormalBattle_01."
		#)
		#return
#
	#if treasure == null:
		#push_error(
			#"RunManager: Failed to load Treasure_01."
		#)
		#return
#
	#if shop == null:
		#push_error(
			#"RunManager: Failed to load Merchant_01."
		#)
		#return
#
	#if event == null:
		#push_error(
			#"RunManager: Failed to load Event_01."
		#)
		#return
#
	#if lab == null:
		#push_error(
			#"RunManager: Failed to load AbandonedLab_01."
		#)
		#return
#
	## --------------------------------------------------
	## Reset Room State
	## --------------------------------------------------
#
	#battle.completed = false
	#treasure.completed = false
	#shop.completed = false
	#event.completed = false
	#lab.completed = false
#
	## --------------------------------------------------
	## Build Graph
	## --------------------------------------------------
#
	#battle.next_rooms = [
		#treasure,
		#shop
	#]
#
	#treasure.next_rooms = [
		#event
	#]
#
	#shop.next_rooms = [
		#event
	#]
#
	#event.next_rooms = [
		#lab
	#]
#
	#lab.next_rooms = []
#
	## --------------------------------------------------
	## Create Run Map
	## --------------------------------------------------
#
	#current_run_map = RunMapResource.new()
#
	#current_run_map.start_room = battle
#
	#current_run_map.rooms = [
		#battle,
		#treasure,
		#shop,
		#event,
		#lab
	#]
#
	#current_run_map.current_room = battle
#
	## --------------------------------------------------
	## Debug
	## --------------------------------------------------
#
	#print("RUN MAP CREATED")
#
	#print(
		#"Start:",
		#current_run_map.start_room.room_name
	#)
#
	#print(
		#"Total rooms:",
		#current_run_map.rooms.size()
	#)
#
	#print(
		#"Battle exits:",
		#battle.next_rooms.size()
	#)
#
	#print(
		#"Treasure exits:",
		#treasure.next_rooms.size()
	#)
#
	#print(
		#"Shop exits:",
		#shop.next_rooms.size()
	#)
#
	#print(
		#"Event exits:",
		#event.next_rooms.size()
	#)
#
	#print("================================")
	#print("STARTING RUN MAP")
	#print("================================")
#
	## --------------------------------------------------
	## Start First Room
	## --------------------------------------------------
#
	#room_manager.start_room(
		#current_run_map.start_room
	#)
func create_run_map() -> void:

	print("================================")
	print("CREATING TEST RUN MAP")
	print("================================")

	# --------------------------------------------------
	# Make sure pools exist
	# --------------------------------------------------

	if battle_rooms.is_empty():

		push_error(
			"RunManager: Battle room pool is empty."
		)

		return

	if treasure_rooms.is_empty():

		push_error(
			"RunManager: Treasure room pool is empty."
		)

		return

	if shop_rooms.is_empty():

		push_error(
			"RunManager: Shop room pool is empty."
		)

		return

	if event_rooms.is_empty():

		push_error(
			"RunManager: Event room pool is empty."
		)

	if lab_rooms.is_empty():

		push_error(
			"RunManager: Lab room pool is empty."
		)

		return


	# --------------------------------------------------
	# Test Room Selection
	# --------------------------------------------------

	var battle := get_random_room(
		battle_rooms
	)

	var treasure := get_random_room(
		treasure_rooms
	)

	var shop := get_random_room(
		shop_rooms
	)

	var event := get_random_room(
		event_rooms
	)

	var lab := get_random_room(
		lab_rooms
	)

	if battle == null:
		return

	if treasure == null:
		return

	if shop == null:
		return

	if event == null:
		return

	if lab == null:
		return

	print(
		"Selected battle:",
		battle.room_name
	)

	print(
		"Selected treasure:",
		treasure.room_name
	)

	print(
		"Selected shop:",
		shop.room_name
	)

	print(
		"Selected event:",
		event.room_name
	)

	print(
		"Selected lab:",
		lab.room_name
	)


	# --------------------------------------------------
	# Build Test Graph
	# --------------------------------------------------

	battle.completed = false
	treasure.completed = false
	shop.completed = false
	event.completed = false
	lab.completed = false

	battle.next_rooms = [
		treasure,
		shop
	]

	treasure.next_rooms = [
		event
	]

	shop.next_rooms = [
		event
	]

	event.next_rooms = [
		lab
	]

	lab.next_rooms = []


	# --------------------------------------------------
	# Create Run Map
	# --------------------------------------------------

	current_run_map = RunMapResource.new()

	current_run_map.start_room = battle

	current_run_map.rooms = [
		battle,
		treasure,
		shop,
		event,
		lab
	]

	current_run_map.current_room = battle


	print("================================")
	print("RUN MAP CREATED FROM ROOM POOLS")
	print("================================")

	room_manager.start_room(
		current_run_map.start_room
	)

# ==================================================
# Run Control
# ==================================================


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
