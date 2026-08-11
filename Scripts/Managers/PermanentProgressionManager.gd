extends Node


# ==================================================
# Permanent Currency
# ==================================================

var permanent_currency: int = 0


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


func trade_gene(
	gene: GeneResource,
	run_manager: RunManager
) -> bool:

	if gene == null:
		return false

	if run_manager == null:
		print(
			"Cannot trade gene: RunManager not provided"
		)

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

	if not run_manager.remove_gene(gene):
		print(
			"Cannot trade gene:",
			gene.gene_name,
			"Gene is not in collection"
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
