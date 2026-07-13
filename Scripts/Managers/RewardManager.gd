extends Node
class_name RewardManager


@export var all_mutagens: Array[MutagenResource] = []

@onready var run_manager = $"../RunManager"
@onready var gene_database = $"../GeneDatabase"


func generate_rewards(room_type):

	var rewards = RewardData.new()

	rewards.gold = randi_range(15,30)


	rewards.gene_choices = generate_gene_rewards()


	print("Rewards generated:")

	for gene in rewards.gene_choices:
		print(gene.gene_name)


	return rewards
#func generate_rewards(room_type: int) -> RewardResult:
	#var reward := RewardResult.new()
#
	#reward.gold = generate_gold(room_type)
#
	#reward.resources = generate_resources(room_type)
#
	#reward.discovered_gene = generate_gene_rewards(room_type)
#
	#reward.mutagen_choices = generate_mutagens(room_type)
#
	#return reward


func generate_gold(room_type: int) -> int:
	match room_type:
		RoomData.RoomType.ENEMY:
			return randi_range(15, 30)

		RoomData.RoomType.GROUP_ENEMY:
			return randi_range(25, 45)

		RoomData.RoomType.ELITE:
			return randi_range(50, 75)

		RoomData.RoomType.BOSS:
			return randi_range(100, 150)

		RoomData.RoomType.AMBUSH:
			return randi_range(25, 40)

		RoomData.RoomType.MERCHANT_TRAP:
			return randi_range(60, 90)

		_:
			return 0


func generate_resources(room_type: int) -> Array:
	var resources: Array = []

	match room_type:
		RoomData.RoomType.ENEMY:
			if randf() < 0.4:
				resources.append("Small Heal")

		RoomData.RoomType.ELITE:
			resources.append("Medium Heal")
			resources.append("Strength Potion")

		RoomData.RoomType.BOSS:
			resources.append("Large Heal")

	return resources


func generate_gene_rewards(amount := 3):

	var available_genes:Array[GeneResource] = []

	for gene in gene_database.all_genes:
		if not run_manager.owns_gene(gene):
			available_genes.append(gene)

	available_genes.shuffle()

	var choices:Array[GeneResource] = []

	for i in range(min(amount, available_genes.size())):
		choices.append(
			available_genes[i]
		)

	return choices
#func generate_gene_rewards(room_type: int) -> Array[GeneResource]:
	#match room_type:
		#RoomData.RoomType.ENEMY:
			#if randf() < 0.2:
				#return [
					#gene_database.get_random_gene_by_rarity(
						#GeneResource.Rarity.COMMON
					#)
				#]
#
			#return []


		#RoomData.RoomType.GROUP_ENEMY:
			#return gene_database.get_random_gene_choices(
				#2,
				#[
					#GeneResource.Rarity.COMMON,
					#GeneResource.Rarity.UNCOMMON
				#]
			#)
#
#
		#RoomData.RoomType.ELITE:
			#return gene_database.get_random_gene_choices(
				#3,
				#[
					#GeneResource.Rarity.UNCOMMON,
					#GeneResource.Rarity.RARE
				#]
			#)
#
#
		#RoomData.RoomType.BOSS:
			#return gene_database.get_random_gene_choices(
				#3,
				#[
					#GeneResource.Rarity.RARE,
					#GeneResource.Rarity.EPIC
				#]
			#)
#
#
		#RoomData.RoomType.LAB:
			#return gene_database.get_random_gene_choices(
				#3,
				#[
					#GeneResource.Rarity.RARE,
					#GeneResource.Rarity.EPIC
				#]
			#)
#
#
		#_:
			#return []
#

func generate_mutagens(room_type: int) -> Array[MutagenResource]:
	if room_type != RoomData.RoomType.BOSS \
	and room_type != RoomData.RoomType.ELITE \
	and room_type != RoomData.RoomType.LAB:

		return []


	var choices = all_mutagens.duplicate()

	choices.shuffle()

	return choices.slice(
		0,
		min(3, choices.size())
	)
