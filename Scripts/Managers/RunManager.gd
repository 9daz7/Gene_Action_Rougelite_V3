extends Node
class_name RunManager


var gold: int = 0

var player_hp:int = 100
var max_hp:int = 100

# Genes equipped for this run
var active_genes: Array[GeneResource] = []


# Genes unlocked permanently
var gene_collection: Array[GeneResource] = []


var player_genes: Array[GeneResource] = []


var adaptation_limit := 6
var used_adaptations := 0


func _ready():
	print("RUN MANAGER READY")


func setup_run(starting_genes: Array[GeneResource]):
	print("=== RUN MANAGER START ===")
	print("Genes received:", starting_genes.size())

	clear_run()
	player_genes.clear()

	gold = 100
	
	print("Starting Gold:", gold)
	
	for gene in starting_genes:
		equip_gene(gene)
		player_genes.append(gene)
		
		# Add starting genes to owned storage
		if not gene_collection.has(gene):
			gene_collection.append(gene)

		print("Starting gene:", gene.gene_name)


func equip_gene(gene: GeneResource) -> bool:
	if used_adaptations + gene.adaptation_cost > adaptation_limit:
		print("Not enough adaptation slots")
		return false

	active_genes.append(gene)
	used_adaptations += gene.adaptation_cost

	return true


func apply_genes_to_player(player):
	for gene in active_genes:
		player.add_gene(gene)


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

	else:
		print("Gene already owned:", gene.gene_name)
		

func clear_run():
	active_genes.clear()
	used_adaptations = 0
	
	
func spend_gold(amount:int) -> bool:

	if gold < amount:
		print("Not enough gold")
		return false

	gold -= amount

	print("Gold remaining:", gold)

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
	
