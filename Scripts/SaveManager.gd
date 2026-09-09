extends Node
class_name SaveManager


# ==================================================
# Constants
# ==================================================

const SAVE_PATH = "user://save.json"


# ==================================================
# Managers
# ==================================================

@onready var potion_storage: PotionStorageManager = get_node(
	"../PotionStorageManager"
)


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("SaveManager ready")


# ==================================================
# Public Functions
# ==================================================

func save_game(
	permanent_manager: Node,
	run_manager: RunManager
) -> void:

	if permanent_manager == null:

		push_error(
			"Cannot save: PermanentProgressionManager is missing"
		)

		return

	if run_manager == null:

		push_error(
			"Cannot save: RunManager is missing"
		)

		return

	if potion_storage == null:

		push_error(
			"Cannot save: PotionStorageManager is missing"
		)

		return

	# ==================================================
	# Build Save Data
	# ==================================================

	var data := {

		# --------------------------------------------------
		# Permanent Progression
		# --------------------------------------------------

		"permanent_currency":
			permanent_manager.permanent_currency,

		"genes":
			permanent_manager.gene_counts,

		"gene_storage_upgrade_level":
			permanent_manager.gene_storage_upgrade_level,

		"tutorial_completed":
			run_manager.tutorial_completed,

		# --------------------------------------------------
		# Permanent Upgrades
		# --------------------------------------------------

		"upgrades": {

			"max_health_level":
				permanent_manager.max_health_level,

			"starting_gold_level":
				permanent_manager.starting_gold_level,

			"damage_level":
				permanent_manager.damage_level
		},

		# --------------------------------------------------
		# Potion Storage
		# --------------------------------------------------

		"potion_storage":
			_serialize_potion_storage(),

		# --------------------------------------------------
		# Player Potion Pockets
		# --------------------------------------------------

		"potion_pocket":
			_serialize_potion_pocket(run_manager)
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

	# ==================================================
	# Debug
	# ==================================================

	print("GAME SAVED")

	print(
		"Permanent currency:",
		permanent_manager.permanent_currency
	)

	print(
		"Permanent genes:",
		permanent_manager.gene_counts
	)

	print(
		"Potion storage:",
		potion_storage.stored_potions
	)

	print(
		"Potion pocket:",
		run_manager.get_run_potions()
	)


# ==================================================
# Load Game
# ==================================================

func load_game(
	permanent_manager: Node,
	gene_database: GeneDatabase,
	run_manager: RunManager
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

	if run_manager == null:

		push_error(
			"Cannot load: RunManager is missing"
		)

		return

	if potion_storage == null:

		push_error(
			"Cannot load: PotionStorageManager is missing"
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
	# Load Gene Storage Upgrade
	# ==================================================

	if data.has("gene_storage_upgrade_level"):

		permanent_manager.gene_storage_upgrade_level = int(
			data["gene_storage_upgrade_level"]
		)

	# ==================================================
	# Load World Progression
	# ==================================================

	if data.has("tutorial_completed"):

		run_manager.tutorial_completed = bool(
			data["tutorial_completed"]
		)

	print(
		"Tutorial completed:",
		run_manager.tutorial_completed
	)

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
	# Load Potion Storage
	# ==================================================

	if data.has("potion_storage"):

		_deserialize_potion_storage(
			data["potion_storage"]
		)

	# ==================================================
	# Load Potion Pocket
	# ==================================================

	if data.has("potion_pocket"):

		_deserialize_potion_pocket(
			data["potion_pocket"],
			run_manager
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

	print(
		"Potion storage:",
		potion_storage.stored_potions
	)

	print(
		"Potion pocket:",
		run_manager.get_run_potions()
	)


# ==================================================
# Potion Serialization
# ==================================================

func _serialize_potion_storage() -> Array:

	var result: Array = []

	for potion in potion_storage.stored_potions.keys():

		if potion == null:
			continue

		var amount: int = potion_storage.get_potion_count(
			potion
		)

		if amount <= 0:
			continue

		if potion.resource_path.is_empty():
			print(
				"WARNING: Potion has no resource path:",
				potion.potion_name
			)

			continue

		result.append({
			"path": potion.resource_path,
			"amount": amount
		})

	return result


func _deserialize_potion_storage(
	saved_storage
) -> void:

	potion_storage.stored_potions.clear()

	if not saved_storage is Array:
		return

	for entry in saved_storage:

		if not entry is Dictionary:
			continue

		var path: String = str(
			entry.get("path", "")
		)

		var amount: int = int(
			entry.get("amount", 0)
		)

		if path.is_empty():
			continue

		if amount <= 0:
			continue

		var potion = load(path) as PotionResource

		if potion == null:

			print(
				"WARNING: Could not load saved potion:",
				path
			)

			continue

		potion_storage.stored_potions[
			potion
		] = amount


# ==================================================
# Potion Pocket Serialization
# ==================================================

func _serialize_potion_pocket(
	run_manager: RunManager
) -> Array:

	var result: Array = []

	var potions := run_manager.get_run_potions()

	for potion in potions:

		if potion == null:

			result.append(null)

			continue

		if potion.resource_path.is_empty():

			print(
				"WARNING: Potion in pocket has no resource path:",
				potion.potion_name
			)

			result.append(null)

			continue

		result.append(
			potion.resource_path
		)

	return result


func _deserialize_potion_pocket(
	saved_pocket,
	run_manager: RunManager
) -> void:

	if not saved_pocket is Array:
		return

	run_manager.run_potion_pocket = [
		null,
		null,
		null
	]

	for i in range(
		min(
			saved_pocket.size(),
			3
		)
	):

		var saved_value = saved_pocket[i]

		if saved_value == null:
			continue

		var path: String = str(
			saved_value
		)

		if path.is_empty():
			continue

		var potion = load(path) as PotionResource

		if potion == null:

			print(
				"WARNING: Could not load saved pocket potion:",
				path
			)

			continue

		run_manager.run_potion_pocket[i] = potion


# ==================================================
# Pocket Helpers
# ==================================================

#func run_manager_for_save_pocket() -> Array:
#
	## This calls RunManager's public getter.
	#return get_node("../RunManager").get_run_potions()


#func run_manager_for_load_pocket(
	#saved_pocket: Array
#) -> void:
#
	#var run_manager_node: RunManager = get_node(
		#"../RunManager"
	#)
#
	#run_manager_node.run_potion_pocket = [
		#null,
		#null,
		#null
	#]
#
	#for i in range(
		#min(
			#saved_pocket.size(),
			#RunManager.MAX_POTION_POCKET_SIZE
		#)
	#):
#
		#var saved_value = saved_pocket[i]
#
		#if saved_value == null:
			#continue
#
		#var path: String = str(
			#saved_value
		#)
#
		#if path.is_empty():
			#continue
#
		#var potion = load(path) as PotionResource
#
		#if potion == null:
#
			#print(
				#"WARNING: Could not load saved pocket potion:",
				#path
			#)
#
			#continue
#
		#run_manager_node.run_potion_pocket[i] = potion


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
