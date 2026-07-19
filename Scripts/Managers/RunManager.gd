extends Node
class_name RunManager


@onready var save_manager = $"../SaveManager"

var gold:int = 0

var player_hp:int = 100
var max_hp:int = 100

# Current animal loaded from Lab Hub
var current_animal_build:AnimalBuildResource

# Genes unlocked permanently
var gene_collection: Array[GeneResource] = []


func _ready():
	print("RUN MANAGER READY")
	
	
func start_run():

	if current_animal_build == null:
		print("ERROR: No animal build selected")
		return


	print(
		"Starting run with:",
		current_animal_build.animal_name
	)


	player_hp = current_animal_build.base_hp
	
	
func set_animal_build(build:AnimalBuildResource):
	
	current_animal_build = build
	current_animal_build.calculate_stats()
	
	print(
		"Animal build saved:",
		build.animal_name
	)


func save_animal_build(build:AnimalBuildResource):

	current_animal_build = build

	print(
		"Animal build saved:",
		build.animal_name
	)
	

func setup_run(starting_genes: Array[GeneResource]):
	if current_animal_build == null:
		push_error("No animal build selected")
		return
		
	current_animal_build.calculate_stats()
	
	print("=== Run Start ===")
	print("Animal:", current_animal_build.animal_name)
	
	for gene in current_animal_build.genes:
		print("Gene:", gene.gene_name)

	for move in current_animal_build.moves:
		print("Move:", move.move_name)


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


func collect_gene(gene: GeneResource):
	if not gene_collection.has(gene):
		gene_collection.append(gene)

	print("Unlocked gene:", gene.gene_name)


func owns_gene(gene: GeneResource) -> bool:

	return gene_collection.has(gene)
	

func store_gene(gene: GeneResource):

	if not gene_collection.has(gene):
		gene_collection.append(gene)

	print("Stored gene:", gene.gene_name)
	
	for owned_gene in gene_collection:
		print(owned_gene.gene_name)

	#else:
		#print("Gene already owned:", gene.gene_name)
		

	
func spend_gold(amount:int) -> bool:

	if save_manager.gold < amount:
		print("Not enough gold")
		return false

	save_manager.gold -= amount

	print("Gold remaining:", save_manager.gold)
	
	save_manager.save_game(self)

	return true


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
	
	
func get_hp_percent() -> float:

	return float(player_hp) / float(max_hp)
