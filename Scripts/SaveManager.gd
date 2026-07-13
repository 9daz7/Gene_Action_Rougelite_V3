extends Node
class_name SaveManager


const SAVE_PATH = "user://save.json"


func save_game(run_manager):
	
	var data = {
		"genes": []
	}
	
	for gene in run_manager.gene_collection:
		data.genes.append(gene.gene_name)
		
	var file = FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)
	
	file.store_string(
		JSON.stringify(data)
	)
	
	print("GAME SAVED")
	
	
func load_game(run_manager, gene_database):
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save found")
		return

	var file = FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	var data = JSON.parse_string(
		file.get_as_text()
	)

	for gene_name in data.genes:
		for gene in gene_database.all_genes:
			if gene.gene_name == gene_name:
				run_manager.gene_collection.append(gene)


	print("GAME LOADED")
