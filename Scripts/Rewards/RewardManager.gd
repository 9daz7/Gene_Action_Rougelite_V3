extends Node
class_name RewardManager

@export var all_mutagens : Array[MutagenResource] = []

func generate_rewards(enemy) -> RewardResult:
	
	var reward := RewardResult.new()
	
	#
	# random mutagen
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

	if enemy.has_method("get_drop_genes"):
		
		reward.discovered_gene = enemy.get_drop_genes()
	
	return reward
	
