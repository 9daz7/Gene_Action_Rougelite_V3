extends Node
class_name GeneDatabase

var all_common_genes: Array[Gene] = []

func load_genes():
	all_common_genes = [
		preload("res://resources/genes/BoarSkinGene.tres"),
		preload("res://resources/genes/cheetahSpeedGene.tres"),
		preload("res://resources/genes/TigerStrengthGene.tres")
	]

func get_random_starting_genes(count: int) -> Array[Gene]:
	var pool = all_common_genes.duplicate()
	pool.shuffle()
	return pool.slice(0, count)
