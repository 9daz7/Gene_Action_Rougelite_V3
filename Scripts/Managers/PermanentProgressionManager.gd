extends Node
class_name PermanentProgressionManager


# ==================================================
# Permanent Currency
# ==================================================

var permanent_currency: int = 0


# ==================================================
# Permanent Upgrades
# ==================================================

var max_health_level: int = 0
var starting_gold_level: int = 0
var damage_level: int = 0


# ==================================================
# Gene Unlocks
# ==================================================

var unlocked_genes: Array[String] = []


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

	print(
		"Permanent currency spent:",
		amount,
		"Remaining:",
		permanent_currency
	)

	return true


# ==================================================
# Gene Unlocks
# ==================================================

func unlock_gene(gene: GeneResource) -> bool:

	if gene == null:
		return false

	if unlocked_genes.has(gene.gene_name):
		return false

	unlocked_genes.append(gene.gene_name)

	print(
		"Permanent gene unlocked:",
		gene.gene_name
	)

	return true


func is_gene_unlocked(gene: GeneResource) -> bool:

	if gene == null:
		return false

	return unlocked_genes.has(
		gene.gene_name
	)
