extends AnimalBase
class_name EnemyAnimal

@export var enemy_data: EnemyResource


func start_battle():
	print("Enemy ready")

	# Load stats from resource
	if enemy_data != null:
		print("Loaded enemy:", enemy_data.enemy_name)

		base_hp = enemy_data.base_hp
		hp = base_hp

		base_attack = enemy_data.base_attack
		base_speed = enemy_data.base_speed

		# Equip starting genes
		for gene in enemy_data.starting_genes:
			add_gene(gene)

	setup_enemy_moves()


func setup_enemy_moves():

	selected_moves.clear()

	var attack = MoveResource.new()

	attack.move_name = "Attack"
	attack.power = 0
	attack.priority = 0
	attack.effect_type = MoveResource.MoveEffectType.DAMAGE

	add_move(attack)

	print(
		name,
		" learned enemy moves"
	)
	
	
func choose_action(_player) -> MoveResource:
	
	var moves = get_battle_moves()
	
	if moves.is_empty():
		print("Enemy has no moves!")
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
