extends Node
class_name RewardManager


@onready var run_manager = $"../RunManager"
@onready var gene_database = $"../GeneDatabase"

@export var all_mutagens: Array[MutagenResource] = []


func generate_rewards(enemy: EnemyAnimal):

	var rewards = RewardData.new()

	# gold reward
	rewards.gold = generate_gold(
		enemy.enemy_data.enemy_type
	)

	# enemy specific gene
	rewards.gene_choices = generate_enemy_genes(enemy)

	# Other rewards
	rewards.resources = generate_resources(enemy.enemy_data.enemy_type)

	print("Rewards generated:")

	for gene in rewards.gene_choices:
		print("Gene:", gene.gene_name)

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


func generate_mutagens(room_type: int) -> Array[MutagenResource]:
	if (
		room_type != RoomData.RoomType.BOSS
		and room_type != RoomData.RoomType.ELITE
		and room_type != RoomData.RoomType.ABANDONED_LAB
	):
		return []

	var choices := all_mutagens.duplicate()

	choices.shuffle()

	return choices.slice(
		0,
		min(3, choices.size())
	)
