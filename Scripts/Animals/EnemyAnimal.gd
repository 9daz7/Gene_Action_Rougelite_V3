extends AnimalBase
class_name EnemyAnimal


@export var enemy_data: EnemyResource


func start_battle():
	
	print("Enemy ready")

	# Load stats from resource
	if enemy_data:
		
		print("Loaded enemy:", enemy_data.enemy_name)

		load_animal_stats(enemy_data)
		
		hp = base_hp
		
		load_genes(enemy_data.starting_genes)

	setup_enemy_moves()


func setup_enemy_moves():

	selected_moves.clear()

	var attack = MoveResource.new()

	attack.move_name = "Attack"
	attack.power = 0
	attack.priority = 0
	attack.effect_type = MoveResource.MoveEffectType.DAMAGE

	add_move(attack)

	
func choose_action(player:AnimalBase) -> MoveResource:
	
	var moves = get_battle_moves()
	
	if moves.is_empty():
		return null
	
	return moves[0]


func get_drop_gene() -> GeneResource:
	
	if enemy_data == null:
		return null

	var pool = enemy_data.drop_gene_pool.duplicate()

	if pool.is_empty():
		return null

	pool.shuffle()

	return pool[0]
