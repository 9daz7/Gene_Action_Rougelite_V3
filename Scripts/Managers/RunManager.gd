extends Node
class_name RunManager


# ==================================================
# Dependencies
# ==================================================


@onready var save_manager = $"../SaveManager"


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
