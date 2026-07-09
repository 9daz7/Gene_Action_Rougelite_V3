extends AnimalBase
class_name EnemyAnimal

@export var enemy_data : GeneResource

func start_battle():

	print("Enemy ready")
	
	# load stats from resource
	if enemy_data != null:

		base_hp = enemy_data.max_hp
		hp = base_hp
		
		base_attack = enemy_data.attack
		base_speed = enemy_data.speed
		
		# equip starting genes
		for gene in enemy_data.starting_genes:
			add_gene(gene)
			
	setup_basic_moves()
		
func choose_action(_player) -> MoveResource:
	
	return learned_moves[0]
		
func get_drop_genes() -> Array[GeneResource]:
	
	if enemy_data == null:
		return []
		
	var pool = enemy_data.gene_pool.duplicate()
	
	pool.shuffle()
	
	return pool.slice(
		0,
		min(2, pool.size())
	)
	
