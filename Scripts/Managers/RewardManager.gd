extends Node
class_name RewardManager


# ==================================================
# Managers
# ==================================================

@onready var run_manager: RunManager = $"../RunManager"

@onready var gene_database: GeneDatabase = $"../GeneDatabase"

@onready var run_mutagen_manager: RunMutagenManager = (
	$"../RunMutagenManager"
)

@onready var save_manager: SaveManager = $"../SaveManager"


# ==================================================
# Reward Generation
# ==================================================

func generate_rewards(
	enemy: EnemyAnimal
) -> RewardData:

	var rewards := RewardData.new()

	# ==================================================
	# Gold
	# ==================================================

	rewards.gold = generate_gold(
		enemy.enemy_data.enemy_type
	)

	# ==================================================
	# Gene
	# ==================================================

	rewards.gene_choices = generate_enemy_genes(enemy)

	# ==================================================
	# Mutagen
	# ==================================================

	rewards.mutagen_choices = generate_mutagen_rewards()

	# ==================================================
	# Other Resources
	# ==================================================

	rewards.resources = generate_resources(enemy.enemy_data.enemy_type)

	print("Rewards generated:")

	for gene in rewards.gene_choices:
		print("Gene:", gene.gene_name)

	for mutagen in rewards.mutagen_choices:

		print(
			"Mutagen:",
			mutagen.mutagen_name,
			"| Family:",
			mutagen.get_family_name(),
			"| Tier:",
			mutagen.tier
		)

	print("================================")

	return rewards


func generate_gold(enemy_type: EnemyResource.EnemyType) -> int:

	match enemy_type:

		EnemyResource.EnemyType.NORMAL:
			return randi_range(5,15)

		EnemyResource.EnemyType.ELITE:
			return randi_range(15,30)

		EnemyResource.EnemyType.BOSS:
			return randi_range(32,65)

		#RoomData.RoomType.GROUP_ENEMY:
			#return randi_range(8, 18)
#
		#RoomData.RoomType.AMBUSH:
			#return randi_range(16, 25)
#
		#RoomData.RoomType.MERCHANT_TRAP:
			#return randi_range(20, 40)

		_:
			return 0


func generate_enemy_genes(enemy: EnemyAnimal) -> Array[GeneResource]:
	
	var choices: Array[GeneResource] = []
	
	if enemy == null:
		print("ERROR: No enemy")
		return choices
	
	if enemy.enemy_data == null:
		print("ERROR: Enemy has no data")
		return choices

	var amount := 1

	match enemy.enemy_data.enemy_type:

		EnemyResource.EnemyType.NORMAL:
			amount = 1

		EnemyResource.EnemyType.ELITE:
			amount = randi_range(1, 2)

		EnemyResource.EnemyType.BOSS:
			amount = 2
			
	var pool: Array[GeneResource] = enemy.enemy_data.drop_gene_pool.duplicate()

	pool.shuffle()

	for i in range(min(amount, pool.size())):
		choices.append(pool[i])

	return choices


func generate_gene_rewards(amount : int = 3) -> Array[GeneResource]:

	var available_genes:Array[GeneResource] = (gene_database.all_genes.duplicate())

	available_genes.shuffle()

	var choices: Array[GeneResource] = []

	for i in range(min(amount, available_genes.size())):
		choices.append(
			available_genes[i]
		)

	return choices

func generate_resources(enemy_type: EnemyResource.EnemyType) -> Array:

	var resources: Array = []

	match enemy_type:
		EnemyResource.EnemyType.NORMAL:
			if randf() < 0.4:
				resources.append("Small Heal")

		EnemyResource.EnemyType.ELITE:
			resources.append("Medium Heal")
			resources.append("Strength Potion")

		EnemyResource.EnemyType.BOSS:
			resources.append("Large Heal")
			resources.append("Rare Mutagen")

	return resources


# ==================================================
# Mutagen Rewards
# ==================================================

func generate_mutagen_rewards() -> Array[MutagenResource]:

	if run_mutagen_manager == null:

		push_error(
			"RewardManager: RunMutagenManager is missing."
		)

		return []

	# ==================================================
	# Choose one family
	# ==================================================

	var family := (
		run_mutagen_manager.choose_weighted_mutagen_family()
	)

	print(
		"Mutagen reward family:",
		run_mutagen_manager.get_mutagen_family_name(
			family
		)
	)

	# ==================================================
	# Generate three choices
	# ==================================================

	var choices := (
		run_mutagen_manager.generate_mutagen_choices(
			family
		)
	)

	return choices


func apply_reward(
	reward
) -> void:

	if reward == null:

		print(
			"No reward selected"
		)

		return

	# ==================================================
	# Gene
	# ==================================================

	if reward is GeneResource:

		var added: bool = (
			PermanentProgressionManager.add_gene(
				reward
			)
		)

		if added:

			save_manager.save_game(
				PermanentProgressionManager
			)

			print(
				"Permanent gene reward added:",
				reward.gene_name
			)

		else:

			print(
				"Could not add gene reward:",
				reward.gene_name
			)

		return

	# ==================================================
	# Mutagen
	# ==================================================

	if reward is MutagenResource:

		var added_mutagen: bool = (
			run_mutagen_manager.add_mutagen(
				reward
			)
		)

		if added_mutagen:

			print(
				"Run Mutagen added:",
				reward.mutagen_name
			)

		else:

			print(
				"Could not add Mutagen:",
				reward.mutagen_name
			)

		return

	# ==================================================
	# Unknown
	# ==================================================

	print(
		"Unknown reward type:",
		reward
	)
