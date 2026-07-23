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


# ==================================================
# Current Animal
# ==================================================

var current_animal_build:AnimalBuildResource


# ==================================================
# Gene Collection
# ==================================================

var gene_collection: Array[GeneResource] = []


# ==================================================
# Initialization
# ==================================================


func _ready():
	print("RUN MANAGER READY")
	
	
# ==================================================
# Run Control
# ==================================================


func start_run():
	
	run_active = true

	if current_animal_build == null:
		push_error(
			"No animal build selected"
		)
		return
		
	gold = 0

	current_animal_build.calculate_stats()

	player_hp = current_animal_build.base_hp
	
	print("=== Run Start ===")
	print(
		"Animal:",
		current_animal_build.animal_name
	)
	
	for gene in current_animal_build.genes:
		print(
			"Gene:",
			gene.gene_name
		)

	for move in current_animal_build.moves:
		print(
			"Move:",
			move.move_name
		)
	
	
func reset_run():
	
	run_active = false

	player_hp = max_hp

	current_animal_build = null
	
	print("Run reset")
	
	
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


#func setup_run():
	#
	#if current_animal_build == null:
		#push_error("No animal build selected")
		#return
		#
	#current_animal_build.calculate_stats()
	#
	#print("=== Run Start ===")
	#print(
		#"Animal:",
		#current_animal_build.animal_name
	#)
	#
	#for gene in current_animal_build.genes:
		#print(
			#"Gene:",
			#gene.gene_name
		#)
#
	#for move in current_animal_build.moves:
		#print(
			#"Move:",
			#move.move_name
		#)


func initialize_starting_collection(gene_database):

	if gene_collection.size() > 0:
		return

	var starter_genes = [
		
		"Turtle shell",
		
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


func unlock_gene(gene:GeneResource):
	
	if gene_collection.has(gene):
		return

	gene_collection.append(gene)

	print(
		"Unlocked gene:",
		gene.gene_name
	)
	
	save_manager.save_game(self)


func owns_gene(gene: GeneResource) -> bool:

	return gene_collection.has(gene)

	
func spend_gold(amount:int) -> bool:

	if gold < amount:
		print("Not enough gold")
		return false

	gold -= amount

	print(
		"Gold remaining:",
		gold
	)
	
	save_manager.save_game(self)

	return true


func add_gold(amount:int):

	gold += amount

	print(
		"Gold gained:",
		amount,
		" Total:",
		gold
	)

	save_manager.save_game(self)
	
	
func heal_player(amount:int):

	player_hp += amount

	if player_hp > max_hp:
		player_hp = max_hp
		
	print(
		"Player healed:",
		player_hp,
		"/",
		max_hp
	)
	
	save_manager.save_game(self)
	
	
func get_hp_percent() -> float:

	return float(player_hp) / float(max_hp)
