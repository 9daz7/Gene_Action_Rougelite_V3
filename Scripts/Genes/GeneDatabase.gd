extends Node
class_name GeneDatabase


var all_common_genes: Array[GeneResource] = []


func load_genes():
	all_common_genes = [
		preload("res://Data/Genes/BoarSkinGene.tres"),
		preload("res://Data/Genes/CheetahSpeedGene.tres"),
		preload("res://Data/Genes/TigerStrenghtGene.tres")
	]


func get_random_starting_genes(count: int) -> Array[GeneResource]:
	var pool = all_common_genes.duplicate()
	pool.shuffle()
	return pool.slice(0, min(count, pool.size()))


func get_random_genes(amount: int) -> Array[GeneResource]:
	var pool = all_common_genes.duplicate()
	pool.shuffle()
	return pool.slice(0, min(amount, pool.size()))
