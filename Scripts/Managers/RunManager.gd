extends Node

# Genes equipped for THIS run
var active_genes: Array[Gene] = []


# Genes unlocked permanently
var gene_collection: Array[Gene] = []


var adaptation_limit := 6
var used_adaptations := 0



func setup_run(starting_genes:Array[Gene]):

	clear_run()

	for gene in starting_genes:
		equip_gene(gene)



func equip_gene(gene:Gene)->bool:

	if used_adaptations + gene.adaptation_cost > adaptation_limit:
		print("Not enough adaptation slots")
		return false


	active_genes.append(gene)

	used_adaptations += gene.adaptation_cost

	return true



func apply_genes_to_player(player):

	for gene in active_genes:
		player.add_gene(gene)



func collect_gene(gene:Gene):

	if not gene_collection.has(gene):
		gene_collection.append(gene)

	print("Unlocked gene:", gene.gene_name)



func clear_run():

	active_genes.clear()
	used_adaptations = 0
