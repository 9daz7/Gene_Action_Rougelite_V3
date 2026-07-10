extends Node
class_name GeneDatabase


var all_genes: Array[GeneResource] = []


func load_genes():
	all_genes.clear()
	
	var folder = DirAccess.open("res://Data/Genes")
	
	if folder == null:
		print("Gene folder not found")
		return
		
	folder.list_dir_begin()
	
	var file = folder.get_next()
	
	while file != "":
		if file.ends_with(".tres"):
			var path = "res://Data/Genes/" + file
			
			var gene = load(path)
			if gene is GeneResource:
				all_genes.append(gene)
				
				print("Loaded gene:", gene.gene_name)
				
		file = folder.get_next()
		
	folder.list_dir_end()
	
	print("Total genes:", all_genes.size())
	

func get_random_starting_genes(count: int) -> Array[GeneResource]:
	var pool = all_genes.duplicate()
	pool.shuffle()
	return pool.slice(0, min(count, pool.size()))


func get_random_genes(amount: int) -> Array[GeneResource]:
	var pool = all_genes.duplicate()
	pool.shuffle()
	return pool.slice(0, min(amount, pool.size()))
