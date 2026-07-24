extends Node
class_name SaveManager


# ==================================================
# Constants
# ==================================================

const SAVE_PATH = "user://save.json"


# ==================================================
# Initialization
# ==================================================


func _ready():

	print("SaveManager ready")


# ==================================================
# Public Functions
# ==================================================


func save_game(run_manager):

	var data = {
		"genes": [],
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


func load_game(run_manager:RunManager, gene_database:GeneDatabase):
	
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

	if data == null:

		print("Save filecorrupted")
		return

	run_manager.gene_collection.clear()

	if data.has("genes"):

		for gene_name in data.genes:

			var gene = _find_gene(
				gene_name,
				gene_database
			)

			if gene != null:

				run_manager.gene_collection.append(gene)


	print("GAME LOADED")


# ==================================================
# Private Functions
# ==================================================


func _find_gene(gene_name:String, gene_database:GeneDatabase) -> GeneResource:

	for gene in gene_database.all_genes:

		if gene.gene_name == gene_name:

			return gene


	return null
