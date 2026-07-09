extends AnimalBase
class_name EnemyAnimal

@export var drop_gene_pool : Array[GeneResource]

func start_battle():

	print("Enemy ready")
	
	setup_basic_moves()


func choose_action(_player):

	if learned_moves.size() > 0:
		return learned_moves[0]
		
	return null
		
func get_drop_genes() -> Array[GeneResource]:
	
	var pool = drop_gene_pool.duplicate()
	
	pool.shuffle()
	
	return pool.slice(
		0,
		min(2, pool.size())
	)
	
