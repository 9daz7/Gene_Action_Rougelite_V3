extends Node
class_name SaveManager


# ==================================================
# Constants
# ==================================================

const SAVE_PATH = "user://save.json"


# ==================================================
# Initialization
# ==================================================


func _ready() -> void:

	print("SaveManager ready")


# ==================================================
# Public Functions
# ==================================================


func save_game(permanent_manager: Node) -> void:

	if permanent_manager == null:

		push_error(
			"Cannot save: PermanentProgressionManager is missing"
		)

		return

	# ==================================================
	# Build Save Data
	# ==================================================

	var data := {
		"permanent_currency":
			permanent_manager.permanent_currency,

		"genes":
			permanent_manager.gene_counts,

		"upgrades": {
			"max_health_level":
				permanent_manager.max_health_level,

			"starting_gold_level":
				permanent_manager.starting_gold_level,

			"damage_level":
				permanent_manager.damage_level
		}
	}

	# ==================================================
	# Write File
	# ==================================================

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	if file == null:

		push_error(
			"Could not open save file for writing"
		)

		return

	file.store_string(
		JSON.stringify(data)
	)

	file.close()

	print("GAME SAVED")

	print(
		"Permanent currency:",
		permanent_manager.permanent_currency
	)

	print(
		"Permanent genes:",
		permanent_manager.gene_counts
	)


# ==================================================
# Load Game
# ==================================================


func load_game(
	permanent_manager: Node,
	gene_database:GeneDatabase
) -> void:
	
	if permanent_manager == null:

		push_error(
			"Cannot load: PermanentProgressionManager is missing"
		)

		return

	if gene_database == null:

		push_error(
			"Cannot load: GeneDatabase is missing"
		)

		return

	# ==================================================
	# First-Time Player
	# ==================================================

	if not FileAccess.file_exists(SAVE_PATH):

		print(
			"No permanent progression save found"
		)

		return

	# ==================================================
	# Open Save
	# ==================================================

	var file = FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	if file == null:

		push_error(
			"Could not open save file"
		)

		return

	var data = JSON.parse_string(
		file.get_as_text()
	)

	file.close()

	# ==================================================
	# Validate Save
	# ==================================================
	if data == null or not data is Dictionary:

		push_error(
			"Save file corrupted"
		)

		return

	# ==================================================
	# Load Permanent Currency
	# ==================================================

	if data.has("permanent_currency"):

		permanent_manager.permanent_currency = int(
			data["permanent_currency"]
		)

	# ==================================================
	# Load Gene Counts
	# ==================================================

	permanent_manager.gene_counts.clear()

	if data.has("genes"):

		var saved_genes = data["genes"]

		if saved_genes is Dictionary:

			for gene_name in saved_genes:

				var gene = _find_gene(
					str(gene_name),
					gene_database
				)

				if gene == null:

					print(
						"WARNING: Saved gene not found:",
						gene_name
					)

					continue

				var count := int(
					saved_genes[gene_name]
				)

				if count <= 0:
					continue

				permanent_manager.gene_counts[
					gene.gene_name
				] = count

	# ==================================================
	# Load Permanent Upgrades
	# ==================================================

	if data.has("upgrades"):

		var upgrades = data["upgrades"]

		if upgrades is Dictionary:

			permanent_manager.max_health_level = int(
				upgrades.get(
					"max_health_level",
					0
				)
			)

			permanent_manager.starting_gold_level = int(
				upgrades.get(
					"starting_gold_level",
					0
				)
			)

			permanent_manager.damage_level = int(
				upgrades.get(
					"damage_level",
					0
				)
			)

	# ==================================================
	# Finished
	# ==================================================

	print("GAME LOADED")

	print(
		"Permanent currency:",
		permanent_manager.permanent_currency
	)

	print(
		"Permanent genes:",
		permanent_manager.gene_counts
	)


# ==================================================
# Private Functions
# ==================================================

func _find_gene(
	gene_name: String,
	gene_database: GeneDatabase
) -> GeneResource:

	for gene in gene_database.all_genes:

		if gene.gene_name == gene_name:

			return gene

	return null
