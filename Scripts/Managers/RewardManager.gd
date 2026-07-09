extends Node
class_name RewardManager

@export var all_mutagens : Array[MutagenResource] = []

func generate_rewards(enemy: EnemyAnimal) -> RewardResult:
	
	var reward := RewardResult.new()
	
	#
	# mutagen rewards
	#

	var mutagens = all_mutagens.duplicate()
	
	mutagens.shuffle()
	
	reward.mutagen_choices = mutagens.slice(
		0,
		min(3, mutagens.size())
	)
	
	#
	# gene discovery
	#

	if enemy != null:
		reward.discovered_gene = enemy.get_drop_genes()
		
		print(
			"Discovered gene:",
			reward.discovered_gene
		)
	
	return reward
	
