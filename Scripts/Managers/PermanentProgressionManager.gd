extends Node


# ==================================================
# Signals
# ==================================================

signal gene_collection_changed
signal gene_storage_changed


# ==================================================
# Permanent Currency
# ==================================================

var permanent_currency: int = 0


# ==================================================
# Gene Collection
# ==================================================

# Stores permanent gene copies by gene name.
var gene_counts: Dictionary = {}


# ==================================================
# Gene Storage
# ==================================================

const BASE_GENE_STORAGE_CAPACITY: int = 10

var gene_storage_upgrade_level: int = 0

const GENE_STORAGE_PER_UPGRADE: int = 5


# ==================================================
# Permanent Upgrades
# ==================================================

var max_health_level: int = 0
var starting_gold_level: int = 0
var damage_level: int = 0


# ==================================================
# Gene Trade Values
# ==================================================

const GENE_TRADE_VALUES := {
	GeneResource.Rarity.COMMON: 5,
	GeneResource.Rarity.UNCOMMON: 10,
	GeneResource.Rarity.RARE: 20,
	GeneResource.Rarity.EPIC: 40,
}


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	print("PermanentProgressionManager initialized")


# ==================================================
# Currency
# ==================================================

func add_currency(amount: int) -> void:

	if amount <= 0:
		return

	permanent_currency += amount

	GameEvents.permanent_currency_changed.emit(
		permanent_currency
	)

	print(
		"Permanent currency gained:",
		amount,
		"Total:",
		permanent_currency
	)


func spend_currency(amount: int) -> bool:

	if amount <= 0:
		return false

	if permanent_currency < amount:
		return false

	permanent_currency -= amount

	GameEvents.permanent_currency_changed.emit(
		permanent_currency
	)

	print(
		"Permanent currency spent:",
		amount,
		"Remaining:",
		permanent_currency
	)

	return true


# ==================================================
# Gene Collection
# ==================================================


func get_gene_storage_capacity() -> int:

	return (
		BASE_GENE_STORAGE_CAPACITY
		+
		gene_storage_upgrade_level
		*
		GENE_STORAGE_PER_UPGRADE
	)


func get_gene_storage_used() -> int:

	var total := 0

	for count in gene_counts.values():
		total += int(count)

	return total


func can_add_gene(
	amount: int = 1
) -> bool:

	if amount <= 0:
		return false

	return (
		get_gene_storage_used() + amount
		<=
		get_gene_storage_capacity()
	)


func add_gene(
	gene: GeneResource,
	amount: int = 1
) -> bool:

	if gene == null:
		return false

	if amount <= 0:
		return false

	if not can_add_gene(amount):

		print(
			"Gene storage full:",
			get_gene_storage_used(),
			"/",
			get_gene_storage_capacity()
		)

		return false

	var gene_name := gene.gene_name

	var current_count: int = gene_counts.get(
		gene_name,
		0
	)

	var was_unlocked: bool = current_count > 0

	gene_counts[gene_name] = current_count + amount

	print(
		"Permanent gene added:",
		gene_name,
		"x",
		amount,
		"Total:",
		gene_counts[gene_name]
	)

	if not was_unlocked:
		GameEvents.gene_unlocked.emit(gene)

	gene_collection_changed.emit()
	gene_storage_changed.emit()

	return true


func remove_gene(gene: GeneResource, amount: int = 1) -> bool:

	if gene == null:
		return false

	if amount <= 0:
		return false

	var gene_name := gene.gene_name

	var current_count: int = gene_counts.get(
		gene_name,
		0
	)

	if current_count < amount:
		print(
			"Cannot remove gene:",
			gene_name,
			"Not enough copies"
		)

		return false

	current_count -= amount

	if current_count <= 0:
		gene_counts.erase(gene_name)
	else:
		gene_counts[gene_name] = current_count

	print(
		"Permanent gene removed:",
		gene_name,
		"x",
		amount,
		"Remaining:",
		current_count
	)

	gene_collection_changed.emit()
	gene_storage_changed.emit()

	return true


func get_gene_count(gene: GeneResource) -> int:

	if gene == null:
		return 0

	return gene_counts.get(
		gene.gene_name,
		0
	)


func get_all_gene_counts() -> Dictionary:

	return gene_counts.duplicate()


func get_owned_genes(
	gene_database: GeneDatabase
) -> Array[GeneResource]:

	var result: Array[GeneResource] = []

	if gene_database == null:
		return result

	for gene in gene_database.all_genes:

		if owns_gene(gene):

			result.append(gene)

	return result


func owns_gene(gene: GeneResource) -> bool:

	return get_gene_count(gene) > 0


func is_gene_unlocked(gene: GeneResource) -> bool:

	return owns_gene(gene)


# ==================================================
# Gene Trading
# ==================================================

func get_gene_trade_value(
	gene: GeneResource
) -> int:

	if gene == null:
		return 0

	return GENE_TRADE_VALUES.get(
		gene.rarity,
		0
	)


func trade_gene(gene: GeneResource) -> bool:

	if gene == null:
		return false

	var trade_value := get_gene_trade_value(
		gene
	)

	if trade_value <= 0:

		print(
			"Cannot trade gene:",
			gene.gene_name
		)

		return false

	if not remove_gene(gene):

		print(
			"Cannot trade gene:",
			gene.gene_name,
			"Gene is not in permanent collection"
		)

		return false

	add_currency(
		trade_value
	)

	print(
		"Gene traded:",
		gene.gene_name,
		"Value:",
		trade_value
	)

	return true


# ==================================================
# Run Rewards
# ==================================================

func reward_enemy_defeats(enemy_count: int) -> int:

	if enemy_count <= 0:
		return 0

	# 1 defeated enemy = 1 permanent currency
	var reward := enemy_count

	add_currency(reward)

	print(
		"Enemy defeat reward:",
		reward
	)

	return reward
