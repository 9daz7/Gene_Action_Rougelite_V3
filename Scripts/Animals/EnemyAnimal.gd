extends AnimalBase
class_name EnemyAnimal

@export var enemy_data : EnemyResource

func start_battle():

	print("Enemy ready")
	
	# load stats from resource
	if enemy_data != null:
		
		print("Loaded enemy:", enemy_data.enemy_name)

		base_hp = enemy_data.base_hp
		hp = base_hp
		
		base_attack = enemy_data.base_attack
		base_speed = enemy_data.base_speed
		
		# equip starting genes
		for gene in enemy_data.starting_genes:
			add_gene(gene)
			
	setup_basic_moves()
		
func choose_action(_player) -> MoveResource:
	
	return learned_moves[0]
		
		
func get_drop_gene() -> GeneResource:

	if enemy_data == null:
		return null

	var pool = enemy_data.drop_gene_pool.duplicate()

	if pool.is_empty():
		return null

	pool.shuffle()

	return pool[0]
