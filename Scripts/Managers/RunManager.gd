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
# Run Map Test
# ==================================================

func create_run_map() -> void:

	print("================================")
	print("CREATING TEST RUN MAP")
	print("================================")

	# --------------------------------------------------
	# Load Rooms
	# --------------------------------------------------

	var battle := load(
		"res://Data/Rooms/NormalBattle_01.tres"
	) as RoomResource

	var treasure := load(
		"res://Data/Rooms/Treasure_01.tres"
	) as RoomResource

	var shop := load(
		"res://Data/Rooms/Merchant_01.tres"
	) as RoomResource

	var event := load(
		"res://Data/Rooms/Event_01.tres"
	) as RoomResource

	var lab := load(
		"res://Data/Rooms/AbandonedLab_01.tres"
	) as RoomResource

	# --------------------------------------------------
	# Validate Rooms
	# --------------------------------------------------

	if battle == null:
		push_error(
			"RunManager: Failed to load NormalBattle_01."
		)
		return

	if treasure == null:
		push_error(
			"RunManager: Failed to load Treasure_01."
		)
		return

	if shop == null:
		push_error(
			"RunManager: Failed to load Merchant_01."
		)
		return

	if event == null:
		push_error(
			"RunManager: Failed to load Event_01."
		)
		return

	if lab == null:
		push_error(
			"RunManager: Failed to load AbandonedLab_01."
		)
		return

	# --------------------------------------------------
	# Reset Room State
	# --------------------------------------------------

	battle.completed = false
	treasure.completed = false
	shop.completed = false
	event.completed = false
	lab.completed = false

	# --------------------------------------------------
	# Build Graph
	# --------------------------------------------------

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

	# --------------------------------------------------
	# Debug
	# --------------------------------------------------

	print("RUN MAP CREATED")

	print(
		"Start:",
		current_run_map.start_room.room_name
	)

	print(
		"Total rooms:",
		current_run_map.rooms.size()
	)

	print(
		"Battle exits:",
		battle.next_rooms.size()
	)

	print(
		"Treasure exits:",
		treasure.next_rooms.size()
	)

	print(
		"Shop exits:",
		shop.next_rooms.size()
	)

	print(
		"Event exits:",
		event.next_rooms.size()
	)

	print("================================")
	print("STARTING RUN MAP")
	print("================================")

	# --------------------------------------------------
	# Start First Room
	# --------------------------------------------------

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
