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

	#GameEvents.gene_unlocked.connect(
		#_on_gene_unlocked
	#)

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

	#player_hp = current_animal_build.final_hp
	#max_hp = current_animal_build.final_hp

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


func reset_run():

	run_active = false

	gold = 0
	player_hp = max_hp

	GameEvents.gold_changed.emit(gold)

	GameEvents.hp_changed.emit(
		player_hp,
		max_hp
	)

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

	GameEvents.gene_unlocked.emit(gene)

	save_manager.save_game(self)


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


#func _on_gene_unlocked(gene: GeneResource):
#
	#unlock_gene(gene)
